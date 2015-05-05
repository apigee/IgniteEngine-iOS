//
//  IXHTTPDataProvider.m
//  Ignite Engine
//
//  Created by Brandon Shelley on 4/7/15.
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

#import "IXHTTPDataProvider.h"

#import "AFNetworking.h"
#import "AFOAuth2Manager.h"

#import "IXAFHTTPSessionManager.h"
#import "IXAppManager.h"
#import "IXDataLoader.h"
#import "IXLogger.h"
#import "IXViewController.h"
#import "IXSandbox.h"
#import "NSDictionary+IXAdditions.h"
#import "IXAttribute.h"
#import "IXAssetManager.h"
#import "IXPathHandler.h"
#import "IXJSONUtils.h"

// TODO: These attributes are old and need to be cleaned up and re-implemented
IX_STATIC_CONST_STRING kIXPredicateFormat = @"predicate.format";            //e.g. "%K CONTAINS[c] %@"
IX_STATIC_CONST_STRING kIXPredicateArguments = @"predicate.arguments";      //e.g. "email,[[inputbox.text]]"

/////////////////////////

// IXHTTPDataProvider Attributes
IX_STATIC_CONST_STRING kIXBody = @"body"; // main body object
IX_STATIC_CONST_STRING kIXQueryParams = @"queryParams";
IX_STATIC_CONST_STRING kIXHeaders = @"headers";
IX_STATIC_CONST_STRING kIXRequestType = @"requestType"; // if not defined, predict from Accept header. If defined, adds Accept header.
IX_STATIC_CONST_STRING kIXResponseType = @"responseType";
IX_STATIC_CONST_STRING kIXMethod = @"method";
IX_STATIC_CONST_STRING kIXDebugRequestBinUrl = @"debug.requestBinUrl";

IX_STATIC_CONST_STRING kIXBasicUserName = @"auth.basic.username";
IX_STATIC_CONST_STRING kIXBasicPassword = @"auth.basic.password";
//IX_STATIC_CONST_STRING kIXOAuthToken = @"auth.oauth.accessToken";
//IX_STATIC_CONST_STRING kIXOAuthTokenKey = @"auth.oauth.refreshToken";

IX_STATIC_CONST_STRING kIXPaginationNextQueryParam = @"pagination.next.queryParam";// e.g. "cursor"; name of the query parameter to be appended to next API call
IX_STATIC_CONST_STRING kIXPaginationPrevQueryParam = @"pagination.prev.queryParam";// e.g. "cursor"; name of the query parameter to be appended to prev API call
IX_STATIC_CONST_STRING kIXPaginationNextPath = @"pagination.next.path"; // e.g. "meta.nextPage"; dot-notated key path where the next page pagination value can be found
IX_STATIC_CONST_STRING kIXPaginationPrevPath = @"pagination.prev.path"; // e.g. "meta.prevPage"; same as above, but for the previous page (optional)
IX_STATIC_CONST_STRING kIXPaginationAppendDataPath = @"pagination.appendData.path"; // dot-notated key path to data array
IX_STATIC_CONST_STRING kIXPaginationAppendData = @"pagination.appendData.enabled"; // default=false; determines whether the pagination results are appended to the current data set or replace it. If enabled, disables the "paginatePrev" function.
IX_STATIC_CONST_STRING kIXCacheEnabled = @"cache.enabled";
IX_STATIC_CONST_STRING kIXCachePolicy = @"cache.policy";

// IXBaseDataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXMethodGET = @"GET"; // kIXMethod
IX_STATIC_CONST_STRING kIXMethodPOST = @"POST"; // kIXMethod
IX_STATIC_CONST_STRING kIXMethodPUT = @"PUT"; // kIXMethod
IX_STATIC_CONST_STRING kIXMethodDELETE = @"DELETE"; // kIXMethod

//TODO: NOT IMPLEMENTED
IX_STATIC_CONST_STRING kIXSortOrderNone = @"none"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending"; // kIXSortOrder
//END TODO

IX_STATIC_CONST_STRING kIXRequestTypeForm = @"form"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXRequestTypeJSON = @"json"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXRequestTypeMultipart = @"multipart"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXResponseTypeJSON = @"json"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXResponseTypeHTML = @"html";

//TODO: binary data for multipart uploads and manually defining mime type, file etc.
//IX_STATIC_CONST_STRING kIXMultipartFilePath = @"attachment.path";
//IX_STATIC_CONST_STRING kIXMultipartFileData = @"attachment.data"; // must choose path OR data not both
//IX_STATIC_CONST_STRING kIXMultipartName = @"attachment.name";
//IX_STATIC_CONST_STRING kIXMultipartFilename = @"attachment.fileName";
//IX_STATIC_CONST_STRING kIXMultipartMimeType = @"attachment.mimeType";

IX_STATIC_CONST_STRING kIXMimeTypeOctetStream = @"application/octet-stream";


//TODO: NOT IMPLEMENTED
IX_STATIC_CONST_STRING kIXResponseTypeJPEG = @"jpeg"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXResponseTypePNG = @"png"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXResponseTypeGIF = @"gif"; // kIXBodyEncoding
//END TODO

IX_STATIC_CONST_STRING kIXCachePolicyDefault = @"reloadIgnoringLocalCache"; // Accepted Value Default
IX_STATIC_CONST_STRING kIXCachePolicyUseProtocolCachePolicy = @"useProtocolCachePolicy";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalCacheData = @"reloadIgnoringLocalCache";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalAndRemoteCacheData = @"reloadIgnoringLocalAndRemoteCache";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataElseLoad = @"useCacheElseLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataDontLoad = @"useCacheDontLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReloadRevalidatingCacheData = @"reloadRevalidatingCache";

// IXHTTPDataProvider Read-Only Properties
IX_STATIC_CONST_STRING kIXResponseTime = @"response.time";
IX_STATIC_CONST_STRING kIXResponseBodyPrefix = @"response.body"; // Prefix for parsed response. Reference objects like dsId.response.body.entities.0.uuid
IX_STATIC_CONST_STRING kIXResponseString = @"response.string";
IX_STATIC_CONST_STRING kIXResponseHeaders = @"response.headers";
IX_STATIC_CONST_STRING kIXStatusCode = @"response.code";
IX_STATIC_CONST_STRING kIXErrorMessage = @"response.error";

// IXHTTPDataProvider Functions
IX_STATIC_CONST_STRING kIXClearCache = @"clearCache"; // Clears the cached data that is associated with this data provider's url.
IX_STATIC_CONST_STRING kIXPaginateNext = @"paginateNext"; // also an event!
IX_STATIC_CONST_STRING kIXPaginatePrev = @"paginatePrev"; // also an event! | Disabled if data appending is enabled *note* this is a beginsWith
IX_STATIC_CONST_STRING kIXModifyDelete = @"delete"; // delete object at specified index. index is REQUIRED
IX_STATIC_CONST_STRING kIXModifyPush = @"push"; // add object to end of array
IX_STATIC_CONST_STRING kIXModifyPop = @"pop"; // remove last object (at end) of array
IX_STATIC_CONST_STRING kIXModifyInsert = @"insert"; // insert object at specified index. default=0
IX_STATIC_CONST_STRING kIXModifyData = @"data"; // push/insert data - automatically parsed as JSON object unless it is a single-level string/int/float/bool

// IXHTTPDataProvider Function Parameters
IX_STATIC_CONST_STRING kIXModifyIndex = @"index"; // index of object to be deleted or inserted
IX_STATIC_CONST_STRING kIXModifyPath = @"path"; // dot notated basepath to data array that will be modified

// IXHTTPDataProvider Events
IX_STATIC_CONST_STRING kIXUploadProgress = @"uploadProgress";
IX_STATIC_CONST_STRING kIXModifiedEvent = @"modified"; // response was modified with push, pop, insert or delete
// IX_STATIC_CONST_STRING kIXPaginateNext = @"paginateNext"; // also a function
// IX_STATIC_CONST_STRING kIXPaginatePrev = @"paginatePrev"; // also a function

static NSCache* sIXDataProviderCache = nil;


@interface IXHTTPDataProvider ()

@property (nonatomic,strong) NSString* requestBinUrl;

@property (nonatomic,strong) NSString* acceptedContentType;
@property (nonatomic,strong) NSString* requestType;
@property (nonatomic,strong) NSString* responseType;
//@property (nonatomic,copy) NSString* cacheID;
@property (nonatomic,strong) NSMutableSet* acceptedContentTypes;
@property (nonatomic,strong) NSDictionary* attachments;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic) double uploadProgress;

@end

// Internal header properties
IX_STATIC_CONST_STRING kIXAcceptHeaderKey = @"Accept";
IX_STATIC_CONST_STRING kIXContentTypeHeaderKey = @"Content-Type";
IX_STATIC_CONST_STRING kIXAcceptCharsetHeaderKey = @"Accept-Charset";

IX_STATIC_CONST_STRING kIXAcceptValueJSON = @"application/json"; // Accept header value
IX_STATIC_CONST_STRING kIXAcceptValueHTML = @"text/html"; // Accept header value
IX_STATIC_CONST_STRING kIXContentTypeValueJSON = @"application/json"; // Content-Type header value
IX_STATIC_CONST_STRING kIXContentTypeValueForm = @"application/x-www-form-urlencoded"; // Content-Type header value
IX_STATIC_CONST_STRING kIXAcceptCharsetValue = @"utf-8"; // Accept-Charset header type

// Internal constants
IX_STATIC_CONST_STRING KIXDataProviderCacheName = @"com.apigee.ignite.DataProviderCache";
IX_STATIC_CONST_STRING kIXRequestBinUrlPrefix = @"http://requestb.in";
IX_STATIC_CONST_STRING kIXLocationSuffixCache = @".cache";

@implementation IXHTTPDataProvider

+(void)initialize
{
    [super initialize];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIXDataProviderCache = [[NSCache alloc] init];
        [sIXDataProviderCache setName:KIXDataProviderCacheName];
    });
}

-(instancetype)init
{
    self = [super init];
    if ( self ) {
        _rowDataResultsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)applySettings
{

    [super applySettings];
    
    if (!_response) {
        _response = [IXHTTPResponse new];
    }
    
    [self setMethod:[[self attributeContainer] getStringValueForAttribute:kIXMethod defaultValue:kIXMethodGET]];
    [self setRequestType:[[self attributeContainer] getStringValueForAttribute:kIXRequestType defaultValue:kIXRequestTypeJSON]];
    [self setResponseType:[[self attributeContainer] getStringValueForAttribute:kIXResponseType defaultValue:kIXRequestTypeJSON]];

    [self setRequestBinUrl:[[self attributeContainer] getStringValueForAttribute:kIXDebugRequestBinUrl defaultValue:nil]];
    [self setCachePolicy:[self cachePolicyFromString:[[self attributeContainer] getStringValueForAttribute:kIXCachePolicy defaultValue:kIXCachePolicyDefault]]];
    [self setCacheResponse:[[self attributeContainer] getBoolValueForAttribute:kIXCacheEnabled defaultValue:YES]];

    // Pagination
    [self setAppendDataOnPaginate:[[self attributeContainer] getBoolValueForAttribute:kIXPaginationAppendData defaultValue:false]];
    [self setPaginationNextPath:[[self attributeContainer] getStringValueForAttribute:kIXPaginationNextPath defaultValue:nil]];
    [self setPaginationNextQueryParam:[[self attributeContainer] getStringValueForAttribute:kIXPaginationNextQueryParam defaultValue:nil]];
    [self setPaginationPrevPath:[[self attributeContainer] getStringValueForAttribute:kIXPaginationPrevPath defaultValue:nil]];
    [self setPaginationPrevQueryParam:[[self attributeContainer] getStringValueForAttribute:kIXPaginationPrevQueryParam defaultValue:nil]];
    [self setPaginationDataPath:[[self attributeContainer] getStringValueForAttribute:kIXPaginationAppendDataPath defaultValue:nil]];
    
    if( ![self isPathLocal] )
    {
        [self buildHTTPRequest];
    }
}

- (void)buildHTTPRequest
{
    [self setRequestType];
    [self setResponseType];
    [self setHeaders];
    [self setBasicAuth];
    [self configureCache];
    [self setAttachments:[NSMutableDictionary dictionaryWithDictionary:[self.fileAttachmentProperties getAllAttributesURLValues]]];
}

- (void)setRequestType {
    if ([_requestType isEqualToString:kIXRequestTypeJSON] && [self requestIsPostOrPut]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

- (void)setResponseType {
    // Currently only JSON response is supported
    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)setHeaders {
    
    // Set Content-Type
    if (![self.headersProperties attributeExistsForName:kIXContentTypeHeaderKey] &&
        ![self.headersProperties attributeExistsForName:[kIXContentTypeHeaderKey lowercaseString]]) {
        [self.headersProperties addAttribute:[IXAttribute attributeWithAttributeName:kIXContentTypeHeaderKey rawValue:[self contentTypeForRequestType]]];
    } else if ([self.requestType isEqualToString:kIXRequestTypeMultipart]) {
        [self.headersProperties removeAttributeNamed:kIXContentTypeHeaderKey];
    }
    // Set other headers
    [[self.headersProperties getAllAttributesAsDictionaryWithURLEncodedValues:NO] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        [[IXAFHTTPSessionManager sharedManager].requestSerializer setValue:value forHTTPHeaderField:key];
    }];
    
    if (_requestBinUrl != nil) {
        [IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes = [[IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes setByAddingObject:kIXAcceptValueHTML];
    }
}

- (void)setBasicAuth {
    NSString* username = [[self attributeContainer] getStringValueForAttribute:kIXBasicUserName defaultValue:nil];
    NSString* password = [[self attributeContainer] getStringValueForAttribute:kIXBasicPassword defaultValue:nil];
    if (username != nil && password != nil) {
        [[IXAFHTTPSessionManager sharedManager].requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    }
}

-(void)configureCache {
    [[IXAFHTTPSessionManager sharedManager].requestSerializer setCachePolicy:(self.shouldCacheResponse) ? _cachePolicy : NSURLRequestReloadIgnoringCacheData];
}

- (NSString*)contentTypeForRequestType {
    if ([self requestIsGetOrDelete]) {
        return kIXContentTypeValueForm;
    } else if ([_requestType isEqualToString:kIXRequestTypeJSON]) {
        return kIXContentTypeValueJSON;
    } else if ([_requestType isEqualToString:kIXRequestTypeForm]) {
        return kIXContentTypeValueForm;
    } else if ([_requestType isEqualToString:kIXRequestTypeMultipart]) {
        return nil; // We need to let AFHTTPSessionManager set the Content-Type header with boundary
    } else
        return kIXContentTypeValueJSON; // default for POST/PUT
}



-(void)GET:(NSString*)url completion:(LoadFinished)completion {
    [[IXAFHTTPSessionManager sharedManager] GET:url parameters:self.queryParams success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) completion(YES, task, responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) completion(NO, task, nil, error);
    }];
}

-(void)POST:(NSString*)url completion:(LoadFinished)completion {
    if ([_requestType isEqualToString:kIXRequestTypeMultipart]) {

        NSDictionary* attachmentsData = [IXAssetManager dataForAttachmentsDict:self.attachments];
        
        NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
        
        // Create a multipart form request.
        NSMutableURLRequest *multipartRequest = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:kIXMethodPOST
                                                                                                           URLString:self.url
                                                                                                          parameters:self.body constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                                 {
                                                     [_attachments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                         if ([obj isKindOfClass:[NSURL class]])
                                                         {
                                                             NSURL* url = [(NSURL*)obj copy];
                                                             // MIME type and file name are automatically detected here
                                                             if ([url isFileURL]) {
                                                                 [formData appendPartWithFileURL:url name:key error:nil];
                                                             } else if ([IXPathHandler pathIsAssetsLibrary:[url absoluteString]]) {
                                                                 NSString* queryString = [[[url absoluteString] componentsSeparatedByString:@"?"] lastObject];
                                                                 NSDictionary* queryParams = [NSDictionary ix_dictionaryFromQueryParamsString:queryString];
                                                                 NSString* ext = [queryParams[@"ext"] lowercaseString];
                                                                 NSString* fileName = [NSString stringWithFormat:@"%@.%@", key, ext];
                                                                 // May use this in the future? Leaving it here in case we need it.
                                                                 //                            NSInputStream* stream = [[NSInputStream alloc] initWithData:data];
                                                                 //                            [formData appendPartWithInputStream:stream name:key fileName:fileName length:[data length] mimeType:kIXMimeTypeOctetStream];
                                                                 NSString* mimeType = [attachmentsData objectForKey:key][@"mimeType"];
                                                                 [formData appendPartWithFileData:[attachmentsData objectForKey:key][@"data"] name:key fileName:fileName mimeType:mimeType];
                                                             }
                                                         }
                                                     }];

                                                     
                                                 } error:nil];
        [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:multipartRequest
                                                  writingStreamContentsToFile:tmpFileUrl
                                                            completionHandler:^(NSError *error) {
                                                                NSProgress *progress = nil;
                                                                __block NSURLSessionUploadTask *task = [[IXAFHTTPSessionManager sharedManager] uploadTaskWithRequest:multipartRequest
                                                                                                                           fromFile:tmpFileUrl
                                                                                                                           progress:&progress
                                                                                                                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                                                                      {
                                                                                                          // Cleanup: remove temporary file.
                                                                                                          [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                                                                          
                                                                                                          [progress removeObserver:self forKeyPath:kIXProgressKVOKey context:NULL];
                                                                                                          
                                                                                                          if (completion) completion((error == nil), task, responseObject, error);
                                                                                                      }];
                                                                
                                                                // Add the observer monitoring the upload progress.
                                                                [progress addObserver:self
                                                                           forKeyPath:kIXProgressKVOKey
                                                                              options:NSKeyValueObservingOptionNew
                                                                              context:NULL];
                                                                
                                                                // Start the file upload.
                                                                [task resume];
                                                            }];
    } else {
        [[IXAFHTTPSessionManager sharedManager] POST:url parameters:self.body success:^(NSURLSessionDataTask *task, id responseObject) {
            if (completion) completion(YES, task, responseObject, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) completion(NO, task, nil, error);
        }];
    }
}

-(void)PUT:(NSString*)url completion:(LoadFinished)completion {
    [[IXAFHTTPSessionManager sharedManager] PUT:self.url parameters:self.body success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(YES, task, responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(NO, task, nil, error);
    }];
}

-(void)DELETE:(NSString*)url completion:(LoadFinished)completion {
    [[IXAFHTTPSessionManager sharedManager] DELETE:self.url parameters:self.queryParams success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) completion(YES, task, responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) completion(NO, task, nil, error);
    }];
}

-(void)loadDataFromLocalPath {
    __weak typeof(IXHTTPResponse) *weakResponse = _response;
    [[IXDataLoader sharedDataLoader] loadJSONFromPath:self.url
                                                async:YES
                                          shouldCache:NO
                                           completion:^(id jsonObject, NSString* stringValue, NSError *error) {
                                               
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   
                                                   if( [NSJSONSerialization isValidJSONObject:jsonObject] )
                                                   {
                                                       [weakResponse setResponseString:stringValue];
                                                       [weakResponse setResponseObject:jsonObject];
                                                       IX_dispatch_main_sync_safe(^{
                                                           [self fireLoadFinishedEvents:YES];
                                                       });
                                                   }
                                                   else
                                                   {
                                                       [weakResponse setErrorMessage:[error localizedDescription]];
                                                       IX_dispatch_main_sync_safe(^{
                                                           [self fireLoadFinishedEvents:NO];
                                                       });
                                                   }
                                               });
                                           }];
}

-(void)loadData:(BOOL)forceGet paginationKey:(NSString *)paginationKey
{
    [super loadData:forceGet paginationKey:paginationKey];
    
    [self loadData:forceGet completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
        
        [_response setRequestEndTime:CFAbsoluteTimeGetCurrent()];
        
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        
        [_response setStatusCode:response.statusCode];
        [_response setHeaders:response.allHeaderFields];
        
        BOOL isValidJSON = [NSJSONSerialization isValidJSONObject:responseObject];
        
        if (error)
        {
            [_response setResponseObject:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]];
            [_response setResponseStringFromObject:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]];
            [_response setErrorMessage:error.localizedDescription];
            _paginationNextValue = nil;
            _paginationPrevValue = nil;
        }
        else
        {
            if (_appendDataOnPaginate && isValidJSON && [paginationKey isEqualToString:kIXPaginateNext]) {
                if (_paginationDataPath != nil) {
                    responseObject = [IXJSONUtils appendNewResponseObject:responseObject toPreviousResponseObject:_previousResponse.responseObject forDataPath:_paginationDataPath sandox:self.sandbox baseObject:self];
                } else {
                    IX_LOG_ERROR(@"%@ attribute is not defined; cannot append pagination data", kIXPaginationAppendDataPath);
                }
            }
            [_response setResponseObject:responseObject];
            [_response setResponseStringFromObject:responseObject];
            [self updatePaginationProperties];
        }
        
        [self fireLoadFinishedEvents:isValidJSON paginationKey:paginationKey];
    }];
}

-(void)loadData:(BOOL)forceGet completion:(LoadFinished)completion
{
    if (self.url != nil) {
        if (forceGet == NO)
        {
            [self fireLoadFinishedEvents:YES];
        }
        else if ([self isPathLocal])
        {
            [self loadDataFromLocalPath];
        }
        else
        {
            if ([self.method isEqualToString:kIXMethodGET]) {
                [self GET:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) {
                    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFHTTPResponseSerializer serializer];
                    [self GET:_requestBinUrl completion:nil];
                }
            } else if ([self.method isEqualToString:kIXMethodPOST]) {
                [self POST:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) {
                    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFHTTPResponseSerializer serializer];
                    [self POST:_requestBinUrl completion:nil];
                }
            } else if ([self.method isEqualToString:kIXMethodPUT]) {
                [self PUT:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) {
                    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFHTTPResponseSerializer serializer];
                    [self PUT:_requestBinUrl completion:nil];
                }
            } else if ([self.method isEqualToString:kIXMethodDELETE]) {
                [self DELETE:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) {
                    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFHTTPResponseSerializer serializer];
                    [self DELETE:_requestBinUrl completion:nil];
                }
            }
        }
    }
    else
    {
        IX_LOG_ERROR(@"ERROR: 'url' [%@] is %@; is 'url' defined in your datasource?", self.ID, self.url);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kIXProgressKVOKey]) {
        // Handle new fractionCompleted value
        NSProgress* progress = (NSProgress*)object;
        _uploadProgress = progress.fractionCompleted;
        [[self actionContainer] executeActionsForEventNamed:kIXUploadProgress];
        IX_LOG_DEBUG(@"Upload percent complete: %f", progress.fractionCompleted);
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}


-(void)updatePaginationProperties {
    NSDictionary* objectsStringValues = [[IXAttributeContainer attributeContainerWithJSONDict:_response.responseObject] getAllAttributesAsDictionaryWithDotNotationAndURLEncodedValues:NO];
    _paginationNextValue = nil;
    _paginationPrevValue = nil;
    if (_paginationNextPath && _paginationNextQueryParam && [objectsStringValues objectForKey:_paginationNextPath]) {
        _paginationNextValue = [objectsStringValues objectForKey:_paginationNextPath];
        NSMutableDictionary* newQueryParams = [self.queryParams mutableCopy];
        [newQueryParams setValue:_paginationNextValue forKey:_paginationNextQueryParam];
        self.queryParams = newQueryParams;
    }
    if (_paginationPrevPath && _paginationPrevQueryParam && [objectsStringValues objectForKey:_paginationPrevPath]) {
        _paginationPrevValue = [objectsStringValues objectForKey:_paginationPrevPath];
        NSMutableDictionary* newQueryParams = [self.queryParams mutableCopy];
        [newQueryParams setValue:_paginationPrevValue forKey:_paginationPrevQueryParam];
        self.queryParams = newQueryParams;
    }
}

-(BOOL)requestIsPostOrPut
{
    return ([self.method isEqualToString:kIXMethodPOST] || [self.method isEqualToString:kIXMethodPUT]);
}

-(BOOL)requestIsGetOrDelete
{
    return ([self.method isEqualToString:kIXMethodGET] || [self.method isEqualToString:kIXMethodDELETE]);
}


+(BOOL)cacheExistsForURL:(NSString*)url {
    NSURLCache* cache =[NSURLCache sharedURLCache];
    
    // Choose a long cached URL.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    // Check the cache.
    NSCachedURLResponse *cachedResponse = [cache cachedResponseForRequest:request];
    return (cachedResponse != nil);
}

+(void)clearCacheForURL:(NSString*)url
{
    NSURLCache* cache =[NSURLCache sharedURLCache];
    
    // Choose a long cached URL.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    // Check the cache.
    NSCachedURLResponse *cachedResponse = [cache cachedResponseForRequest:request];

    if (cachedResponse) {
        [cache storeCachedResponse:nil forRequest:request];
        [NSURLCache setSharedURLCache:cache];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue;
    if( [propertyName isEqualToString:kIXResponseString] )
    {
        returnValue = [_response.responseString copy];
    }
    else if ([propertyName hasPrefix:kIXResponseHeaders]) {
        NSString* headerKey = [[propertyName componentsSeparatedByString:kIX_PERIOD_SEPERATOR] lastObject];
        @try {
            returnValue = _response.headers[headerKey];
            if (!returnValue) {
                returnValue = _response.headers[[headerKey lowercaseString]]; // try again with lowercase?
            }
        }
        @catch (NSException *exception) {
            DDLogDebug(@"No header value named '%@' exists in response object", headerKey);
        }
    }
    else if ([propertyName hasPrefix:kIXResponseTime]) {
        returnValue = [NSString stringWithFormat: @"%0.f", _response.responseTime];
    }
    else if( [propertyName isEqualToString:kIXStatusCode] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)_response.statusCode];
    }
    else if( [propertyName isEqualToString:kIXErrorMessage] )
    {
        returnValue = [_response.errorMessage copy];
    }
    else if ( [propertyName isEqualToString:kIXUploadProgress])
    {
        returnValue = [NSString stringWithFormat:@"%lf", _uploadProgress];
    }
    else if ([propertyName hasPrefix:kIXResponseBodyPrefix]) {
        NSString* prefix = [NSString stringWithFormat:@"%@%@", kIXResponseBodyPrefix, kIX_PERIOD_SEPERATOR];
        propertyName = [propertyName stringByReplacingOccurrencesOfString:prefix withString:kIX_EMPTY_STRING];
        returnValue = [self stringForPath:propertyName container:_response.responseObject];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed paginationKey:(NSString*)paginationKey
{
    
    if( loadDidSucceed )
    {
        [self updateDataRowData];
        
        if ([paginationKey isEqualToString:kIXPaginateNext]) {
            [[self actionContainer] executeActionsForEventNamed:kIXPaginateNext];
        } else if ([paginationKey isEqualToString:kIXPaginatePrev]) {
            [[self actionContainer] executeActionsForEventNamed:kIXPaginatePrev];
        }
    }
    if ([IXHTTPDataProvider cacheExistsForURL:self.url]) {
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",(loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED,kIXLocationSuffixCache]];
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_DONE,kIXLocationSuffixCache]];
    }
    [super fireLoadFinishedEvents:loadDidSucceed paginationKey:paginationKey];

}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXClearCache] )
    {
        [IXHTTPDataProvider clearCacheForURL:self.url];
    }
    else if( [functionName hasPrefix:kIXPaginateNext] )
    {
        [self.queryParams setValue:_paginationNextValue forKey:_paginationNextQueryParam];
        if (_paginationNextValue != nil && _paginationNextValue != kIX_EMPTY_STRING) {
            if (_appendDataOnPaginate) {
                _previousResponse = _response;
            }
            [self loadData:YES paginationKey:kIXPaginateNext];
        } else {
            IX_LOG_DEBUG(@"Could not paginate next - either pagination is complete or path is invalid");
        }
    }
    else if( [functionName hasPrefix:kIXPaginatePrev] )
    {
        // if append data on paginate is enabled, we don't want to allow this function to fire otherwise data will be overwritten.
        if (!_appendDataOnPaginate) {
            // if append data on paginate is enabled, we don't want to allow this function to fire otherwise data will be overwritten.
            [self.queryParams setValue:_paginationPrevValue forKey:_paginationPrevQueryParam];
            if (_paginationPrevValue != nil && _paginationPrevValue != kIX_EMPTY_STRING) {
                [self loadData:YES paginationKey:kIXPaginatePrev];
            } else {
                IX_LOG_DEBUG(@"Could not paginate previous - either pagination is complete or path is invalid");
            }
        } else {
            IX_LOG_ERROR(@"Could not paginate previous - data appending is enabled via %@", kIXPaginationAppendData);
        }
    }
    else if([functionName isEqualToString:kIXModifyPush] ||
            [functionName isEqualToString:kIXModifyPop] ||
            [functionName isEqualToString:kIXModifyDelete] ||
            [functionName isEqualToString:kIXModifyInsert])
    {
        [self modifyResponseForFunctionNamed:functionName withParameters:parameterContainer];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

// TODO: This is a bit of a bastardized approach. We should have a separate class for handling offline data manipulation that HTTP can leverage.
- (void)modifyResponseForFunctionNamed:(NSString*)functionName withParameters:(IXAttributeContainer *)parameterContainer {

    BOOL wasModified = NO;
    NSDictionary* paramsDict = [parameterContainer getAllAttributesAsDictionary];
    id newData = ([paramsDict valueForKey:kIXModifyData]) ?: nil;
    NSMutableDictionary* modifiedResponseObject = [NSMutableDictionary dictionary];
    // Get existing data
    NSString* existingDataPath = [parameterContainer getStringValueForAttribute:kIXModifyPath defaultValue:nil];
    NSString* index = [parameterContainer getStringValueForAttribute:kIXModifyIndex defaultValue:nil];
    id existingDataArray = [[IXJSONUtils objectForPath:existingDataPath container:_response.responseObject sandox:self.sandbox baseObject:self] mutableCopy];
    
    
    if (newData != nil && ([functionName isEqualToString:kIXModifyPush] || [functionName isEqualToString:kIXModifyInsert])) {
        // newData is legit. We can do push and insert.
        if (existingDataArray == nil) {
            existingDataArray = [NSMutableArray array];
        }
        if ([existingDataArray isKindOfClass:[NSMutableArray class]]) {
            if ([functionName isEqualToString:kIXModifyPush]) {
                // Currently only adding a single object at a time is supported.
// TODO: support adding multiple objects at once from a JSON array
                [existingDataArray addObject:newData];
                [modifiedResponseObject setValue:existingDataArray forKeyPath:existingDataPath];
                wasModified = YES;
            } else if ([functionName isEqualToString:kIXModifyInsert]) {
                // If index is defined, insert there, otherwise at position 0
                NSInteger idx = (index) ? [index integerValue] : 0;
                // Safeguard so we don't try and insert out of array bounds
                idx = (idx > [existingDataArray count]) ? [existingDataArray count] : idx;
                [existingDataArray insertObject:newData atIndex:idx];
                [modifiedResponseObject setValue:existingDataArray forKeyPath:existingDataPath];
                wasModified = YES;
            }
        }
    }
    if (newData == nil && ([functionName isEqualToString:kIXModifyPop] || [functionName isEqualToString:kIXModifyDelete])) {
        if ([existingDataArray isKindOfClass:[NSMutableArray class]]) {
            // newData is nil but existingDataArray is legit. We can do pop and delete.
            if ([functionName isEqualToString:kIXModifyPop]) {
                if ([existingDataArray count] > 0) {
                    [existingDataArray removeLastObject];
                    [modifiedResponseObject setValue:existingDataArray forKeyPath:existingDataPath];
                    wasModified = YES;
                } else {
                    DDLogError(@"Could not %@ last object because the array length is 0", kIXModifyPop);
                }
            } else if ([functionName isEqualToString:kIXModifyDelete]) {
                if (index != nil) {
                    NSInteger idx = [index integerValue];
                    if (idx > [existingDataArray count]) {
                        DDLogError(@"Could not %@ object; '%@' function parameter is out of bounds", kIXModifyDelete, kIXModifyIndex);
                    } else {
                        [existingDataArray removeObjectAtIndex:idx];
                        [modifiedResponseObject setValue:existingDataArray forKeyPath:existingDataPath];
                        wasModified = YES;
                    }
                } else {
                    DDLogError(@"The '%@' function parameter is required when using the '%@' function", kIXModifyIndex, kIXModifyDelete);
                }
            }
        }
    }
    if (wasModified) {
        [_response setResponseObject:modifiedResponseObject];
        [_response setResponseStringFromObject:modifiedResponseObject];
        
        
        [self updateDataRowData];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                                object:self];
        });
        [[self actionContainer] executeActionsForEventNamed:kIXModifiedEvent];
    }

// TODO: re-implement predicate filtering:
    
//        NSString* modifyResponseType = [parameterContainer getStringPropertyValue:kIXModifyType defaultValue:nil];
//        if( [modifyResponseType length] > 0 )
//        {
//            NSString* topLevelContainerPath = [parameterContainer getStringPropertyValue:kIXTopLevelContainer defaultValue:nil];
//            id topLevelContainer = [IXJSONUtils objectForPath:topLevelContainerPath container:_response.responseObject sandox:self.sandbox baseObject:self];
//
//            if( [topLevelContainer isKindOfClass:[NSMutableArray class]] )
//            {
//                NSMutableArray* topLevelArray = (NSMutableArray*) topLevelContainer;
//
//                if( [modifyResponseType isEqualToString:kIXDelete] )
//                {
//                    NSString* predicateFormat = [parameterContainer getStringPropertyValue:kIXPredicateFormat defaultValue:nil];
//                    NSArray* predicateArgumentsArray = [parameterContainer getCommaSeparatedArrayListValue:kIXPredicateArguments defaultValue:nil];
//
//                    if( [predicateFormat length] > 0 && [predicateArgumentsArray count] > 0 )
//                    {
//                        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArgumentsArray];
//                        if( predicate != nil )
//                        {
//                            NSArray* filteredArray = [topLevelContainer filteredArrayUsingPredicate:predicate];
//                            [topLevelArray removeObjectsInArray:filteredArray];
//                        }
//                    }
//                }
//                else if( [modifyResponseType isEqualToString:kIXAppend] )
//                {
//                    id jsonToAppendObject = nil;
//                }
//            }
//        }
}

- (void)updateDataRowData {
    NSString* dataRowBasePath = [self dataRowBasePath];
    [self calculateAndStoreDataRowResultsForDataRowPath:dataRowBasePath];
    
    for( NSString* dataRowKey in [[self rowDataResultsDict] allKeys] )
    {
        if( ![dataRowKey isEqualToString:dataRowBasePath] )
        {
            [self calculateAndStoreDataRowResultsForDataRowPath:dataRowKey];
        }
    }
}

- (NSURLRequestCachePolicy)cachePolicyFromString:(NSString*)policy {
    NSURLRequestCachePolicy returnPolicy;
    if ([policy isEqualToString:kIXCachePolicyDefault]) {
        returnPolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    else if ([policy isEqualToString:kIXCachePolicyUseProtocolCachePolicy]) {
        returnPolicy = NSURLRequestUseProtocolCachePolicy;
    }
    else if ([policy isEqualToString:kIXCachePolicyReloadIgnoringLocalCacheData]) {
        returnPolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    else if ([policy isEqualToString:kIXCachePolicyReloadIgnoringLocalAndRemoteCacheData]) {
        returnPolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    else if ([policy isEqualToString:kIXCachePolicyReturnCacheDataElseLoad]) {
        returnPolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    else if ([policy isEqualToString:kIXCachePolicyReturnCacheDataDontLoad]) {
        returnPolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    else if ([policy isEqualToString:kIXCachePolicyReloadRevalidatingCacheData]) {
        returnPolicy = NSURLRequestReloadRevalidatingCacheData;
    }
    else {
        returnPolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    return returnPolicy;
}

-(void)calculateAndStoreDataRowResultsForDataRowPath:(NSString*)dataRowPath
{
    NSObject* jsonObject = nil;
    if( [dataRowPath length] <= 0 && [[_response responseObject] isKindOfClass:[NSArray class]] )
    {
        jsonObject = [_response responseObject];
    }
    else
    {
        jsonObject = [IXJSONUtils objectForPath:dataRowPath container:_response.responseObject sandox:self.sandbox baseObject:self];
    }
    
    NSArray* rowDataResults = nil;
    if( [jsonObject isKindOfClass:[NSArray class]] )
    {
        rowDataResults = (NSArray*)jsonObject;
    }
    if( rowDataResults )
    {
        NSPredicate* predicate = [self predicate];
        if( predicate )
        {
            rowDataResults = [rowDataResults filteredArrayUsingPredicate:predicate];
        }
        NSSortDescriptor* sortDescriptor = [self sortDescriptor];
        if( sortDescriptor )
        {
            rowDataResults = [rowDataResults sortedArrayUsingDescriptors:@[sortDescriptor]];
        }
    }
    
    if( [dataRowPath length] && rowDataResults != nil )
    {
        [[self rowDataResultsDict] setObject:rowDataResults forKey:dataRowPath];
    }
}

-(NSString*)rowDataRawStringResponse
{
    NSString* returnValue = nil;
    NSArray* results = [self rowDataResultsDict][[self dataRowBasePath]];
    if( [results count] > 0 )
    {
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:results
                                                           options:0
                                                             error:&error];
        if( [jsonData length] > 0 && error == nil )
        {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            returnValue = jsonString;
        }
    }
    return returnValue;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath dataRowBasePath:(NSString*)dataRowBasePath
{
    if( [dataRowBasePath length] <= 0 )
    {
        dataRowBasePath = [self dataRowBasePath];
    }

    NSString* returnValue = [super rowDataForIndexPath:rowIndexPath keyPath:keyPath dataRowBasePath:dataRowBasePath];
    if( keyPath && rowIndexPath )
    {
        NSArray* dataRowContainer = [self rowDataResultsDict][dataRowBasePath];

        if( dataRowContainer != nil )
        {
            NSString* jsonKeyPath = [NSString stringWithFormat:@"%li.%@",(long)rowIndexPath.row,keyPath];
            returnValue = [self stringForPath:jsonKeyPath container:dataRowContainer];
        }
    }
    return returnValue;
}

-(NSUInteger)rowCount:(NSString *)dataRowBasePath
{
    if( [dataRowBasePath length] <= 0 )
    {
        dataRowBasePath = [self dataRowBasePath];
    }

    if( [self rowDataResultsDict][dataRowBasePath] == nil )
    {
        [self calculateAndStoreDataRowResultsForDataRowPath:dataRowBasePath];
    }

    return [[self rowDataResultsDict][dataRowBasePath] count];
}

-(NSString*)stringForPath:(NSString*)jsonXPath container:(NSObject*)container
{
    NSString* returnValue = nil;
    NSObject* jsonObject = [IXJSONUtils objectForPath:jsonXPath container:container sandox:self.sandbox baseObject:self];
    if( jsonObject )
    {
        if( [jsonObject isKindOfClass:[NSString class]] ) {
            returnValue = (NSString*)jsonObject;
        } else if( [jsonObject isKindOfClass:[NSNumber class]] ) {
            returnValue = [((NSNumber*)jsonObject) stringValue];
        } else if( [jsonObject isKindOfClass:[NSNull class]] ) {
            returnValue = nil;
        } else if( [NSJSONSerialization isValidJSONObject:jsonObject] ) {
            
            NSError* __autoreleasing jsonConvertError = nil;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&jsonConvertError];
            
            if( jsonConvertError == nil && jsonData ) {
                returnValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            } else {
                IX_LOG_WARN(@"WARNING from %@ in %@: Error Converting JSON object: %@",THIS_FILE,THIS_METHOD,[jsonConvertError description]);
            }
        } else {
            IX_LOG_WARN(@"WARNING from %@ in %@: Invalid JSON Object: %@",THIS_FILE,THIS_METHOD,[jsonObject description]);
        }
    }
    return returnValue;
}

@end