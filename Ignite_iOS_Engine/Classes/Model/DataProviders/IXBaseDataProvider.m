//
//  IXBaseDataProvider.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseDataProvider.h"

#import "AFHTTPClient.h"
#import "AFOAuth2Client.h"
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

#import <RestKit/RestKit.h>

NSString* IXBaseDataProviderDidUpdateNotification = @"IXBaseDataProviderDidUpdateNotification";

// IXBaseDataProvider Attributes
IX_STATIC_CONST_STRING kIXDataBaseUrl = @"baseUrl";
IX_STATIC_CONST_STRING kIXDataPath = @"pathSuffix";
IX_STATIC_CONST_STRING kIXAutoLoad = @"autoLoad.enabled";
IX_STATIC_CONST_STRING kIXAutoEncodeParams = @"autoEncodeParams.enabled";
IX_STATIC_CONST_STRING kIXCacheID = @"cache.id";
IX_STATIC_CONST_STRING kIXHTTPMethod = @"http.method";
IX_STATIC_CONST_STRING kIXHTTPBody = @"http.body";
IX_STATIC_CONST_STRING kIXBasicUserName = @"auth.basic.username";
IX_STATIC_CONST_STRING kIXBasicPassword = @"auth.basic.password";
IX_STATIC_CONST_STRING kIXParameterEncoding = @"http.body.encoding";
IX_STATIC_CONST_STRING kIXParseParametsAsObject = @"parseParameters.enabled";
IX_STATIC_CONST_STRING kIXAcceptedContentType = @"http.headers.accept";
IX_STATIC_CONST_STRING kIXCachePolicy = @"cache.policy";

// IXBaseDataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXSortOrderNone = @"none"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending"; // kIXSortOrder
IX_STATIC_CONST_STRING kIXParameterEncodingJSON = @"json"; // kIXParameterEncoding
IX_STATIC_CONST_STRING kIXParameterEncodingPList = @"plist"; // kIXParameterEncoding
IX_STATIC_CONST_STRING kIXParameterEncodingForm = @"form"; // kIXParameterEncoding
IX_STATIC_CONST_STRING kIXCachePolicyUseProtocolCachePolicy = @"useProtocolCachePolicy";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalCacheData = @"reloadIgnoringLocalCache";
IX_STATIC_CONST_STRING kIXCachePolicyReloadIgnoringLocalAndRemoteCacheData = @"reloadIgnoringLocalAndRemoteCache";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataElseLoad = @"useCacheElseLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReturnCacheDataDontLoad = @"useCacheDontLoad";
IX_STATIC_CONST_STRING kIXCachePolicyReloadRevalidatingCacheData = @"reloadRevalidatingCache";

// Accepted Value Defaults
IX_STATIC_CONST_STRING kIXCachePolicyDefault = @"reloadIgnoringLocalCache";

// IXBaseDataProvider Read-Only Properties
IX_STATIC_CONST_STRING kIXRawDataResponse = @"response.raw";
// IX_STATIC_CONST_STRING kIXResponseHeaders = @"response.headers"; This is removed from BaseData provider and only implmeented in JSONDP.
IX_STATIC_CONST_STRING kIXStatusCode = @"response.status.code";
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
IX_STATIC_CONST_STRING kIXRequestParameterPropertiesNSCodingKey = @"requestParameterProperties";
IX_STATIC_CONST_STRING kIXRequestHeaderPropertiesNSCodingKey = @"requestHeaderProperties";
IX_STATIC_CONST_STRING kIXFileAttachmentPropertiesNSCodingKey = @"fileAttachmentProperties";

@interface IXImage ()

@property (nonatomic,strong) UIImage* defaultImage;

@end

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,getter = shouldAutoEncodeParams) BOOL autoEncodeParams;
@property (nonatomic,assign,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,copy) NSString* cacheID;
@property (nonatomic,copy) NSString* acceptedContentType;
@property (nonatomic,copy) NSString* httpMethod;
@property (nonatomic,copy) NSString* httpBody;
@property (nonatomic,copy) NSString* fullDataLocation;
@property (nonatomic,copy) NSString* dataBaseURL;
@property (nonatomic,copy) NSString* dataPath;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

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
    [copiedDataProvider setRequestParameterProperties:[[self requestParameterProperties] copy]];
    [copiedDataProvider setRequestHeaderProperties:[[self requestHeaderProperties] copy]];
    [copiedDataProvider setFileAttachmentProperties:[[self fileAttachmentProperties] copy]];
    return copiedDataProvider;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self requestParameterProperties] forKey:kIXRequestParameterPropertiesNSCodingKey];
    [aCoder encodeObject:[self requestHeaderProperties] forKey:kIXRequestHeaderPropertiesNSCodingKey];
    [aCoder encodeObject:[self fileAttachmentProperties] forKey:kIXFileAttachmentPropertiesNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setRequestParameterProperties:[aDecoder decodeObjectForKey:kIXRequestParameterPropertiesNSCodingKey]];
        [self setRequestHeaderProperties:[aDecoder decodeObjectForKey:kIXRequestHeaderPropertiesNSCodingKey]];
        [self setFileAttachmentProperties:[aDecoder decodeObjectForKey:kIXFileAttachmentPropertiesNSCodingKey]];
    }
    return self;
}

+(void)clearCache
{
    [sIXDataProviderCache removeAllObjects];
}

-(void)setRequestHeaderProperties:(IXPropertyContainer *)requestHeaderProperties
{
    _requestHeaderProperties = requestHeaderProperties;
    [_requestHeaderProperties setOwnerObject:self];
}

-(void)setRequestParameterProperties:(IXPropertyContainer *)requestParameterProperties
{
    _requestParameterProperties = requestParameterProperties;
    [_requestParameterProperties setOwnerObject:self];
}

-(void)setFileAttachmentProperties:(IXPropertyContainer *)fileAttachmentProperties
{
    _fileAttachmentProperties = fileAttachmentProperties;
    [_fileAttachmentProperties setOwnerObject:self];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setHttpMethod:[[self propertyContainer] getStringPropertyValue:kIXHTTPMethod defaultValue:@"GET"]];
    [self setHttpBody:[[self propertyContainer] getStringPropertyValue:kIXHTTPBody defaultValue:nil]];
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    [self setAutoEncodeParams:[[self propertyContainer] getBoolPropertyValue:kIXAutoEncodeParams defaultValue:YES]];
    [self setCacheID:[[self propertyContainer] getStringPropertyValue:kIXCacheID defaultValue:nil]];
    [self setAcceptedContentType:[[self propertyContainer] getStringPropertyValue:kIXAcceptedContentType defaultValue:nil]];
    [self setDataBaseURL:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    [self setDataPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setCachePolicy:[self cachePolicyFromString:[[self propertyContainer] getStringPropertyValue:kIXCachePolicy defaultValue:kIXCachePolicyDefault]]];
    
    NSString* fullDataLocation = [[self propertyContainer] getPathPropertyValue:kIXDataBaseUrl basePath:nil defaultValue:nil];
    if( [[self dataPath] length] )
    {
        if( ![fullDataLocation hasSuffix:@"/"] && ![[self dataPath] hasPrefix:@"/"] )
        {
            fullDataLocation = [NSString stringWithFormat:@"%@/%@",fullDataLocation,[self dataPath]];
        }
        else
        {
            fullDataLocation = [fullDataLocation stringByAppendingString:[self dataPath]];
        }
    }
    [self setFullDataLocation:fullDataLocation];
    
    [self setPathIsLocal:[IXPathHandler pathIsLocal:[self fullDataLocation]]];
    if( ![self isPathLocal] )
    {
        [self createHTTPClient];
        
        AFHTTPClientParameterEncoding paramEncoding = AFJSONParameterEncoding;
        NSString* parameterEncoding = [[self propertyContainer] getStringPropertyValue:kIXParameterEncoding defaultValue:kIXParameterEncodingJSON];
        if( [parameterEncoding isEqualToString:kIXParameterEncodingForm] ) {
            paramEncoding = AFFormURLParameterEncoding;
        } else if( [parameterEncoding isEqualToString:kIXParameterEncodingPList] ) {
            paramEncoding = AFPropertyListParameterEncoding;
        }
        
        [[self httpClient] setParameterEncoding:paramEncoding];
    }
}

-(void)createHTTPClient
{
    if( [self httpClient] == nil || ![[[[self httpClient] baseURL] absoluteString] isEqualToString:[self dataBaseURL]] )
    {
        NSURL* baseURL = [NSURL URLWithString:[self dataBaseURL]];
        AFHTTPClient* httpClient = [AFHTTPClient clientWithBaseURL:baseURL];
        [self setHttpClient:httpClient];
    }
    
    NSString* userName = [[self propertyContainer] getStringPropertyValue:kIXBasicUserName defaultValue:nil];
    NSString* password = [[self propertyContainer] getStringPropertyValue:kIXBasicPassword defaultValue:nil];
        
    [[self httpClient] clearAuthorizationHeader];
        
    if( [userName length] > 0 && [password length] > 0 )
    {
        [[self httpClient] setAuthorizationHeaderWithUsername:userName password:password];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXRawDataResponse] )
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
    
    [[self actionContainer] executeActionsForEventNamed:kIX_FINISHED];
    [[self actionContainer] executeActionsForEventNamed:[NSString stringWithFormat:@"%@%@",kIX_FINISHED,locationSpecificEventSuffix]];

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

-(NSURLRequest*)createURLRequest
{
    NSMutableURLRequest* request = nil;
    
    NSMutableDictionary* dictionaryOfFiles = [NSMutableDictionary dictionaryWithDictionary:[[self fileAttachmentProperties] getAllPropertiesURLValues]];
    [dictionaryOfFiles removeObjectsForKeys:@[@"image.id",@"image.name",@"image.mimeType",@"image.jpegCompression"]];
    
    NSDictionary* parameters = nil;
    if( [[self propertyContainer] getBoolPropertyValue:kIXParseParametsAsObject defaultValue:YES] )
    {
        parameters = [[self requestParameterProperties] getAllPropertiesObjectValues:[self shouldAutoEncodeParams]];
    }
    else
    {
        parameters = [[self requestParameterProperties] getAllPropertiesStringValues:[self shouldAutoEncodeParams]];
    }
    
    NSString* imageControlRef = [[self fileAttachmentProperties] getStringPropertyValue:@"image.id" defaultValue:nil];
    IXImage* imageControl = [[[self sandbox] getAllControlsWithID:imageControlRef] firstObject];
    
    if( [[dictionaryOfFiles allKeys] count] > 0 || imageControl.defaultImage != nil )
    {
        request = [[self httpClient] multipartFormRequestWithMethod:[self httpMethod] path:[self dataPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            if( [imageControl isKindOfClass:[IXImage class]] )
            {
                NSString* attachementImageName = [[self fileAttachmentProperties] getStringPropertyValue:@"image.name"
                                                                                            defaultValue:nil];
                NSString* imageMimeType = [[self fileAttachmentProperties] getStringPropertyValue:@"image.mimeType"
                                                                                     defaultValue:nil];
                
                NSString* imageType = [[imageMimeType componentsSeparatedByString:@"/"] lastObject];
                
                NSData* imageData = nil;
                if( [imageType isEqualToString:@"png"] )
                {
                    imageData = UIImagePNGRepresentation(imageControl.defaultImage);
                }
                else if( [imageType isEqualToString:@"jpeg"] )
                {
                    float imageJPEGCompression = [[self fileAttachmentProperties] getFloatPropertyValue:@"image.jpegCompression" defaultValue:0.5f];
                    imageData = UIImageJPEGRepresentation(imageControl.defaultImage, imageJPEGCompression);
                }
                
                if( imageData && [attachementImageName length] > 0 && [imageMimeType length] > 0 && [imageType length] > 0 )
                {
                    [formData appendPartWithFileData:imageData
                                                name:attachementImageName
                                            fileName:[NSString stringWithFormat:@"%@.%@",attachementImageName,imageType]
                                            mimeType:imageMimeType];
                }
            }
            
            [dictionaryOfFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if( [obj isKindOfClass:[NSURL class]] && [obj isFileURL] )
                {
                    [formData appendPartWithFileURL:obj name:key error:nil];
                }
            }];
        }];
    }
    else
    {
        request = [[self httpClient] requestWithMethod:[self httpMethod]
                                                  path:[self dataPath]
                                            parameters:parameters];
    }
    
    if (_cachePolicy) {
        
    }

    if( [[self httpBody] length] > 0 ) {
        [request setHTTPBody:[[self httpBody] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues:NO]];
    return request;
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

@end
