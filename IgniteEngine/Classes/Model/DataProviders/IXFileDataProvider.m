//
//  IXFileDataProvider.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/11/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

/*
#import "IXFileDataProvider.h"

#import "IXPathHandler.h"

#import "IXDataGrabber.h"
#import "AFHttpRequestOperation.h"
#import "ZipArchive.h"

// IXFileDataProvider Attributes
IX_STATIC_CONST_STRING kIXSaveToLocation = @"saveToLocation";
IX_STATIC_CONST_STRING kIXUnzipToLocation = @"unzipToLocation";

// IXFileDataProvider Events
IX_STATIC_CONST_STRING kIXUnzipStarted = @"unzip.started";
IX_STATIC_CONST_STRING kIXUnzipSuccess = @"unzip.success";
IX_STATIC_CONST_STRING kIXUnzipFailed = @"unzip.failed";

@interface IXFileDataProvider ()

@property (nonatomic,copy) NSString* savedFileLocation;
@property (nonatomic,copy) NSString* unzipToFileLocation;
@property (nonatomic,assign) BOOL isZipFile;
@property (nonatomic,strong) ZipArchive* zipArchive;

@end

@implementation IXFileDataProvider

-(void)applySettings
{
    [super applySettings];
    
    [self setSavedFileLocation:[[self propertyContainer] getPathPropertyValue:kIXSaveToLocation basePath:nil defaultValue:nil]];
    [self setUnzipToFileLocation:[[self propertyContainer] getPathPropertyValue:kIXUnzipToLocation basePath:nil defaultValue:nil]];
    
    [self setIsZipFile:[[self unzipToFileLocation] length] > 0];
    if( [self isZipFile] && [self zipArchive] == nil )
    {
        [self setZipArchive:[[ZipArchive alloc] init]];
    }
    
    if( [self acceptedContentType] )
    {
        [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObject:[self acceptedContentType]]];
    }
}

-(void)loadData:(BOOL)forceGet
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
            IX_LOG_ERROR(@"ERROR: 'data.baseurl' of control [%@] is %@; is 'data.baseurl' defined correctly in your data_provider?", self.ID, self.dataBaseURL);
        }
    }
}

@end
*/