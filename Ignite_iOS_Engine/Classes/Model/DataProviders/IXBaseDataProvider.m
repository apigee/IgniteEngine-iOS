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
#import "IXTableView.h"
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

// IXBaseDataProvider Properties
IX_STATIC_CONST_STRING kIXDataBaseUrl = @"data.baseurl";
IX_STATIC_CONST_STRING kIXDataPath = @"data.path";
IX_STATIC_CONST_STRING kIXDataRowBasePath = @"datarow.basepath";
IX_STATIC_CONST_STRING kIXAutoLoad = @"auto_load";
IX_STATIC_CONST_STRING kIXAuthType = @"auth_type";
IX_STATIC_CONST_STRING kIXCacheID = @"cache_id";
IX_STATIC_CONST_STRING kIXHTTPMethod = @"http_method";
IX_STATIC_CONST_STRING kIXBasicUserName = @"basic.username";
IX_STATIC_CONST_STRING kIXBasicPassword = @"basic.password";
IX_STATIC_CONST_STRING kIXParameterEncoding = @"parameter_encoding";
IX_STATIC_CONST_STRING kIXParseParametsAsObject = @"parse_parameters_as_object";
IX_STATIC_CONST_STRING kIXAcceptedContentType = @"accepted_content_type";
IX_STATIC_CONST_STRING kIXPredicateFormat = @"predicate.format";            //e.g. "%K CONTAINS[c] %@"
IX_STATIC_CONST_STRING kIXPredicateArguments = @"predicate.arguments";      //e.g. "email,[[inputbox.text]]"
IX_STATIC_CONST_STRING kIXSortOrder = @"sort.order";
IX_STATIC_CONST_STRING kIXSortKey = @"sort.key";                            //dataRow key to sort on
IX_STATIC_CONST_STRING kIXOAuthClientID = @"oauth.client_id";
IX_STATIC_CONST_STRING kIXOAuthSecret = @"oauth.secret";
IX_STATIC_CONST_STRING kIXOAuthTokenStorageID = @"oauth.storage_id";
IX_STATIC_CONST_STRING kIXOAuthGrantType = @"oauth.grant_type";
IX_STATIC_CONST_STRING kIXOAuthAuthorizePath = @"oauth.authorize_path";
IX_STATIC_CONST_STRING kIXOAuthAccessTokenPath = @"oauth.access_token_path";
IX_STATIC_CONST_STRING kIXOAuthRedirectURI = @"oauth.redirect_uri";
IX_STATIC_CONST_STRING kIXOAuthScope = @"oauth.scope";

// kIXSortOrder Accepted Types
IX_STATIC_CONST_STRING kIXSortOrderNone = @"none";
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending";
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending";

// kIXAuthType Accepted Types
IX_STATIC_CONST_STRING kIXAuthTypeBasic = @"basic";
IX_STATIC_CONST_STRING kIXAuthTypeOAuth2 = @"oauth2";

// kIXParameterEncoding Accepted Types
IX_STATIC_CONST_STRING kIXParameterEncodingJSON = @"json";
IX_STATIC_CONST_STRING kIXParameterEncodingPList = @"plist";
IX_STATIC_CONST_STRING kIXParameterEncodingForm = @"form";

// IXBaseDataProvider Read-Only Properties
IX_STATIC_CONST_STRING kIXRawDataResponse = @"raw_data_response";
IX_STATIC_CONST_STRING kIXStatusCode = @"status_code";
IX_STATIC_CONST_STRING kIXErrorMessage = @"error_message";
IX_STATIC_CONST_STRING kIXCount = @"count";
IX_STATIC_CONST_STRING kIXAccessToken = @"access_token";

// IXBaseDataProvider Functions
IX_STATIC_CONST_STRING kIXClearAccessToken = @"clear_access_token"; // kIXOAuthTokenStorageID is the parameter for this.
IX_STATIC_CONST_STRING kIXClearCache = @"clear_cache"; // Clears the cached data that is associated with this data providers kIXCacheID.
IX_STATIC_CONST_STRING kIXDeleteCookies = @"delete_cookies"; // kIXCookieURL is the parameter for this function.
IX_STATIC_CONST_STRING kIXCookieURL = @"cookie_url";

// IXBaseDataProvider Events
IX_STATIC_CONST_STRING kIXStarted = @"started";
IX_STATIC_CONST_STRING kIXAuthSuccess = @"auth_success";
IX_STATIC_CONST_STRING kIXAuthFail = @"auth_fail";

// Non Property constants.
IX_STATIC_CONST_STRING kIX_Default_RedirectURI = @"ix://callback:oauth";
IX_STATIC_CONST_STRING KIXDataProviderCacheName = @"com.ignite.DataProviderCache";
IX_STATIC_CONST_STRING kIXDataRow = @"dataRow.";
IX_STATIC_CONST_STRING kIXTotal = @"total.";
static NSCache* sIXDataProviderCache = nil;

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXRequestParameterPropertiesNSCodingKey = @"requestParameterProperties";
IX_STATIC_CONST_STRING kIXRequestHeaderPropertiesNSCodingKey = @"requestHeaderProperties";
IX_STATIC_CONST_STRING kIXFileAttachmentPropertiesNSCodingKey = @"fileAttachmentProperties";

@interface IXImage ()
@property (nonatomic,strong) UIImage* defaultImage;
@end

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

@property (nonatomic,copy) NSString* cacheID;

@property (nonatomic,strong) AFHTTPRequestOperation* requestToEnqueAfterAuthentication;

@property (nonatomic,strong) IXOAuthWebAuthViewController* oAuthWebAuthViewController;
@property (nonatomic,strong) AFOAuthCredential* oAuthCredential;

@property (nonatomic,copy) NSString* oAuthClientID;
@property (nonatomic,copy) NSString* oAuthSecret;
@property (nonatomic,copy) NSString* oAuthTokenStorageID;
@property (nonatomic,copy) NSString* oAuthGrantType;
@property (nonatomic,copy) NSString* oAuthAuthorizePath;
@property (nonatomic,copy) NSString* oAuthAccessTokenPath;
@property (nonatomic,copy) NSString* oAuthRedirectURI;
@property (nonatomic,copy) NSString* oAuthScope;

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
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    [self setCacheID:[[self propertyContainer] getStringPropertyValue:kIXCacheID defaultValue:nil]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    [self setDataPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setDataRowBasePath:[[self propertyContainer] getStringPropertyValue:kIXDataRowBasePath defaultValue:nil]];
    [self setPredicateFormat:[[self propertyContainer] getStringPropertyValue:kIXPredicateFormat defaultValue:nil]];
    [self setPredicateArguments:[[self propertyContainer] getStringPropertyValue:kIXPredicateArguments defaultValue:nil]];
    [self setSortDescriptorKey:[[self propertyContainer] getStringPropertyValue:kIXSortKey defaultValue:nil]];
    [self setSortOrder:[[self propertyContainer] getStringPropertyValue:kIXSortOrder defaultValue:kIXSortOrderNone]];
    [self setAcceptedContentType:[[self propertyContainer] getStringPropertyValue:kIXAcceptedContentType defaultValue:nil]];

    [self setIsLocalPath:[IXPathHandler pathIsLocal:[self dataLocation]]];
    
    [self setAuthType:[[self propertyContainer] getStringPropertyValue:kIXAuthType defaultValue:nil]];
    if( ![self isLocalPath] )
    {
        if( [self httpClient] == nil || ![[[[self httpClient] baseURL] absoluteString] isEqualToString:[self dataLocation]] )
        {
            NSURL* baseURL = [NSURL URLWithString:[self dataLocation]];
            if( [[self authType] isEqualToString:kIXAuthTypeOAuth2] )
            {
                [self setOAuthClientID:[[self propertyContainer] getStringPropertyValue:kIXOAuthClientID defaultValue:nil]];
                [self setOAuthSecret:[[self propertyContainer] getStringPropertyValue:kIXOAuthSecret defaultValue:nil]];
                
                AFOAuth2Client* oauth2Client = [AFOAuth2Client clientWithBaseURL:baseURL clientID:[self oAuthClientID] secret:[self oAuthSecret]];
                [self setHttpClient:oauth2Client];
            }
            else
            {
                [self setHttpClient:[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[self dataLocation]]]];
            }
        }
        
        AFHTTPClientParameterEncoding paramEncoding = AFJSONParameterEncoding;
        NSString* parameterEncoding = [[self propertyContainer] getStringPropertyValue:kIXParameterEncoding defaultValue:kIXParameterEncodingJSON];
        if( [parameterEncoding isEqualToString:kIXParameterEncodingForm] ) {
            paramEncoding = AFFormURLParameterEncoding;
        } else if( [parameterEncoding isEqualToString:kIXParameterEncodingPList] ) {
            paramEncoding = AFPropertyListParameterEncoding;
        }
        
        [[self httpClient] setParameterEncoding:paramEncoding];
        
        if( [[self authType] isEqualToString:kIXAuthTypeOAuth2] )
        {
            [self setOAuthTokenStorageID:[[self propertyContainer] getStringPropertyValue:kIXOAuthTokenStorageID defaultValue:nil]];
            [self setOAuthGrantType:[[self propertyContainer] getStringPropertyValue:kIXOAuthGrantType defaultValue:nil]];
            [self setOAuthAuthorizePath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAuthorizePath defaultValue:nil]];
            [self setOAuthAccessTokenPath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAccessTokenPath defaultValue:nil]];
            [self setOAuthScope:[[self propertyContainer] getStringPropertyValue:kIXOAuthScope defaultValue:nil]];
            [self setOAuthRedirectURI:[[self propertyContainer] getStringPropertyValue:kIXOAuthRedirectURI defaultValue:kIX_Default_RedirectURI]];
        }
        else if( [[self authType] isEqualToString:kIXAuthTypeBasic] )
        {
            NSString* userName = [[self propertyContainer] getStringPropertyValue:kIXBasicUserName defaultValue:nil];
            NSString* password = [[self propertyContainer] getStringPropertyValue:kIXBasicPassword defaultValue:nil];

            [[self httpClient] clearAuthorizationHeader];
            
            if( [userName length] > 0 && [password length] > 0 )
            {
                [[self httpClient] setAuthorizationHeaderWithUsername:userName password:password];
            }
        }
    }
    else
    {
        [self setDataLocation:[[self propertyContainer] getPathPropertyValue:kIXDataBaseUrl basePath:nil defaultValue:nil]];
    }
}

-(void)loadData:(BOOL)forceGet
{
    if( [self cacheID] != nil )
    {
        NSString* cachedResponse = [sIXDataProviderCache objectForKey:[self cacheID]];
        if( [cachedResponse length] > 0 )
        {
            [self setRawResponse:cachedResponse];
            [self fireLoadFinishedEventsFromCachedResponse];
        }
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXStarted];
}

-(NSString*)buildAccessCodeURL
{
    NSMutableString* accessCodeURLString = [NSMutableString stringWithString:[[self dataLocation] stringByAppendingString:[self oAuthAuthorizePath]]];
    [accessCodeURLString appendString:@"?response_type=code"];
    if( [[self oAuthClientID] length] > 0 )
        [accessCodeURLString appendFormat:@"&%@=%@",@"client_id",[self oAuthClientID]];
    if( [[self oAuthScope] length] > 0 )
        [accessCodeURLString appendFormat:@"&%@=%@",@"scope",[self oAuthScope]];
    if( [[self oAuthGrantType] length] > 0 )
        [accessCodeURLString appendFormat:@"&%@=%@",@"grant_type",[self oAuthGrantType]];
    if( [[self oAuthRedirectURI] length] > 0 )
        [accessCodeURLString appendFormat:@"&%@=%@",@"redirect_uri",[self oAuthRedirectURI]];
    
    return accessCodeURLString;
}

-(void)authenticateAndEnqueRequestOperation:(AFHTTPRequestOperation*)requestOperation
{
    if( [[self httpClient] isKindOfClass:[AFOAuth2Client class]] )
    {
        requestOperation = nil;
        
        AFOAuth2Client* oauth2Client = (AFOAuth2Client*)[self httpClient];
        BOOL foundValidStoredCredential = NO;
        NSString* storageID = [self oAuthTokenStorageID];
        if( [storageID length] > 0 )
        {
            AFOAuthCredential* storedCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:storageID];
            if( storedCredential )
            {
                if( [storedCredential isExpired] )
                {
                    __weak typeof(self) weakSelf = self;
                    __weak typeof(oauth2Client) weakOAuth2Client = oauth2Client;

                    AFHTTPClientParameterEncoding paramEncoding = [oauth2Client parameterEncoding];
                    [oauth2Client setParameterEncoding:AFFormURLParameterEncoding];

                    [oauth2Client authenticateUsingOAuthWithPath:[self oAuthAccessTokenPath]
                                                    refreshToken:[storedCredential refreshToken]
                                                         success:^(AFOAuthCredential *credential) {
                                                             
                                                             [weakOAuth2Client setParameterEncoding:paramEncoding];
                                                             [weakSelf setOAuthCredential:credential];
                                                             
                                                             IX_LOG_VERBOSE(@"%@ : Did refresh access token for dataprovider with ID :%@ accessToken : %@",THIS_FILE,[weakSelf ID],[credential accessToken]);
                                                             
                                                             if( [storageID length] > 0 )
                                                             {
                                                                 [AFOAuthCredential storeCredential:credential withIdentifier:storageID];
                                                             }
                                                             
                                                             [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                                                             
                                                             if( requestOperation )
                                                             {
                                                                 [weakOAuth2Client enqueueHTTPRequestOperation:requestOperation];
                                                             }
                                                             
                                                         } failure:^(NSError *error) {
                                                             
                                                             [AFOAuthCredential deleteCredentialWithIdentifier:storageID];
                                                             [weakOAuth2Client setParameterEncoding:paramEncoding];
                                                             [weakSelf authenticateAndEnqueRequestOperation:requestOperation];
                                                             
                                                         }];
                    return;
                }
                else
                {
                    foundValidStoredCredential = YES;
                    [self setOAuthCredential:storedCredential];
                    [oauth2Client setAuthorizationHeaderWithCredential:storedCredential];
                    
                    [self setRequestToEnqueAfterAuthentication:nil];
                    [[self actionContainer] executeActionsForEventNamed:kIXAuthSuccess];

                    if( requestOperation )
                    {
                        [oauth2Client enqueueHTTPRequestOperation:requestOperation];
                    }
                }
            }
        }
        
        if( !foundValidStoredCredential && [self oAuthWebAuthViewController] == nil )
        {
            NSString* accessCodeURLString = [self buildAccessCodeURL];
            NSURL* accessCodeURL = [NSURL URLWithString:accessCodeURLString];
            NSURL* redirectURI = [NSURL URLWithString:[self oAuthRedirectURI]];
            
            IXOAuthWebAuthViewController* oauthWebAuthViewController = [[IXOAuthWebAuthViewController alloc] initWithDelegate:self
                                                                                                                accessCodeURL:accessCodeURL
                                                                                                                  redirectURI:redirectURI];
            if( [UIViewController isOkToPresentViewController:oauthWebAuthViewController] )
            {
                [self setRequestToEnqueAfterAuthentication:requestOperation];
                [self setOAuthWebAuthViewController:oauthWebAuthViewController];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[IXAppManager sharedAppManager] rootViewController] presentViewController:[self oAuthWebAuthViewController]
                                                                                       animated:YES
                                                                                     completion:nil];
                });
            }
        }
    }
    else
    {
        [self setRequestToEnqueAfterAuthentication:nil];
        [[self httpClient] enqueueHTTPRequestOperation:requestOperation];
    }
}

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                    didFailWithError:(NSError *)error;
{
    [self setRequestToEnqueAfterAuthentication:nil];
    [self setLastResponseErrorMessage:[error description]];
    [[self actionContainer] executeActionsForEventNamed:kIXAuthFail];
    [self fireLoadFinishedEvents:NO shouldCacheResponse:NO];
    
    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                didRecieveOAuthCode:(NSString *)accessCode
{
    AFOAuth2Client* oAuth2Client = (AFOAuth2Client*)[self httpClient];
    AFHTTPRequestOperation* requestOperation = [self requestToEnqueAfterAuthentication];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(oAuth2Client) weakOAuth2Client = oAuth2Client;
    
    NSString* oauthStorageID = [self oAuthTokenStorageID];

    AFHTTPClientParameterEncoding paramEncoding = [[self httpClient] parameterEncoding];
    [[self httpClient] setParameterEncoding:AFFormURLParameterEncoding];
    
    [oAuth2Client authenticateUsingOAuthWithPath:[self oAuthAccessTokenPath]
                                            code:accessCode
                                     redirectURI:[self oAuthRedirectURI]
                                         success:^(AFOAuthCredential *credential) {
                                            
                                             [[weakSelf httpClient] setParameterEncoding:paramEncoding];
                                             [weakSelf setOAuthCredential:credential];
                                             [weakSelf setRequestToEnqueAfterAuthentication:nil];

                                             IX_LOG_VERBOSE(@"%@ : Did recieve access token for dataprovider with ID :%@ accessToken : %@",THIS_FILE,[weakSelf ID],[credential accessToken]);
                                             
                                             if( [oauthStorageID length] > 0 )
                                             {
                                                 [AFOAuthCredential storeCredential:credential withIdentifier:oauthStorageID];
                                             }
                                             
                                             [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                                             
                                             if( requestOperation )
                                             {
                                                 [weakOAuth2Client enqueueHTTPRequestOperation:requestOperation];
                                             }

                                         } failure:^(NSError *error) {
                                            
                                             [[weakSelf httpClient] setParameterEncoding:paramEncoding];
                                             [weakSelf setRequestToEnqueAfterAuthentication:nil];
                                             [weakSelf setLastResponseErrorMessage:[error description]];
                                             [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthFail];
                                             [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                                        }];
    
    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)fireLoadFinishedEventsFromCachedResponse
{
    [self fireLoadFinishedEvents:YES shouldCacheResponse:NO];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse
{
    if( loadDidSucceed )
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_SUCCESS];
    }
    else
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_FAILED];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIX_FINISHED];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                            object:self];
    });

    if( loadDidSucceed && shouldCacheResponse )
    {
        if ( [[self cacheID] length] > 0 && [[self rawResponse] length] > 0 )
        {
            [sIXDataProviderCache setObject:[self rawResponse]
                                     forKey:[self cacheID]];
        }
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXRawDataResponse] )
    {
        returnValue = [[self rawResponse] copy];
    }
    else if( [propertyName hasPrefix:kIXDataRow] )
    {
        NSString* remainingKeyPathString = [propertyName stringByReplacingOccurrencesOfString:kIXDataRow withString:kIX_EMPTY_STRING];
        if( [remainingKeyPathString length] > 0 )
        {
            if( [remainingKeyPathString isEqualToString:kIXRawDataResponse] )
            {
                returnValue = [self rowDataRawJSONResponse];
            }
            else if( [remainingKeyPathString hasPrefix:kIXTotal] )
            {
                remainingKeyPathString = [remainingKeyPathString stringByReplacingOccurrencesOfString:kIXTotal withString:kIX_EMPTY_STRING];
                if( [remainingKeyPathString length] > 0 )
                {
                    returnValue = [self rowDataTotalForKeyPath:remainingKeyPathString];
                }
            }
        }
    }
    else if( [propertyName isEqualToString:kIXStatusCode] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self lastResponseStatusCode]];
    }
    else if( [propertyName isEqualToString:kIXErrorMessage] )
    {
        returnValue = [[self lastResponseErrorMessage] copy];
    }
    else if( [propertyName isEqualToString:kIXCount] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self rowCount]];
    }
    else if( [propertyName isEqualToString:kIXAccessToken] )
    {
        returnValue = [[[self oAuthCredential] accessToken] copy];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXClearAccessToken] )
    {
        NSString* tokenStorageID = [parameterContainer getStringPropertyValue:kIXOAuthTokenStorageID defaultValue:nil];
        if( [tokenStorageID length] > 0 )
        {
            [AFOAuthCredential deleteCredentialWithIdentifier:tokenStorageID];
        }
    }
    else if( [functionName isEqualToString:kIXClearCache] )
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

-(NSURLRequest*)urlRequest
{
    NSMutableURLRequest* request = nil;
    
    NSMutableDictionary* dictionaryOfFiles = [NSMutableDictionary dictionaryWithDictionary:[[self fileAttachmentProperties] getAllPropertiesURLValues]];
    [dictionaryOfFiles removeObjectsForKeys:@[@"image.id",@"image.name",@"image.mimeType",@"image.jpegCompression"]];
    
    NSDictionary* parameters = nil;
    if( [[self propertyContainer] getBoolPropertyValue:kIXParseParametsAsObject defaultValue:YES] )
    {
        parameters = [[self requestParameterProperties] getAllPropertiesObjectValues];
    }
    else
    {
        parameters = [[self requestParameterProperties] getAllPropertiesStringValues];
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
    [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues]];
    return request;
}

-(NSSortDescriptor*)sortDescriptor
{
    NSSortDescriptor* sortDescriptor = nil;
    if( [[self sortDescriptorKey] length] > 0 && ![[self sortOrder] isEqualToString:kIXSortOrderNone])
    {
        BOOL sortAscending = YES;
        if ([self.sortOrder isEqualToString:kIXSortOrderDescending])
            sortAscending = NO;
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self sortDescriptorKey]
                                                       ascending:sortAscending
                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return sortDescriptor;
}

-(NSPredicate*)predicate
{
    NSPredicate* predicate = nil;
    @try {
        NSArray* predicateArgumentsArray = [[self predicateArguments] componentsSeparatedByString:kIX_COMMA_SEPERATOR];
        if( [[self predicateFormat] length] > 0 && [predicateArgumentsArray count] > 0 )
        {
            predicate = [NSPredicate predicateWithFormat:[self predicateFormat] argumentArray:predicateArgumentsArray];
            IX_LOG_VERBOSE(@"%@ : PREDICATE EQUALS : %@",THIS_FILE,[predicate description]);
        }
        return predicate;
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR - BAD PREDICATE: %@", exception);
        return nil;
    }
    
}

-(NSUInteger)rowCount
{
    return 0;
}

-(NSString*)rowDataRawJSONResponse
{
    return nil;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath
{
    return nil;
}

-(NSString*)rowDataTotalForKeyPath:(NSString*)keyPath
{
    NSInteger rowCount = [self rowCount];
    NSDecimalNumber* rowTotal = [NSDecimalNumber zero];
    for( int i = 0; i < rowCount; i++ )
    {
        NSString* rowDataForIndex = [self rowDataForIndexPath:[NSIndexPath indexPathForRow:i inSection:0] keyPath:keyPath];
        if( rowDataForIndex )
        {
            NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:rowDataForIndex];
            if( decimalNumber != nil )
            {
                rowTotal = [rowTotal decimalNumberByAdding:decimalNumber];
            }
        }
    }
    return [rowTotal stringValue];
}

@end
