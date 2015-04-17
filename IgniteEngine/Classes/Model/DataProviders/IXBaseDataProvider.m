//
//  IXBaseDataProvider.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseDataProvider.h"

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
#import "NSDictionary+IXAdditions.h"

//#import <RestKit/RestKit.h>

NSString* IXBaseDataProviderDidUpdateNotification = @"IXBaseDataProviderDidUpdateNotification";

// IXBaseDataProvider Attributes
IX_STATIC_CONST_STRING kIXAutoLoad = @"autoLoad.enabled";
IX_STATIC_CONST_STRING kIXUrl = @"url";
IX_STATIC_CONST_STRING kIXUrlEncodeParams = @"urlEncodeParams.enabled"; // When enabled, url-encodes query params
IX_STATIC_CONST_STRING kIXDeriveValueTypes = @"deriveValueTypes.enabled"; // Default=true; parses POST/PUT body JSON number and bool values
IX_STATIC_CONST_STRING kIXRequestType = @"requestType"; // must match counterpart in HTTPDP

// IXBaseDataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXRequestTypeJSON = @"json"; // kIXBodyEncoding - must match counterpart in HTTPDP

// IXBaseDataProvider Functions
IX_STATIC_CONST_STRING kIXDeleteCookies = @"deleteCookies"; // kIXCookieURL is the parameter for this function.
IX_STATIC_CONST_STRING kIXCookieURL = @"url"; // Function parameter for deleteCookies

// IXBaseDataProvider Events
IX_STATIC_CONST_STRING kIXStarted = @"began";

// TODO: These are not used?
//IX_STATIC_CONST_STRING kIXAuthSuccess = @"auth.success";
//IX_STATIC_CONST_STRING kIXAuthFail = @"auth.error";


// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXRequestBodyObjectNSCodingKey = @"requestBodyObject";
IX_STATIC_CONST_STRING kIXRequestQueryParamsObjectNSCodingKey = @"requestQueryParamsObject";
IX_STATIC_CONST_STRING kIXRequestHeadersObjectNSCodingKey = @"requestHeadersObject";
IX_STATIC_CONST_STRING kIXFileAttachmentObjectNSCodingKey = @"fileAttachmentObject";

@interface IXImage ()

@property (nonatomic,strong) UIImage* defaultImage;

@end

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

//@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
//@property (nonatomic,assign,getter = shouldUrlEncodeParams) BOOL urlEncodeParams;
//@property (nonatomic,assign,getter = shouldDeriveValueTypes) BOOL deriveValueTypes;
//@property (nonatomic,assign,getter = isPathLocal)    BOOL pathIsLocal;

//@property (nonatomic,copy) NSString* method;
//@property (nonatomic,copy) NSString* body;
//@property (nonatomic,copy) NSString* queryParams;
////@property (nonatomic,copy) NSString* fullDataLocation;
//@property (nonatomic,copy) NSString* url;

//@property (nonatomic,copy) NSString* dataPath;

@end

@implementation IXBaseDataProvider
@synthesize body = _body;
@synthesize queryParams = _queryParams;

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

-(id)copyWithZone:(NSZone *)zone
{
    IXBaseDataProvider *copiedDataProvider = [super copyWithZone:zone];
    [copiedDataProvider setQueryParamsProperties:[[self queryParamsProperties] copy]];
    [copiedDataProvider setBodyProperties:[[self bodyProperties] copy]];
    [copiedDataProvider setHeadersProperties:[[self headersProperties] copy]];
    [copiedDataProvider setFileAttachmentProperties:[[self fileAttachmentProperties] copy]];
    return copiedDataProvider;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self queryParamsProperties] forKey:kIXRequestQueryParamsObjectNSCodingKey];
    [aCoder encodeObject:[self bodyProperties] forKey:kIXRequestBodyObjectNSCodingKey];
    [aCoder encodeObject:[self headersProperties] forKey:kIXRequestHeadersObjectNSCodingKey];
    [aCoder encodeObject:[self fileAttachmentProperties] forKey:kIXFileAttachmentObjectNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setQueryParamsProperties:[aDecoder decodeObjectForKey:kIXRequestQueryParamsObjectNSCodingKey]];
        [self setBodyProperties:[aDecoder decodeObjectForKey:kIXRequestBodyObjectNSCodingKey]];
        [self setHeadersProperties:[aDecoder decodeObjectForKey:kIXRequestHeadersObjectNSCodingKey]];
        [self setFileAttachmentProperties:[aDecoder decodeObjectForKey:kIXFileAttachmentObjectNSCodingKey]];
    }
    return self;
}

-(void)setHeadersProperties:(IXPropertyContainer *)headersProperties
{
    _headersProperties = headersProperties;
    [_headersProperties setOwnerObject:self];
}

-(void)setQueryParamsProperties:(IXPropertyContainer *)queryParamsProperties
{
    _queryParamsProperties = queryParamsProperties;
    [_queryParamsProperties setOwnerObject:self];
}

-(void)setBodyProperties:(IXPropertyContainer *)bodyProperties
{
    _bodyProperties = bodyProperties;
    [_bodyProperties setOwnerObject:self];
}

-(void)setFileAttachmentProperties:(IXPropertyContainer *)fileAttachmentProperties
{
    _fileAttachmentProperties = fileAttachmentProperties;
    [fileAttachmentProperties setOwnerObject:self];
}

-(void)applySettings
{
    [super applySettings];

    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    NSString* url = [[self propertyContainer] getPathPropertyValue:kIXUrl basePath:nil defaultValue:nil];
    [self setUrl:url];
    [self setPathIsLocal:[IXPathHandler pathIsLocal:url]];
    [self setUrlEncodeParams:[[self propertyContainer] getBoolPropertyValue:kIXUrlEncodeParams defaultValue:YES]];
    [self setDeriveValueTypes:[[self propertyContainer] getBoolPropertyValue:kIXDeriveValueTypes defaultValue:YES]];
    [self setBody:[_bodyProperties getAllPropertiesObjectValues:NO] ?: @{}];
    [self setQueryParams:[_queryParamsProperties getAllPropertiesObjectValues:_urlEncodeParams] ?: @{}];
}

-(void)setBody:(NSDictionary *)body
{
    @try {
        NSString* bodyString = [[self propertyContainer] getStringPropertyValue:kIX_DP_BODY defaultValue:nil];
        if (body) {
            _body = body;
        } else if (bodyString) {
            NSError* __autoreleasing error = nil;
            _body = [NSJSONSerialization JSONObjectWithData:[bodyString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error] ?: nil;
        }
        if (_deriveValueTypes && [[[self propertyContainer] getStringPropertyValue:kIXRequestType defaultValue:nil] isEqualToString:kIXRequestTypeJSON]) {
            _body = [NSDictionary ix_dictionaryWithParsedValuesFromDictionary:_body];
        }
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: 'body' included with request was not a valid JSON object or string: %@", body);
    }
}

-(void)setQueryParams:(NSDictionary *)queryParams
{
    @try {
        NSString* queryParamsString = [[self propertyContainer] getStringPropertyValue:kIX_DP_QUERYPARAMS defaultValue:nil];
        if (queryParams) {
            _queryParams = queryParams;
        } else if (queryParamsString) {
            _queryParams = [NSDictionary ix_dictionaryFromQueryParamsString:queryParamsString];
        }
//        else {
//            _queryParams = @{};
//        }
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: 'queryParams' included with request was not a valid JSON object or string: %@", queryParams);
    }
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
    returnValue = [super getReadOnlyPropertyValue:propertyName];
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXDeleteCookies] )
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



//- (void)loadDataFromLocalPath {
//    
//}

-(void)loadData:(BOOL)forceGet
{
    [self loadData:forceGet paginationKey:nil];
}

-(void)loadData:(BOOL)forceGet paginationKey:(NSString *)paginationKey
{
    [[self actionContainer] executeActionsForEventNamed:kIXStarted];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed paginationKey:(NSString *)paginationKey
{
    [[self actionContainer] executeActionsForEventNamed:(loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED];
    [[self actionContainer] executeActionsForEventNamed:kIX_DONE];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                            object:self];
    });
}



+(void)clearAllCachedResponses
{
    NSURLCache* cache =[NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
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



@end
