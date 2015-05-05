//
//  IXFileDataProvider.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/11/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//


#import "IXFileDataProvider.h"

#import "IXPathHandler.h"

#import "IXDataLoader.h"
#import "ZipArchive.h"

// IXFileDataProvider Attributes
IX_STATIC_CONST_STRING kIXSavePath = @"savePath";
IX_STATIC_CONST_STRING kIXUnzipPath = @"unzipPath";

// IXFileDataProvider Events
IX_STATIC_CONST_STRING kIXUnzipStarted = @"unzip.began";
IX_STATIC_CONST_STRING kIXUnzipSuccess = @"unzip.success";
IX_STATIC_CONST_STRING kIXUnzipFailed = @"unzip.failed";
IX_STATIC_CONST_STRING kIXDownloadProgress = @"downloadProgress"; // also a property

// IXFileDataProvider Read-only properties
// IX_STATIC_CONST_STRING kIXDownloadProgress = @"downloadProgress"; // also an event


@interface IXFileDataProvider ()

@property (nonatomic,copy) NSString* savedFileLocation;
@property (nonatomic,copy) NSURL* savedFileURL;
@property (nonatomic,copy) NSString* unzipToFileLocation;
@property (nonatomic,assign) BOOL isZipFile;
@property (nonatomic,strong) ZipArchive* zipArchive;
@property (nonatomic,strong) IXHTTPResponse* response;
@property (nonatomic) double downloadProgress;

@end

// Internal properties
IX_STATIC_CONST_STRING kIXAcceptValueZip = @"application/zip";

@implementation IXFileDataProvider
@dynamic response;

-(void)applySettings
{
    [super applySettings];
    
    [self setSavedFileURL:[[self attributeContainer] getURLValueForAttribute:kIXSavePath basePath:nil defaultValue:nil]];
    [self setSavedFileLocation:[[self attributeContainer] getPathValueForAttribute:kIXSavePath basePath:nil defaultValue:nil]];
    [self setUnzipToFileLocation:[[self attributeContainer] getPathValueForAttribute:kIXUnzipPath basePath:nil defaultValue:nil]];
    
    [self setIsZipFile:[[self unzipToFileLocation] length] > 0];
    if( [self isZipFile] && [self zipArchive] == nil )
    {
        [self setZipArchive:[[ZipArchive alloc] init]];
    }
    
    [IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes = [[IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes setByAddingObject:kIXAcceptValueZip];
}

-(void)GET:(NSString *)url completion:(LoadFinished)completion {

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSProgress *progress;
    __block NSURLSessionDownloadTask *downloadTask = [[IXAFHTTPSessionManager sharedManager] downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return _savedFileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (completion) completion((error == nil), nil, response, error);
    }];

    [downloadTask resume];
    [progress addObserver:self
               forKeyPath:kIXProgressKVOKey
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kIXProgressKVOKey]) {
        // Handle new fractionCompleted value
        NSProgress* progress = (NSProgress*)object;
        _downloadProgress = progress.fractionCompleted;
        [[self actionContainer] executeActionsForEventNamed:kIXDownloadProgress];
        IX_LOG_DEBUG(@"Download percent complete: %f", progress.fractionCompleted);
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

-(void)loadData:(BOOL)forceGet paginationKey:(NSString *)paginationKey
{
   // [super loadData:forceGet paginationKey:paginationKey];
    [self loadData:forceGet completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
        
//        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        
        if (error)
        {
            [self fireLoadFinishedEvents:NO];
        }
        else
        {
            if( [self isZipFile] )
            {
                [[self actionContainer] executeActionsForEventNamed:kIXUnzipStarted];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    BOOL wasSuccessful = [[self zipArchive] UnzipOpenFile:[self savedFileLocation]];
                    if( wasSuccessful )
                    {
                        wasSuccessful = [[self zipArchive] UnzipFileTo:[self unzipToFileLocation] overWrite:YES];
                        [[self zipArchive] UnzipCloseFile];
                    }
                    IX_dispatch_main_sync_safe(^{
                        if( wasSuccessful )
                        {
                            [[self actionContainer] executeActionsForEventNamed:kIXUnzipSuccess];
                        }
                        else
                        {
                            [[self actionContainer] executeActionsForEventNamed:kIXUnzipFailed];
                        }
                    });
                });
            }
            [self fireLoadFinishedEvents:YES];
        }
    }];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue;
    if ( [propertyName isEqualToString:kIXDownloadProgress])
    {
        returnValue = [NSString stringWithFormat:@"%lf", _downloadProgress];
    } else {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

/*-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
 
    if (forceGet == NO)
    {
        [self fireLoadFinishedEvents:YES shouldCacheResponse:NO];
    }
    else
    {
        [self setResponseRawString:nil];
        [self setResponseStatusCode:0];
        [self setResponseErrorMessage:nil];
        
        if ( [self dataBaseURL] != nil )
        {
            if( ![self isPathLocal] )
            {
                __weak typeof(self) weakSelf = self;
                AFHTTPRequestOperation *fileRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[self createURLRequest]];
                if( [[self savedFileLocation] length] > 0 )
                {
                    NSOutputStream* ops =[NSOutputStream outputStreamToFileAtPath:[self savedFileLocation] append:NO];;
                    fileRequestOperation.outputStream = ops;
                }
                [fileRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [weakSelf setResponseStatusCode:[[operation response] statusCode]];

                    if( [weakSelf isZipFile] )
                    {
                        [[weakSelf actionContainer] executeActionsForEventNamed:kIXUnzipStarted];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            BOOL wasSuccessful = [[self zipArchive] UnzipOpenFile:[self savedFileLocation]];
                            if( wasSuccessful )
                            {
                                wasSuccessful = [[self zipArchive] UnzipFileTo:[self unzipToFileLocation] overWrite:YES];
                                [[self zipArchive] UnzipCloseFile];
                            }
                            IX_dispatch_main_sync_safe(^{
                                if( wasSuccessful )
                                {
                                    [[weakSelf actionContainer] executeActionsForEventNamed:kIXUnzipSuccess];
                                }
                                else
                                {
                                    [[weakSelf actionContainer] executeActionsForEventNamed:kIXUnzipFailed];
                                }
                            });
                        });
                    }
                    [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:NO];

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf setResponseStatusCode:[[operation response] statusCode]];
                    [weakSelf setResponseErrorMessage:[error description]];
                    [weakSelf setResponseRawString:[operation responseString]];
                    [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                }];
                
                [[self httpClient] enqueueHTTPRequestOperation:fileRequestOperation];
            }
        }
        else
        {
            IX_LOG_ERROR(@"ERROR: 'url' of control [%@] is %@; is 'url' defined correctly in your datasource?", self.ID, self.url);
        }
    }
}*/

@end
