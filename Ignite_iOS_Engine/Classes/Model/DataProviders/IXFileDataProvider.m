//
//  IXFileDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name            | Type       | Description                  | Default |
 |-----------------|------------|------------------------------|---------|
 | saveToLocation  | *(string)* | /local/path/to/save/file.zip |         |
 | unzipToLocation | *(string)* | /local/path/to/extract       |         |

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name              | Type       | Description                                         |
 |-------------------|------------|-----------------------------------------------------|
 | raw_data_response | *(string)* | Raw data returned by Data Provider                  |
 | response_headers  | *(string)* | Response Headers                                    |
 | status_code       | *(string)* | Status Code                                         |
 | count_rows        | *(int)*    | Count of rows (requires datarow.basepath to be set) |
 | total.{dataRow}   | *(float)*  | Does math on defined dataRow key values             |
 | error_message     | *(string)* | Whoopsie.                                           |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseDataProvider
 
 ##  <a name="events">Events</a>

 | Name          | Description                              |
 |---------------|------------------------------------------|
 | unzip.started | Fires when unzip starts                  |
 | unzip.success | Fires when file is successfully unzipped |
 | unzip.failed  | Fires when file unzip fails              |

 ##  <a name="functions">Functions</a>
 
>   None
 
 ##  <a name="example">Example JSON</a> 
 
 
 */
//
//  [/Documentation]
/*  -----------------------------  */



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
