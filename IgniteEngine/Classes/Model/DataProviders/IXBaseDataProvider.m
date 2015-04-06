//
//  IXBaseDataProvider.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseDataProvider.h"

#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFOAuth2Manager.h"
#import "IXImage.h"
#import "IXPropertyContainer.h"
#import "IXEntityContainer.h"
#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXPathHandler.h"
#import "IXOAuthWebAuthViewController.h"
#import "IXSandbox.h"
#import "IXNavigationViewController.h"
#import "IXAppManager.h"
#import "UIViewController+IXAdditions.h"

//#import <RestKit/RestKit.h>

NSString* IXBaseDataProviderDidUpdateNotification = @"IXBaseDataProviderDidUpdateNotification";

// IXBaseDataProvider Attributes
IX_STATIC_CONST_STRING kIXAutoLoad = @"autoLoad.enabled";
IX_STATIC_CONST_STRING kIXBody = @"body"; // main body object
IX_STATIC_CONST_STRING kIXBodyEncoding = @"encoding"; // if not defined, predict from Content-Type header. If defined, adds Content-Type header.
IX_STATIC_CONST_STRING kIXHeaders = @"headers";
IX_STATIC_CONST_STRING kIXMethod = @"method";
IX_STATIC_CONST_STRING kIXParseResponse = @"parseResponse.enabled"; // parses response or leaves it as a string
IX_STATIC_CONST_STRING kIXQueryParams = @"queryParams";
IX_STATIC_CONST_STRING kIXUrl = @"url";
IX_STATIC_CONST_STRING kIXUrlEncodeParams = @"urlEncodeParams.enabled";

IX_STATIC_CONST_STRING kIXBasicUserName = @"auth.basic.username";
IX_STATIC_CONST_STRING kIXBasicPassword = @"auth.basic.password";

IX_STATIC_CONST_STRING kIXCacheID = @"cache.id";
IX_STATIC_CONST_STRING kIXCachePolicy = @"cache.policy";
//IX_STATIC_CONST_STRING kIXParseParametsAsObject = @"parseParameters.enabled";
//IX_STATIC_CONST_STRING kIXAcceptedContentType = @"http.headers.accept";

// IXBaseDataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXSortOrderNone = @"none"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending"; // kIXSortOrder
//IX_STATIC_CONST_STRING kIXParameterEncodingJSON = @"json"; // kIXParameterEncoding
//IX_STATIC_CONST_STRING kIXParameterEncodingPList = @"plist"; // kIXParameterEncoding
//IX_STATIC_CONST_STRING kIXParameterEncodingForm = @"form"; // kIXParameterEncoding

IX_STATIC_CONST_STRING kIXBodyEncodingForm = @"form"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXBodyEncodingJSON = @"json"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXBodyEncodingJSONString = @"jsonString"; // kIXBodyEncoding
IX_STATIC_CONST_STRING kIXBodyEncodingMultipart = @"multipart"; // kIXBodyEncoding

IX_STATIC_CONST_STRING kIXMethodGET = @"GET";
IX_STATIC_CONST_STRING kIXMethodPOST = @"POST";
IX_STATIC_CONST_STRING kIXMethodPUT = @"PUT";
IX_STATIC_CONST_STRING kIXMethodDELETE = @"DELETE";

IX_STATIC_CONST_STRING kIXCachePolicyDefault = @"reloadIgnoringLocalCache"; // Accepted Value Default
IX_STATIC_CONST_STRING kIXCachePolicyUseProtocolCachePolicy = @"useProtocolCachePolicy";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalCacheData = @"reloadIgnoringLocalCache";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalAndRemoteCacheData = @"reloadIgnoringLocalAndRemoteCache";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataElseLoad = @"useCacheElseLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataDontLoad = @"useCacheDontLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReloadRevalidatingCacheData = @"reloadRevalidatingCache";




// IXBaseDataProvider Read-Only Properties
IX_STATIC_CONST_STRING kIXResponseBodyParsed = @"response.body";
IX_STATIC_CONST_STRING kIXResponseRaw = @"response.raw";
IX_STATIC_CONST_STRING kIXResponseHeaders = @"response.headers";
IX_STATIC_CONST_STRING kIXStatusCode = @"response.code";
IX_STATIC_CONST_STRING kIXErrorMessage = @"response.error";

// IXBaseDataProvider Functions
IX_STATIC_CONST_STRING kIXClearCache = @"clearCache"; // Clears the cached data that is associated with this data providers kIXCacheID.
IX_STATIC_CONST_STRING kIXDeleteCookies = @"deleteCookies"; // kIXCookieURL is the parameter for this function.
IX_STATIC_CONST_STRING kIXCookieURL = @"cookie.url"; // Parameter on deleteCookies

// IXBaseDataProvider Events
IX_STATIC_CONST_STRING kIXStarted = @"began";

// TODO: These are not used?
IX_STATIC_CONST_STRING kIXAuthSuccess = @"auth.success";
IX_STATIC_CONST_STRING kIXAuthFail = @"auth.error";

// Non Property constants.
IX_STATIC_CONST_STRING KIXDataProviderCacheName = @"com.ignite.DataProviderCache";
IX_STATIC_CONST_STRING kIXLocationSuffixCache = @".cache";
IX_STATIC_CONST_STRING kIXLocationSuffixRemote = @".remote";
static NSCache* sIXDataProviderCache = nil;

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXRequestBodyObjectNSCodingKey = @"requestBodyObject";
IX_STATIC_CONST_STRING kIXRequestQueryParamsObjectNSCodingKey = @"requestQueryParamsObject";
IX_STATIC_CONST_STRING kIXRequestHeadersObjectNSCodingKey = @"requestHeadersObject";
IX_STATIC_CONST_STRING kIXFileAttachmentObjectNSCodingKey = @"fileAttachmentObject";

@interface IXImage ()

@property (nonatomic,strong) UIImage* defaultImage;

@end

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,getter = shouldUrlEncodeParams) BOOL urlEncodeParams;
@property (nonatomic,assign,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,copy) id responseObject;
@property (nonatomic,copy) id responseSerializer;
@property (nonatomic,copy) NSString* cacheID;
@property (nonatomic,copy) NSString* acceptedContentType;
@property (nonatomic,copy) NSString* method;
@property (nonatomic,copy) NSString* body;
@property (nonatomic,copy) NSString* queryParams;
@property (nonatomic,copy) NSString* fullDataLocation;
@property (nonatomic,copy) NSString* url;
//@property (nonatomic,copy) NSString* dataPath;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;


@end

@implementation IXBaseDataProvider

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIXDataProviderCache = [[NSCache alloc] init];
        [sIXDataProviderCache setName:KIXDataProviderCacheName];
    });
}

-(id)copyWithZone:(NSZone *)zone
{
    IXBaseDataProvider *copiedDataProvider = [super copyWithZone:zone];
    [copiedDataProvider setRequestQueryParamsObject:[[self requestQueryParamsObject] copy]];
    [copiedDataProvider setRequestBodyObject:[[self requestBodyObject] copy]];
    [copiedDataProvider setRequestHeadersObject:[[self requestHeadersObject] copy]];
    [copiedDataProvider setFileAttachmentObject:[[self fileAttachmentObject] copy]];
    return copiedDataProvider;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self requestQueryParamsObject] forKey:kIXRequestQueryParamsObjectNSCodingKey];
    [aCoder encodeObject:[self requestBodyObject] forKey:kIXRequestBodyObjectNSCodingKey];
    [aCoder encodeObject:[self requestHeadersObject] forKey:kIXRequestHeadersObjectNSCodingKey];
    [aCoder encodeObject:[self fileAttachmentObject] forKey:kIXFileAttachmentObjectNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setRequestQueryParamsObject:[aDecoder decodeObjectForKey:kIXRequestQueryParamsObjectNSCodingKey]];
        [self setRequestBodyObject:[aDecoder decodeObjectForKey:kIXRequestBodyObjectNSCodingKey]];
        [self setRequestHeadersObject:[aDecoder decodeObjectForKey:kIXRequestHeadersObjectNSCodingKey]];
        [self setFileAttachmentObject:[aDecoder decodeObjectForKey:kIXFileAttachmentObjectNSCodingKey]];
    }
    return self;
}

+(void)clearCache
{
    [sIXDataProviderCache removeAllObjects];
}

-(void)setRequestHeadersObject:(IXPropertyContainer *)requestHeadersObject
{
    _requestHeadersObject = requestHeadersObject;
    [_requestHeadersObject setOwnerObject:self];
}

-(void)setRequestQueryParamsObject:(IXPropertyContainer *)requestQueryParamsObject
{
    _requestQueryParamsObject = requestQueryParamsObject;
    [requestQueryParamsObject setOwnerObject:self];
}

-(void)setRequestBodyObject:(IXPropertyContainer *)requestBodyObject
{
    _requestBodyObject = requestBodyObject;
    [_requestBodyObject setOwnerObject:self];
}

-(void)setFileAttachmentObject:(IXPropertyContainer *)fileAttachmentObject
{
    _fileAttachmentObject = fileAttachmentObject;
    [_fileAttachmentObject setOwnerObject:self];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setMethod:[[self propertyContainer] getStringPropertyValue:kIXMethod defaultValue:kIXMethodGET]];
    [self setBody:[[self propertyContainer] getStringPropertyValue:kIXBody defaultValue:nil]];
    [self setQueryParams:[[self propertyContainer] getStringPropertyValue:kIXQueryParams defaultValue:nil]];
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    [self setUrlEncodeParams:[[self propertyContainer] getBoolPropertyValue:kIXUrlEncodeParams defaultValue:YES]];
    [self setCacheID:[[self propertyContainer] getStringPropertyValue:kIXCacheID defaultValue:nil]];
    [self setAcceptedContentType:[self acceptHeader]];
    //    [self setDataBaseURL:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    //    [self setDataPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setCachePolicy:[self cachePolicyFromString:[[self propertyContainer] getStringPropertyValue:kIXCachePolicy defaultValue:kIXCachePolicyDefault]]];
    
    NSString* url = [[self propertyContainer] getPathPropertyValue:_url basePath:nil defaultValue:nil];
    [self setUrl:url];
    [self setPathIsLocal:[IXPathHandler pathIsLocal:url]];
    if( ![self isPathLocal] )
    {
        [self createHTTPRequest:^{
            //
        }];
        
//        [self createRequest];
        
//        AFHTTPClientParameterEncoding paramEncoding = AFJSONParameterEncoding;
//        NSString* parameterEncoding = [[self propertyContainer] getStringPropertyValue:kIXParameterEncoding defaultValue:kIXParameterEncodingJSON];
//        if( [parameterEncoding isEqualToString:kIXParameterEncodingForm] ) {
//            paramEncoding = AFFormURLParameterEncoding;
//        } else if( [parameterEncoding isEqualToString:kIXParameterEncodingPList] ) {
//            paramEncoding = AFPropertyListParameterEncoding;
//        }
        
//        [[self httpClient] setParameterEncoding:paramEncoding];
    }
}

- (NSString*)acceptHeader {
    NSString* acceptHeader = [[self propertyContainer] getStringPropertyValue:kIXBodyEncoding defaultValue:nil];
    if (acceptHeader == nil) {
        acceptHeader = [[self propertyContainer] getStringPropertyValue:[NSString stringWithFormat:@"%@.Accept", kIXHeaders] defaultValue:nil];
    }
    if (acceptHeader == nil) {
        acceptHeader = [[self propertyContainer] getStringPropertyValue:[NSString stringWithFormat:@"%@.accept", kIXHeaders] defaultValue:nil];
    }
    return acceptHeader;
}

- (void)createHTTPRequest:(void(^)(void))completion
{
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
    }

    [self setEncoding];
    [self setHeaders];
    [self setBasicAuth];
    
    if ([_method isEqualToString:kIXMethodGET]) {
        [_manager GET:_url parameters:[_requestQueryParamsObject getAllPropertiesObjectValues:_urlEncodeParams]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  _responseObject = responseObject;
                  completion();
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  _responseErrorMessage = error.localizedDescription;
                  completion();
              }];
    } else if ([_method isEqualToString:kIXMethodPOST]) {
        [_manager POST:_url parameters:[_requestBodyObject getAllPropertiesObjectValues:NO]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  _responseObject = responseObject;
                  completion();
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  _responseErrorMessage = error.localizedDescription;
                  completion();
              }];
    } else if ([_method isEqualToString:kIXMethodPUT]) {
        [_manager PUT:_url parameters:[_requestBodyObject getAllPropertiesObjectValues:NO]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   _responseObject = responseObject;
                   completion();
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   _responseErrorMessage = error.localizedDescription;
                   completion();
               }];
    } else if ([_method isEqualToString:kIXMethodDELETE]) {
        [_manager DELETE:_url parameters:[_requestQueryParamsObject getAllPropertiesObjectValues:_urlEncodeParams]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   _responseObject = responseObject;
                   completion();
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   _responseErrorMessage = error.localizedDescription;
                   completion();
               }];
    }
}

- (void)setEncoding {
    if ([_acceptedContentType isEqualToString:kIXBodyEncodingJSON] || [_acceptedContentType isEqualToString:kIXBodyEncodingJSONString]) {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    } else if ([_acceptedContentType isEqualToString:kIXBodyEncodingForm]) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

- (void)setHeaders {
    [[_requestHeadersObject getAllPropertiesObjectValues:NO] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        [_manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }];
}

- (void)setBasicAuth {
    NSString* username = [[self propertyContainer] getStringPropertyValue:kIXBasicUserName defaultValue:nil];
    NSString* password = [[self propertyContainer] getStringPropertyValue:kIXBasicPassword defaultValue:nil];
    [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

//-(void)createRequest
//{
//    if( _requestManager == nil || ![_requestManager.baseURL.absoluteString isEqualToString:_url] )
//    {
//        NSURL* baseURL = [NSURL URLWithString:_url];
//        AFHTTPClient* httpClient = [AFHTTPClient clientWithBaseURL:baseURL];
//        [self setHttpClient:httpClient];
//    }
//    
//    NSString* userName = [[self propertyContainer] getStringPropertyValue:kIXBasicUserName defaultValue:nil];
//    NSString* password = [[self propertyContainer] getStringPropertyValue:kIXBasicPassword defaultValue:nil];
//    
//    [[self httpClient] clearAuthorizationHeader];
//    
//    if( [userName length] > 0 && [password length] > 0 )
//    {
//        [[self httpClient] setAuthorizationHeaderWithUsername:userName password:password];
//    }
//}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXResponseRaw] )
    {
        returnValue = [[self responseRawString] copy];
    }
    // TODO: Remove this from JSON DP and implement here instead
    /* This is removed from BaseData provider and only implmeented in JSONDP.
     else if( [propertyName containsString:kIXResponseHeaders] )
     {
     @try {
     NSString* responseHeader = [[[propertyName componentsSeparatedByString:kIX_PERIOD_SEPERATOR] lastObject] lowercaseString];
     returnValue = [self responseHeaders][responseHeader];
     
     }
     @catch (NSException *exception) {
     DDLogDebug(@"Tried to reference a response header object that didn't exist: %@", returnValue);
     }
     }
     */
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXClearCache] )
    {
        if( [[self cacheID] length] > 0 )
        {
            [sIXDataProviderCache removeObjectForKey:[self cacheID]];
        }
    }
    else if( [functionName isEqualToString:kIXDeleteCookies] )
    {
        NSString* urlToDeleteCookiesFor = [parameterContainer getStringPropertyValue:kIXCookieURL defaultValue:nil];
        if( [urlToDeleteCookiesFor length] > 0 )
        {
            NSArray *cookiesToDelete = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlToDeleteCookiesFor]];
            for (NSHTTPCookie *cookie in cookiesToDelete )
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)loadData:(BOOL)forceGet
{
    if( [self cacheID] != nil )
    {
        NSString* cachedResponse = [sIXDataProviderCache objectForKey:[self cacheID]];
        if( [cachedResponse length] > 0 )
        {
            [self setResponseRawString:cachedResponse];
            [self fireLoadFinishedEventsFromCachedResponse];
        }
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXStarted];
}

-(void)fireLoadFinishedEventsFromCachedResponse
{
    [self fireLoadFinishedEvents:YES shouldCacheResponse:NO isFromCache:YES];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse
{
    [self fireLoadFinishedEvents:loadDidSucceed shouldCacheResponse:shouldCacheResponse isFromCache:NO];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache
{
    NSString* locationSpecificEventSuffix = (isFromCache) ? kIXLocationSuffixCache : kIXLocationSuffixRemote;
    
    if( loadDidSucceed )
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_SUCCESS];
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_SUCCESS,locationSpecificEventSuffix]];
    }
    else
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_FAILED];
        [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_FAILED,locationSpecificEventSuffix]];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIX_DONE];
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_DONE,locationSpecificEventSuffix]];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                            object:self];
    });
    
    if( loadDidSucceed && shouldCacheResponse )
    {
        [self cacheResponse];
    }
}

-(void)cacheResponse
{
    if ( [[self cacheID] length] > 0 && [[self responseRawString] length] > 0 )
    {
        [sIXDataProviderCache setObject:[self responseRawString]
                                 forKey:[self cacheID]];
    }
}

//-(NSURLRequest*)createURLRequest
//{
//    NSMutableURLRequest* request = nil;
//    
//    NSMutableDictionary* dictionaryOfFiles = [NSMutableDictionary dictionaryWithDictionary:[[self fileAttachmentObject] getAllPropertiesURLValues]];
//    [dictionaryOfFiles removeObjectsForKeys:@[@"image.id",@"image.name",@"image.mimeType",@"image.jpegCompression"]];
//    
//    NSDictionary* queryParams = [[self requestQueryParamsObject] getAllPropertiesObjectValues:[self shouldUrlEncodeParams]];
//    
//    NSString* imageControlRef = [[self fileAttachmentObject] getStringPropertyValue:@"image.id" defaultValue:nil];
//    IXImage* imageControl = [[[self sandbox] getAllControlsWithID:imageControlRef] firstObject];
//    
//    if( [[dictionaryOfFiles allKeys] count] > 0 || imageControl.defaultImage != nil )
//    {
//        request = [[self httpClient] multipartFormRequestWithMethod:_method path:_url parameters:queryParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            
//            if( [imageControl isKindOfClass:[IXImage class]] )
//            {
//                NSString* attachementImageName = [[self fileAttachmentObject] getStringPropertyValue:@"image.name"
//                                                                                        defaultValue:nil];
//                NSString* imageMimeType = [[self fileAttachmentObject] getStringPropertyValue:@"image.mimeType"
//                                                                                 defaultValue:nil];
//                
//                NSString* imageType = [[imageMimeType componentsSeparatedByString:@"/"] lastObject];
//                
//                NSData* imageData = nil;
//                if( [imageType isEqualToString:@"png"] )
//                {
//                    imageData = UIImagePNGRepresentation(imageControl.defaultImage);
//                }
//                else if( [imageType isEqualToString:@"jpeg"] )
//                {
//                    float imageJPEGCompression = [[self fileAttachmentObject] getFloatPropertyValue:@"image.jpegCompression" defaultValue:0.5f];
//                    imageData = UIImageJPEGRepresentation(imageControl.defaultImage, imageJPEGCompression);
//                }
//                
//                if( imageData && [attachementImageName length] > 0 && [imageMimeType length] > 0 && [imageType length] > 0 )
//                {
//                    [formData appendPartWithFileData:imageData
//                                                name:attachementImageName
//                                            fileName:[NSString stringWithFormat:@"%@.%@",attachementImageName,imageType]
//                                            mimeType:imageMimeType];
//                }
//            }
//            
//            [dictionaryOfFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                if( [obj isKindOfClass:[NSURL class]] && [obj isFileURL] )
//                {
//                    [formData appendPartWithFileURL:obj name:key error:nil];
//                }
//            }];
//        }];
//    }
//    else
//    {
//        request = [[self httpClient] requestWithMethod:_method
//                                                  path:_url
//                                            parameters:queryParams];
//    }
//    
//    if( [[self httpBody] length] > 0 ) {
//        [request setHTTPBody:[[self httpBody] dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    
//    [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues:NO]];
//    return request;
//}
//


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

@end
