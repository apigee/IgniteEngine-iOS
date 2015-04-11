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
//IX_STATIC_CONST_STRING kIXParseResponse = @"parseResponse.enabled"; // parses response or leaves it as a string

IX_STATIC_CONST_STRING kIXDebugRequestBinUrl = @"debug.requestBinUrl";

IX_STATIC_CONST_STRING kIXBasicUserName = @"auth.basic.username";
IX_STATIC_CONST_STRING kIXBasicPassword = @"auth.basic.password";

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
// TODO: implement JSON to XML conversion for POST/PUTting XML
IX_STATIC_CONST_STRING kIXRequestTypeXML = @"xml"; // kIXBodyEncoding - currently not supported as body type

IX_STATIC_CONST_STRING kIXCachePolicyDefault = @"reloadIgnoringLocalCache"; // Accepted Value Default
IX_STATIC_CONST_STRING kIXCachePolicyUseProtocolCachePolicy = @"useProtocolCachePolicy";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalCacheData = @"reloadIgnoringLocalCache";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalAndRemoteCacheData = @"reloadIgnoringLocalAndRemoteCache";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataElseLoad = @"useCacheElseLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataDontLoad = @"useCacheDontLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReloadRevalidatingCacheData = @"reloadRevalidatingCache";

// IXHTTPDataProvider Read-Only Properties
IX_STATIC_CONST_STRING kIXResponseTime = @"response.time";
IX_STATIC_CONST_STRING kIXResponseBodyParsed = @"response.body";
IX_STATIC_CONST_STRING kIXResponseRaw = @"response.raw";
IX_STATIC_CONST_STRING kIXResponseHeaders = @"response.headers";
IX_STATIC_CONST_STRING kIXStatusCode = @"response.code";
IX_STATIC_CONST_STRING kIXErrorMessage = @"response.error";

// IXBaseDataProvider Functions
IX_STATIC_CONST_STRING kIXClearCache = @"clearCache"; // Clears the cached data that is associated with this data provider's url.

// Non Property constants.
IX_STATIC_CONST_STRING KIXDataProviderCacheName = @"com.ignite.DataProviderCache";
IX_STATIC_CONST_STRING kIXLocationSuffixCache = @".cache";
IX_STATIC_CONST_STRING kIXLocationSuffixRemote = @".remote";
static NSCache* sIXDataProviderCache = nil;


@interface IXHTTPDataProvider ()

@property (nonatomic,copy) NSString* requestBinUrl;

@property (nonatomic,copy) NSString* acceptedContentType;
@property (nonatomic,copy) NSString* requestType;
@property (nonatomic,copy) NSString* responseType;
//@property (nonatomic,copy) NSString* cacheID;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

@end

// Internal header properties
IX_STATIC_CONST_STRING kIXContentTypeHeaderJSON = @"application/json; charset=utf-8"; // Content-Type header value
IX_STATIC_CONST_STRING kIXContentTypeHeaderForm = @"application/x-www-form-urlencoded"; // Content-Type header value
IX_STATIC_CONST_STRING kIXAcceptHeaderJSON = @"application/json"; // Accept header value
IX_STATIC_CONST_STRING kIXAcceptHeaderXML = @"application/xml"; // Accept header value
IX_STATIC_CONST_STRING kIXContentTypeHeaderKey = @"Content-Type";
IX_STATIC_CONST_STRING kIXAcceptCharsetHeaderKey = @"Accept-Charset";
IX_STATIC_CONST_STRING kIXAcceptCharsetHeaderValue = @"utf-8"; // Accept-Charset header type


@implementation IXHTTPDataProvider
@synthesize url = _url;
@synthesize method = _method;
@synthesize body = _body;
@synthesize requestBinUrl = _requestBinUrl;
@synthesize queryParams = _queryParams;
@synthesize urlEncodeParams = _urlEncodeParams;
@synthesize deriveValueTypes = _deriveValueTypes;
@synthesize requestQueryParamsObject = _requestQueryParamsObject;
@synthesize requestBodyObject = _requestBodyObject;
@synthesize requestHeadersObject = _requestHeadersObject;
@synthesize fileAttachmentObject = _fileAttachmentObject;

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
    [self setBody:[[self propertyContainer] getStringPropertyValue:kIXBody defaultValue:nil]];
    [self setQueryParams:[[self propertyContainer] getStringPropertyValue:kIXQueryParams defaultValue:nil]];
    [self setRequestType:[[self propertyContainer] getStringPropertyValue:kIXRequestType defaultValue:kIXRequestTypeJSON]];
    [self setResponseType:[[self propertyContainer] getStringPropertyValue:kIXResponseType defaultValue:kIXRequestTypeJSON]];
    
    if ([self requestIsPostOrPut]) {
        [self setRequestBinUrl:[[self propertyContainer] getStringPropertyValue:kIXDebugRequestBinUrl defaultValue:nil]];
    }
    //    [self setDataBaseURL:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    //    [self setDataPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setCachePolicy:[self cachePolicyFromString:[[self propertyContainer] getStringPropertyValue:kIXCachePolicy defaultValue:kIXCachePolicyDefault]]];
    [self setCacheResponse:[[self propertyContainer] getBoolPropertyValue:kIXCacheEnabled defaultValue:YES]];

    if( ![self isPathLocal] )
    {
        [self buildHTTPRequest];
    }
 
//    if( [self acceptedContentType] )
//    {
//        [IXAF addAcceptedContentType:[self acceptedContentType]];
//    }
}

- (void)buildHTTPRequest
{
    [self setAcceptedContentType];
    [self setRequestType];
    [self setHeaders];
    [self setBasicAuth];
    [self configureCache];
}

//-(NSString*)cacheForCacheID:(NSString*)cacheID
//{
//    return [sIXDataProviderCache objectForKey:cacheID];
//}


- (void)setAcceptedContentType {
    
    NSString* acceptedContentType;
    if ([[NSStringFromClass([self class]) lowercaseString] containsString:kIXRequestTypeJSON]) {
        acceptedContentType = kIXAcceptHeaderJSON;
    } else if ([[NSStringFromClass([self class]) lowercaseString] containsString:kIXRequestTypeXML]) {
        acceptedContentType = kIXAcceptHeaderXML;
    }
    if (acceptedContentType == nil) {
        acceptedContentType = [[self propertyContainer] getStringPropertyValue:[NSString stringWithFormat:@"%@.Accept", kIXHeaders] defaultValue:nil];
    }
    if (acceptedContentType == nil) {
        acceptedContentType = [[self propertyContainer] getStringPropertyValue:[NSString stringWithFormat:@"%@.accept", kIXHeaders] defaultValue:nil];
    }
    if (acceptedContentType != nil) {
        [IXAFHTTPSessionManager sharedManager].responseSerializer.acceptableContentTypes = [NSSet setWithObject:acceptedContentType];
    }
    _acceptedContentType = acceptedContentType;
}

- (void)setRequestType {
    if ([_requestType isEqualToString:kIXRequestTypeJSON]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFJSONRequestSerializer serializer];
    } else if ([_requestType isEqualToString:kIXRequestTypeForm]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    if ([_method isEqualToString:kIXMethodGET] || [_method isEqualToString:kIXMethodDELETE]) {
        [IXAFHTTPSessionManager sharedManager].requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

- (void)setHeaders {
    if ([_requestHeadersObject propertyExistsForPropertyNamed:kIXAcceptCharsetHeaderKey]) {
        [_requestHeadersObject addProperty:[IXProperty propertyWithPropertyName:kIXAcceptCharsetHeaderKey rawValue:kIXAcceptCharsetHeaderValue]];
    }
    if ([_requestHeadersObject propertyExistsForPropertyNamed:kIXContentTypeHeaderKey]) {
        [_requestHeadersObject addProperty:[IXProperty propertyWithPropertyName:kIXContentTypeHeaderKey rawValue:[self contentTypeForBodyEncoding]]];
    }
    [[_requestHeadersObject getAllPropertiesObjectValues:NO] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
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

- (NSString*)contentTypeForBodyEncoding {
    if ([_requestType isEqualToString:kIXRequestTypeJSON]) {
        return kIXAcceptHeaderJSON;
    } else if ([_requestType isEqualToString:kIXRequestTypeForm]) {
        return kIXContentTypeHeaderForm;
    } else
        return kIXAcceptHeaderJSON; // default
}

//- (void)loadDataFromCache:(NSString*)cachedResponse {
//    [self setResponseString:cachedResponse];
//    [self fireLoadFinishedEventsFromCache];
//}


-(void)setRequestEndTime:(CFAbsoluteTime)requestEndTime
{
    CFTimeInterval elapsedTime = (requestEndTime - _requestStartTime) * 1000;
    _responseTime = elapsedTime;
}

-(void)loadDataFromLocalPath {
    __weak typeof(self) weakSelf = self;
    [[IXDataLoader sharedDataLoader] loadJSONFromPath:self.url
                                                async:YES
                                          shouldCache:NO
                                           completion:^(id jsonObject, NSString* stringValue, NSError *error) {
                                               
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   
                                                   if( [NSJSONSerialization isValidJSONObject:jsonObject] )
                                                   {
                                                       [self setResponseString:stringValue];
                                                       [self setResponseObject:jsonObject];
                                                       IX_dispatch_main_sync_safe(^{
                                                           [self fireLoadFinishedEvents:YES];
                                                       });
                                                   }
                                                   else
                                                   {
                                                       [weakSelf setResponseErrorMessage:[error description]];
                                                       IX_dispatch_main_sync_safe(^{
                                                           [self fireLoadFinishedEvents:NO];
                                                       });
                                                   }
                                               });
                                           }];
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    [self loadData:forceGet completion:^(BOOL success, NSURLSessionDataTask *task, id responseObject, NSError *error) {
        
        [self setRequestEndTime:CFAbsoluteTimeGetCurrent()];
        
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
//        NSError* __autoreleasing dataErr = nil;
//        NSData* responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:&dataErr];
        [self setResponseObject:responseObject];
//        [self setResponseString:[[NSString string] initWithData:responseData encoding:NSUTF8StringEncoding]];
        
        [self setResponseStatusCode:response.statusCode];

        [self setResponseHeaders:response.allHeaderFields];
        [self setRequestEndTime:CFAbsoluteTimeGetCurrent()];
        
        if (error)
        {
            [self setResponseObject:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]];
            [self setResponseErrorMessage:error.localizedDescription];
        }
        else
        {
            [self setResponseObject:responseObject];
            [self fireLoadFinishedEvents:[NSJSONSerialization isValidJSONObject:self.responseObject]];
        }
    }];
}

-(void)loadData:(BOOL)forceGet completion:(LoadFinished)completion
{
    [IXAFHTTPSessionManager sharedManager].responseSerializer = [AFJSONResponseSerializer serializer];
    
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
            [self setResponseObject:nil];
            [self setResponseHeaders:nil];
            [self setResponseString:nil];
            [self setResponseStatusCode:0];
            [self setResponseTime:0];
            [self setResponseErrorMessage:nil];
            
            NSDictionary* body = [self resolveBody];
            NSDictionary* queryParams = [self resolveQueryParams];
            
            if ([_method isEqualToString:kIXMethodGET]) {
                
                [[IXAFHTTPSessionManager sharedManager] GET:_url parameters:queryParams success:^(NSURLSessionDataTask *task, id responseObject) {
                    completion(YES, task, responseObject, nil);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    completion(NO, task, nil, error);
                }];
            } else if ([_method isEqualToString:kIXMethodPOST]) {
                [[IXAFHTTPSessionManager sharedManager] POST:_url parameters:body success:^(NSURLSessionDataTask *task, id responseObject) {
                    completion(YES, task, responseObject, nil);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    completion(NO, task, nil, error);
                }];
                if (_requestBinUrl != nil) {
                    [[IXAFHTTPSessionManager sharedManager] POST:_requestBinUrl parameters:body success:nil failure:nil];
                }
            } else if ([_method isEqualToString:kIXMethodPUT]) {
                [[IXAFHTTPSessionManager sharedManager] PUT:_url parameters:body success:^(NSURLSessionDataTask *task, id responseObject) {
                    completion(YES, task, responseObject, nil);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    completion(NO, task, nil, error);
                }];
                if (_requestBinUrl != nil) {
                    [[IXAFHTTPSessionManager sharedManager] PUT:_requestBinUrl parameters:body success:nil failure:nil];
                }
            } else if ([_method isEqualToString:kIXMethodDELETE]) {
                [[IXAFHTTPSessionManager sharedManager] DELETE:_url parameters:queryParams success:^(NSURLSessionDataTask *task, id responseObject) {
                    completion(YES, task, responseObject, nil);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    completion(NO, task, nil, error);
                }];
            }
        }
    }
    else
    {
        IX_LOG_ERROR(@"ERROR: 'url' [%@] is %@; is 'url' defined in your datasource?", self.ID, self.url);
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

-(NSDictionary*)resolveBody
{
    NSDictionary* body;
    if ([self requestIsPostOrPut]) {
        @try {
            if (_requestBodyObject) {
                body = [_requestBodyObject getAllPropertiesObjectValues:NO];
            } else if (_body) {
                NSError* __autoreleasing error = nil;
                body = [NSJSONSerialization JSONObjectWithData:[_body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error] ?: nil;
            }
            if (_deriveValueTypes) {
                body = [NSDictionary ix_dictionaryWithParsedValuesFromDictionary:body];
            }
        }
        @catch (NSException *exception) {
            IX_LOG_ERROR(@"Body included with request was not a valid JSON object or string: %@", body);
        }
    }
    return body;
}

-(NSDictionary*)resolveQueryParams
{
    NSDictionary* queryParams;
    if ([self requestIsGetOrDelete]) {
        @try {
            if (_requestQueryParamsObject) {
                queryParams = [_requestQueryParamsObject getAllPropertiesObjectValues:_urlEncodeParams];
            } else if (_queryParams) {
                queryParams = [NSDictionary ix_dictionaryFromQueryParamsString:_queryParams];
            }
        }
        @catch (NSException *exception) {
            IX_LOG_ERROR(@"Body included with request was not a valid form-encoded object or string: %@", queryParams);
        }
    }
    return queryParams;
}

-(void)calculateAndStoreDataRowResultsForDataRowPath:(NSString*)dataRowPath
{
    NSObject* jsonObject = nil;
    if( [dataRowPath length] <= 0 && [[self responseObject] isKindOfClass:[NSArray class]] )
    {
        jsonObject = [self responseObject];
    }
    else
    {
        jsonObject = [self objectForPath:dataRowPath container:[self responseObject]];
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
    NSString* returnValue = [super getReadOnlyPropertyValue:propertyName];
    if( returnValue == nil )
    {
        if( ![[self propertyContainer] propertyExistsForPropertyNamed:propertyName] )
        {
            NSObject* jsonObject = [self objectForPath:propertyName container:[self responseObject]];
            if( jsonObject )
            {
                if( [jsonObject isKindOfClass:[NSString class]] )
                {
                    returnValue = (NSString*)jsonObject;
                }
                else if( [jsonObject isKindOfClass:[NSNumber class]] )
                {
                    returnValue = [(NSNumber*)jsonObject stringValue];
                }
                else if( [NSJSONSerialization isValidJSONObject:jsonObject] )
                {
                    NSError* __autoreleasing jsonConvertError = nil;
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
                    if( jsonConvertError == nil && jsonData )
                    {
                        returnValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    }
                }
            }
        }
    }
    else if( [propertyName isEqualToString:kIXResponseRaw] )
    {
        returnValue = [_responseString copy];
    }
    else if ([propertyName hasPrefix:kIXResponseHeaders]) {
        NSString* headerKey = [[propertyName componentsSeparatedByString:kIX_PERIOD_SEPERATOR] lastObject];
        @try {
            returnValue = _responseHeaders[headerKey];
            if (!returnValue) {
                returnValue = _responseHeaders[[headerKey lowercaseString]]; // try again with lowercase?
            }
        }
        @catch (NSException *exception) {
            DDLogDebug(@"No header value named '%@' exists in response object", headerKey);
        }
    }
    else if ([propertyName hasPrefix:kIXResponseTime]) {
        returnValue = [NSString stringWithFormat: @"%0.f", _responseTime];
    }
    else if( [propertyName isEqualToString:kIXStatusCode] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self responseStatusCode]];
    }
    else if( [propertyName isEqualToString:kIXErrorMessage] )
    {
        returnValue = [[self responseErrorMessage] copy];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

//-(void)fireLoadFinishedEventsFromCache
//{

//    NSString* responseString = [self responseString];
//    NSData* rawResponseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError* __autoreleasing error = nil;
//    id jsonObject = [NSJSONSerialization JSONObjectWithData:rawResponseData options:0 error:&error];
//    if( jsonObject )
//    {
//        [self setResponseObject:jsonObject];
//        [super fireLoadFinishedEventsFromCachedResponse];
//    }
//    if ([self responseHeaders])
//    {
//        [self setResponseHeaders:[self responseHeaders]];
//    }
//    [self fireLoadFinishedEvents:YES shouldCacheResponse:NO isFromCache:YES];
//}

//-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse
//{
//    [self fireLoadFinishedEvents:loadDidSucceed shouldCacheResponse:shouldCacheResponse isFromCache:NO];
//}

//-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache
//{
    //
//    if( loadDidSucceed && shouldCacheResponse )
//    {
//        [self cacheResponse];
//    }
//}

//-(void)cacheResponse
//{
//    if ( [[self cacheID] length] > 0 && [[self responseObject] != nil )
//    {
//        [sIXDataProviderCache setObject:[self responseObject]
//                                 forKey:[self cacheID]];
//    }
//}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    [super fireLoadFinishedEvents:loadDidSucceed];
    
    NSString* locationSpecificEventSuffix = ([IXHTTPDataProvider cacheExistsForURL:_url]) ? kIXLocationSuffixCache : kIXLocationSuffixRemote;
    
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
    
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",(loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED,locationSpecificEventSuffix]];
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_DONE,locationSpecificEventSuffix]];

}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
//    BOOL needsToRecacheResponse = NO;
    if( [functionName isEqualToString:kIXClearCache] )
    {
        [IXHTTPDataProvider clearCacheForURL:self.url];
    }
    else if( [functionName isEqualToString:kIXModifyResponse] )
    {
        NSString* modifyResponseType = [parameterContainer getStringPropertyValue:kIXModifyType defaultValue:nil];
        if( [modifyResponseType length] > 0 )
        {
            NSString* topLevelContainerPath = [parameterContainer getStringPropertyValue:kIXTopLevelContainer defaultValue:nil];
            id topLevelContainer = [self objectForPath:topLevelContainerPath container:[self responseObject]];

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
//                            needsToRecacheResponse = YES;
                        }
                    }
                }
                else if( [modifyResponseType isEqualToString:kIXAppend] )
                {
                    id jsonToAppendObject = nil;
//                    if( [parameterContainer getBoolPropertyValue:kIXParseJSONAsObject defaultValue:NO] )
//                    {
//                        jsonToAppendObject = [[parameterContainer getAllPropertiesObjectValues:NO] objectForKey:kIXJSONToAppend];
//                    }
//                    else
//                    {
//                        NSString* jsonToAppendString = [parameterContainer getStringPropertyValue:kIXJSONToAppend defaultValue:nil];
//                        jsonToAppendObject = [NSJSONSerialization JSONObjectWithData:[jsonToAppendString dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments
//                                                                                    error:nil];
//                    }
//
//
//                    if( jsonToAppendObject != nil )
//                    {
//                        [topLevelArray addObject:jsonToAppendObject];
////                        needsToRecacheResponse = YES;
//                    }
                }

//                if( needsToRecacheResponse )
//                {
//                    NSError* error;
//                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self responseObject]
//                                                                       options:0
//                                                                         error:&error];
//                    if( [jsonData length] > 0 && error == nil )
//                    {
//                        [self setResponseString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
//                        [self cacheResponse];
//                    }
//                }
            }

        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

//-(void)cacheResponse
//{
//    if( [self responseObject] != nil )
//    {
//        NSError* error;
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self responseObject]
//                                                           options:0
//                                                             error:&error];
//        if( [jsonData length] > 0 && error == nil )
//        {
//            [self setResponseString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
//        }
//    }
//    
//    [super cacheResponse];
//}

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
    NSObject* jsonObject = [self objectForPath:jsonXPath container:container];
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

-(NSString*)getQueryValueOutOfValue:(NSString*)value
{
    NSString* returnValue = value;
    NSArray* seperatedValue = [value componentsSeparatedByString:@"?"];
    if( [seperatedValue count] > 0 )
    {
        NSString* objectID = [seperatedValue firstObject];
        NSString* propertyName = [seperatedValue lastObject];
        if( [objectID isEqualToString:kIXSessionRef] )
        {
            returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringPropertyValue:propertyName defaultValue:value];
        }
        else if( [objectID isEqualToString:kIXAppRef] )
        {
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:propertyName defaultValue:value];
        }
        else if( [objectID isEqualToString:kIXViewControlRef] )
        {
            returnValue = [[[self sandbox] viewController] getViewPropertyNamed:propertyName];
            if( returnValue == nil )
            {
                returnValue = value;
            }
        }
        else
        {
            NSArray* objectWithIDArray = [[self sandbox] getAllControlsAndDataProvidersWithID:objectID withSelfObject:self];
            IXBaseObject* baseObject = [objectWithIDArray firstObject];

            if( baseObject )
            {
                returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
                if( returnValue == nil )
                {
                    returnValue = [[baseObject propertyContainer] getStringPropertyValue:propertyName defaultValue:value];
                }
            }
        }
    }
    return returnValue;
}

- (NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*) currentNode
{
    if (currentNode == nil) {
        return nil;
    }
    
    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
        return currentNode;
    }
    if ([jsonXPath hasPrefix:kIX_PERIOD_SEPERATOR]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:kIX_PERIOD_SEPERATOR] firstObject];
    NSObject *nextNode;
    // if dict -> get value
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = currentDict[jsonXPath];
        if( nextNode != nil )
        {
            return nextNode;
        }
        else
        {
            nextNode = currentDict[currentKey];
        }
    }
    
    if ([currentNode isKindOfClass:[NSArray class]]) {
        NSArray * currentArray = (NSArray *) currentNode;
        @try {
            if( [currentKey containsString:@"="] ) // current key is actually looking to filter array if theres an '=' character
            {
                NSArray* currentKeySeperated = [currentKey componentsSeparatedByString:@"="];
                if( [currentKeySeperated count] > 1 ) {
                    NSString* currentKeyValue = [currentKeySeperated lastObject];
                    if( [currentKeyValue rangeOfString:@"?"].location != NSNotFound )
                    {
                        currentKeyValue = [self getQueryValueOutOfValue:currentKeyValue];
                    }
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(%K == %@)",[currentKeySeperated firstObject],currentKeyValue];
                    NSArray* filteredArray = [currentArray filteredArrayUsingPredicate:predicate];
                    if( [filteredArray count] >= 1 ) {
                        if( [filteredArray count] == 1 ) {
                            nextNode = [filteredArray firstObject];
                        } else {
                            nextNode = filteredArray;
                        }
                    }
                }
            }
            else // current key must be an number
            {
                if( [currentKey isEqualToString:@"$count"] || [currentKey isEqualToString:@".$count"] )
                {
                    return [NSString stringWithFormat:@"%lu",(unsigned long)[currentArray count]];
                }
                else if ([currentArray count] > 0)
                {
                    nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
                }
                else
                {
                    @throw [NSException exceptionWithName:@"NSRangeException"
                                                   reason:@"Specified array index is out of bounds"
                                                 userInfo:nil];
                }
            }
        }
        @catch (NSException *exception) {
            IX_LOG_ERROR(@"ERROR : %@ Exception in %@ : %@; attempted to retrieve index %@ from %@",THIS_FILE,THIS_METHOD,exception,currentKey, jsonXPath);
        }
    }
    
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:kIX_EMPTY_STRING];
    if( nextXPath.length <= 0 )
    {
        return nextNode;
    }
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container: nextNode];
}

@end