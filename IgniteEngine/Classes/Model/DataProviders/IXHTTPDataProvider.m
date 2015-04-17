//
//  IXHTTPDataProvider.m
//  Ignite Engine
//
//  Created by Brandon Shelley on 4/7/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
#import "IXProperty.h"
#import "IXAssetManager.h"
#import "IXPathHandler.h"
#import "IXJSONUtils.h"

// TODO: Clean up naming and document
IX_STATIC_CONST_STRING kIXModifyResponse = @"modify_response";
IX_STATIC_CONST_STRING kIXModifyType = @"modify.type";
IX_STATIC_CONST_STRING kIXDelete = @"delete";
IX_STATIC_CONST_STRING kIXAppend = @"append";

IX_STATIC_CONST_STRING kIXTopLevelContainer = @"top_level_container";

IX_STATIC_CONST_STRING kIXPredicateFormat = @"predicate.format";            //e.g. "%K CONTAINS[c] %@"
IX_STATIC_CONST_STRING kIXPredicateArguments = @"predicate.arguments";      //e.g. "email,[[inputbox.text]]"

IX_STATIC_CONST_STRING kIXJSONToAppend = @"json_to_append";
//IX_STATIC_CONST_STRING kIXParseJSONAsObject = @"parse_json_as_object";

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
IX_STATIC_CONST_STRING kIXOAuthToken = @"auth.oauth.accessToken";
IX_STATIC_CONST_STRING kIXOAuthTokenKey = @"auth.oauth.refreshToken";

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

IX_STATIC_CONST_STRING kIXSortOrderNone = @"none"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending"; // kIXSortOrder

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
IX_STATIC_CONST_STRING kIXResponseBodyPrefix = @"response.body";
IX_STATIC_CONST_STRING kIXResponseString = @"response.string";
IX_STATIC_CONST_STRING kIXResponseHeaders = @"response.headers";
IX_STATIC_CONST_STRING kIXStatusCode = @"response.code";
IX_STATIC_CONST_STRING kIXErrorMessage = @"response.error";

// IXHTTPDataProvider Functions
IX_STATIC_CONST_STRING kIXClearCache = @"clearCache"; // Clears the cached data that is associated with this data provider's url.
IX_STATIC_CONST_STRING kIXPaginateNext = @"paginateNext"; // also an event!
IX_STATIC_CONST_STRING kIXPaginatePrev = @"paginatePrev"; // also an event! | Disabled if data appending is enabled *note* this is a beginsWith

// IXHTTPDataProvider Events
IX_STATIC_CONST_STRING kIXUploadProgress = @"uploadProgress";
// IX_STATIC_CONST_STRING kIXPaginateNext = @"paginateNext"; // also a function
// IX_STATIC_CONST_STRING kIXPaginatePrev = @"paginatePrev"; // also a function

static NSCache* sIXDataProviderCache = nil;


@interface IXHTTPDataProvider ()

@property (nonatomic,strong) NSString* requestBinUrl;

@property (nonatomic,strong) NSString* acceptedContentType;
@property (nonatomic,strong) NSString* requestType;
@property (nonatomic,strong) NSString* responseType;
//@property (nonatomic,copy) NSString* cacheID;
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
IX_STATIC_CONST_STRING kIXLocationSuffixCache = @".cache";
IX_STATIC_CONST_STRING kIXLocationSuffixRemote = @".remote";
IX_STATIC_CONST_STRING kIXProgressKVOKey = @"fractionCompleted";

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
    
    [self setMethod:[[self propertyContainer] getStringPropertyValue:kIXMethod defaultValue:kIXMethodGET]];
    [self setRequestType:[[self propertyContainer] getStringPropertyValue:kIXRequestType defaultValue:kIXRequestTypeJSON]];
    [self setResponseType:[[self propertyContainer] getStringPropertyValue:kIXResponseType defaultValue:kIXRequestTypeJSON]];

    [self setRequestBinUrl:[[self propertyContainer] getStringPropertyValue:kIXDebugRequestBinUrl defaultValue:nil]];
    [self setCachePolicy:[self cachePolicyFromString:[[self propertyContainer] getStringPropertyValue:kIXCachePolicy defaultValue:kIXCachePolicyDefault]]];
    [self setCacheResponse:[[self propertyContainer] getBoolPropertyValue:kIXCacheEnabled defaultValue:YES]];

    // Pagination
    [self setAppendDataOnPaginate:[[self propertyContainer] getBoolPropertyValue:kIXPaginationAppendData defaultValue:false]];
    [self setPaginationNextPath:[[self propertyContainer] getStringPropertyValue:kIXPaginationNextPath defaultValue:nil]];
    [self setPaginationNextQueryParam:[[self propertyContainer] getStringPropertyValue:kIXPaginationNextQueryParam defaultValue:nil]];
    [self setPaginationPrevPath:[[self propertyContainer] getStringPropertyValue:kIXPaginationPrevPath defaultValue:nil]];
    [self setPaginationPrevQueryParam:[[self propertyContainer] getStringPropertyValue:kIXPaginationPrevQueryParam defaultValue:nil]];
    [self setPaginationDataPath:[[self propertyContainer] getStringPropertyValue:kIXPaginationAppendDataPath defaultValue:nil]];
    
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
    [self setAttachments:[NSMutableDictionary dictionaryWithDictionary:[self.fileAttachmentProperties getAllPropertiesURLValues]]];
}

- (void)setRequestType {
    if ([_requestType isEqualToString:kIXRequestTypeJSON]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFJSONRequestSerializer serializer];
    } else if ([_requestType isEqualToString:kIXRequestTypeForm]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

- (void)setResponseType {
    // Currently only JSON response is supported
    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)setHeaders {
    
    // Set Content-Type
    if (![self.headersProperties propertyExistsForPropertyNamed:kIXContentTypeHeaderKey] &&
        ![self.headersProperties propertyExistsForPropertyNamed:[kIXContentTypeHeaderKey lowercaseString]]) {
        [self.headersProperties addProperty:[IXProperty propertyWithPropertyName:kIXContentTypeHeaderKey rawValue:[self contentTypeForRequestType]]];
    } else if ([self.requestType isEqualToString:kIXRequestTypeMultipart]) {
        [self.headersProperties removePropertyNamed:kIXContentTypeHeaderKey];
    }
    // Set Accept
    NSString* acceptContentType;
    if (![self.headersProperties propertyExistsForPropertyNamed:kIXAcceptHeaderKey] &&
        ![self.headersProperties propertyExistsForPropertyNamed:[kIXAcceptHeaderKey lowercaseString]]) {
        
        if ([_responseType isEqualToString:kIXResponseTypeJSON]) {
            acceptContentType = kIXAcceptValueJSON;
        } else if ([_responseType isEqualToString:kIXResponseTypeHTML]) {
            acceptContentType = kIXAcceptValueHTML;
        }
        // Add additional accept header options here
        [self.headersProperties addProperty:[IXProperty propertyWithPropertyName:kIXAcceptHeaderKey rawValue:acceptContentType]];
        
    } else {
        acceptContentType = [self.headersProperties getStringPropertyValue:kIXAcceptHeaderKey defaultValue:nil] ?: [self.headersProperties getStringPropertyValue:[kIXAcceptHeaderKey lowercaseString] defaultValue:nil];
    }
    if (acceptContentType != nil) {
        [IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes = [NSSet setWithObject:acceptContentType];
    }
    
    // Set Accept-Encoding
    if (![self.headersProperties propertyExistsForPropertyNamed:kIXAcceptCharsetHeaderKey] &&
        ![self.headersProperties propertyExistsForPropertyNamed:[kIXAcceptCharsetHeaderKey lowercaseString]]) {
        [self.headersProperties addProperty:[IXProperty propertyWithPropertyName:kIXAcceptCharsetHeaderKey rawValue:kIXAcceptCharsetValue]];
    }
    
    // Set other headers
    [[self.headersProperties getAllPropertiesObjectValues:NO] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        [[IXAFHTTPSessionManager sharedManager].requestSerializer setValue:value forHTTPHeaderField:key];
    }];
}

- (void)setBasicAuth {
    NSString* username = [[self propertyContainer] getStringPropertyValue:kIXBasicUserName defaultValue:nil];
    NSString* password = [[self propertyContainer] getStringPropertyValue:kIXBasicPassword defaultValue:nil];
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
                                                           [self fireLoadFinishedEvents:YES paginationKey:nil];
                                                       });
                                                   }
                                                   else
                                                   {
                                                       [weakResponse setErrorMessage:[error localizedDescription]];
                                                       IX_dispatch_main_sync_safe(^{
                                                           [self fireLoadFinishedEvents:NO paginationKey:nil];
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
            [self fireLoadFinishedEvents:YES paginationKey:nil];
        }
        else if ([self isPathLocal])
        {
            [self loadDataFromLocalPath];
        }
        else
        {
            _response = [IXHTTPResponse new];
            
            if ([self.method isEqualToString:kIXMethodGET]) {
                [self GET:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) [self GET:_requestBinUrl completion:nil];
            } else if ([self.method isEqualToString:kIXMethodPOST]) {
                [self POST:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) [self POST:_requestBinUrl completion:nil];
            } else if ([self.method isEqualToString:kIXMethodPUT]) {
                [self PUT:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) [self PUT:_requestBinUrl completion:nil];
            } else if ([self.method isEqualToString:kIXMethodDELETE]) {
                [self DELETE:self.url completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
                    completion(success, task, responseObject, error);
                }];
                if (_requestBinUrl) [self DELETE:_requestBinUrl completion:nil];
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
    NSDictionary* objectsStringValues = [[IXPropertyContainer propertyContainerWithJSONDict:_response.responseObject] getAllPropertiesStringValues:NO];
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
    //    [sIXDataProviderCache removeAllObjects];
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
    
    NSString* locationSpecificEventSuffix = ([IXHTTPDataProvider cacheExistsForURL:self.url]) ? kIXLocationSuffixCache : kIXLocationSuffixRemote;
    
    if( loadDidSucceed )
    {
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
    
    if ([paginationKey isEqualToString:kIXPaginateNext]) {
        [[self actionContainer] executeActionsForEventNamed:kIXPaginateNext];
    } else if ([paginationKey isEqualToString:kIXPaginatePrev]) {
        [[self actionContainer] executeActionsForEventNamed:kIXPaginatePrev];
    }
    
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",(loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED,locationSpecificEventSuffix]];
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_DONE,locationSpecificEventSuffix]];
    
    [super fireLoadFinishedEvents:loadDidSucceed paginationKey:paginationKey];

}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
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
    else if( [functionName isEqualToString:kIXModifyResponse] )
    {
        NSString* modifyResponseType = [parameterContainer getStringPropertyValue:kIXModifyType defaultValue:nil];
        if( [modifyResponseType length] > 0 )
        {
            NSString* topLevelContainerPath = [parameterContainer getStringPropertyValue:kIXTopLevelContainer defaultValue:nil];
            id topLevelContainer = [IXJSONUtils objectForPath:topLevelContainerPath container:_response.responseObject sandox:self.sandbox baseObject:self];

            if( [topLevelContainer isKindOfClass:[NSMutableArray class]] )
            {
                NSMutableArray* topLevelArray = (NSMutableArray*) topLevelContainer;

                if( [modifyResponseType isEqualToString:kIXDelete] )
                {
                    NSString* predicateFormat = [parameterContainer getStringPropertyValue:kIXPredicateFormat defaultValue:nil];
                    NSArray* predicateArgumentsArray = [parameterContainer getCommaSeperatedArrayListValue:kIXPredicateArguments defaultValue:nil];

                    if( [predicateFormat length] > 0 && [predicateArgumentsArray count] > 0 )
                    {
                        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArgumentsArray];
                        if( predicate != nil )
                        {
                            NSArray* filteredArray = [topLevelContainer filteredArrayUsingPredicate:predicate];
                            [topLevelArray removeObjectsInArray:filteredArray];
                        }
                    }
                }
                else if( [modifyResponseType isEqualToString:kIXAppend] )
                {
                    id jsonToAppendObject = nil;
                }
            }
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
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
                IX_LOG_WARN(@"WARNING from %@ in %@ : Error Converting JSON object : %@",THIS_FILE,THIS_METHOD,[jsonConvertError description]);
            }
        } else {
            IX_LOG_WARN(@"WARNING from %@ in %@ : Invalid JSON Object : %@",THIS_FILE,THIS_METHOD,[jsonObject description]);
        }
    }
    return returnValue;
}

//-(NSString*)getQueryValueOutOfValue:(NSString*)value
//{
//    NSString* returnValue = value;
//    NSArray* seperatedValue = [value componentsSeparatedByString:@"?"];
//    if( [seperatedValue count] > 0 )
//    {
//        NSString* objectID = [seperatedValue firstObject];
//        NSString* propertyName = [seperatedValue lastObject];
//        if( [objectID isEqualToString:kIXSessionRef] )
//        {
//            returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringPropertyValue:propertyName defaultValue:value];
//        }
//        else if( [objectID isEqualToString:kIXAppRef] )
//        {
//            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:propertyName defaultValue:value];
//        }
//        else if( [objectID isEqualToString:kIXViewControlRef] )
//        {
//            returnValue = [[[self sandbox] viewController] getViewPropertyNamed:propertyName];
//            if( returnValue == nil )
//            {
//                returnValue = value;
//            }
//        }
//        else
//        {
//            NSArray* objectWithIDArray = [[self sandbox] getAllControlsAndDataProvidersWithID:objectID withSelfObject:self];
//            IXBaseObject* baseObject = [objectWithIDArray firstObject];
//
//            if( baseObject )
//            {
//                returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
//                if( returnValue == nil )
//                {
//                    returnValue = [[baseObject propertyContainer] getStringPropertyValue:propertyName defaultValue:value];
//                }
//            }
//        }
//    }
//    return returnValue;
//}

//- (NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*) currentNode
//{
//    if (currentNode == nil) {
//        return nil;
//    }
//    
//    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
//        return currentNode;
//    }
//    if ([jsonXPath hasPrefix:kIX_PERIOD_SEPERATOR]) {
//        jsonXPath = [jsonXPath substringFromIndex:1];
//    }
//    
//    NSString *currentKey = [[jsonXPath componentsSeparatedByString:kIX_PERIOD_SEPERATOR] firstObject];
//    NSObject *nextNode;
//    // if dict -> get value
//    if ([currentNode isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *currentDict = (NSDictionary *) currentNode;
//        nextNode = currentDict[jsonXPath];
//        if( nextNode != nil )
//        {
//            return nextNode;
//        }
//        else
//        {
//            nextNode = currentDict[currentKey];
//        }
//    }
//    
//    if ([currentNode isKindOfClass:[NSArray class]]) {
//        NSArray * currentArray = (NSArray *) currentNode;
//        @try {
//            if( [currentKey containsString:@"="] ) // current key is actually looking to filter array if theres an '=' character
//            {
//                NSArray* currentKeySeperated = [currentKey componentsSeparatedByString:@"="];
//                if( [currentKeySeperated count] > 1 ) {
//                    NSString* currentKeyValue = [currentKeySeperated lastObject];
//                    if( [currentKeyValue rangeOfString:@"?"].location != NSNotFound )
//                    {
//                        currentKeyValue = [self getQueryValueOutOfValue:currentKeyValue];
//                    }
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(%K == %@)",[currentKeySeperated firstObject],currentKeyValue];
//                    NSArray* filteredArray = [currentArray filteredArrayUsingPredicate:predicate];
//                    if( [filteredArray count] >= 1 ) {
//                        if( [filteredArray count] == 1 ) {
//                            nextNode = [filteredArray firstObject];
//                        } else {
//                            nextNode = filteredArray;
//                        }
//                    }
//                }
//            }
//            else // current key must be an number
//            {
//                if( [currentKey isEqualToString:@"$count"] || [currentKey isEqualToString:@".$count"] )
//                {
//                    return [NSString stringWithFormat:@"%lu",(unsigned long)[currentArray count]];
//                }
//                else if ([currentArray count] > 0)
//                {
//                    nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
//                }
//                else
//                {
//                    @throw [NSException exceptionWithName:@"NSRangeException"
//                                                   reason:@"Specified array index is out of bounds"
//                                                 userInfo:nil];
//                }
//            }
//        }
//        @catch (NSException *exception) {
//            IX_LOG_ERROR(@"ERROR : %@ Exception in %@ : %@; attempted to retrieve index %@ from %@",THIS_FILE,THIS_METHOD,exception,currentKey, jsonXPath);
//        }
//    }
//    
//    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:kIX_EMPTY_STRING];
//    if( nextXPath.length <= 0 )
//    {
//        return nextNode;
//    }
//    // call recursively with the new xpath and the new Node
//    return [self objectForPath:nextXPath container: nextNode];
//}

@end