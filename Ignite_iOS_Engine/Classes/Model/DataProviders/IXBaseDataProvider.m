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
static NSString* const kIXPredicateFormat = @"predicate.format"; //e.g. "%K CONTAINS[c] %@"
static NSString* const kIXPredicateArguments = @"predicate.arguments"; //e.g. "email,[[inputbox.text]]"
static NSString* const kIXSortOrder = @"sort.order"; //ascending, descending, none (default=none)
static NSString* const kIXSortKey = @"sort.key"; //dataRow key to sort on
static NSString* const kIXDataBaseUrl = @"data.baseurl";
static NSString* const kIXDataPath = @"data.path";
static NSString* const kIXAutoLoad = @"auto_load";
static NSString* const kIXAuthType = @"auth_type";
static NSString* const kIXCacheID = @"cache_id";

// kIXAuthType Types
static NSString* const kIX_AuthType_Basic = @"basic";

static NSString* const kIXBasicUserName = @"basic.username";
static NSString* const kIXBasicPassword = @"basic.password";

static NSString* const kIX_AuthType_OAuth2 = @"oauth2";

static NSString* const kIXOAuthClientID = @"oauth.client_id";
static NSString* const kIXOAuthSecret = @"oauth.secret";
static NSString* const kIXOAuthTokenStorageID = @"oauth.storage_id";
static NSString* const kIXOAuthGrantType = @"oauth.grant_type";
static NSString* const kIXOAuthAuthorizePath = @"oauth.authorize_path";
static NSString* const kIXOAuthAccessTokenPath = @"oauth.access_token_path";
static NSString* const kIXOAuthRedirectURI = @"oauth.redirect_uri";
static NSString* const kIXOAuthScope = @"oauth.scope";

// IXBaseDataProvider Read-Only Properties
static NSString* const kIXRawDataResponse = @"raw_data_response";
static NSString* const kIXStatusCode = @"status_code";
static NSString* const kIXErrorMessage = @"error_message";
static NSString* const kIXCount = @"count";
static NSString* const kIXAccessToken = @"access_token";

// IXBaseDataProvider Functions
static NSString* const kIXClearAccessToken = @"clear_access_token"; // kIXOAuthTokenStorageID is the parameter for this.
static NSString* const kIXClearCache = @"clear_cache"; // Clears the cached data that is associated with this data providers kIXCacheID.
static NSString* const kIXDeleteCookies = @"delete_cookies"; // kIXCookieURL is the parameter for this function.
static NSString* const kIXCookieURL = @"cookie_url";

// IXBaseDataProvider Events
static NSString* const kIXStarted = @"started";
static NSString* const kIXAuthSuccess = @"auth_success";
static NSString* const kIXAuthFail = @"auth_fail";

// Non Property constants.
static NSString* const kIX_Default_RedirectURI = @"ix://callback:oauth";
static NSCache* sIXDataProviderCache = nil;

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

@property (nonatomic,assign) BOOL isFirstLoad;
@property (nonatomic,assign) BOOL isLocalPath;
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
        [sIXDataProviderCache setName:@"com.ignite.DataProviderCache"];
    });
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
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    [self setCacheID:[[self propertyContainer] getStringPropertyValue:kIXCacheID defaultValue:nil]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    [self setObjectsPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setPredicateFormat:[[self propertyContainer] getStringPropertyValue:kIXPredicateFormat defaultValue:nil]];
    [self setPredicateArguments:[[self propertyContainer] getStringPropertyValue:kIXPredicateArguments defaultValue:nil]];
    [self setSortDescriptorKey:[[self propertyContainer] getStringPropertyValue:kIXSortKey defaultValue:nil]];
    [self setSortOrder:[[self propertyContainer] getStringPropertyValue:kIXSortOrder defaultValue:@"none"]];
    
    [self setIsLocalPath:[IXPathHandler pathIsLocal:[self dataLocation]]];
    
    [self setAuthType:[[self propertyContainer] getStringPropertyValue:kIXAuthType defaultValue:nil]];
    if( ![self isLocalPath] )
    {
        if( [self httpClient] == nil || ![[[[self httpClient] baseURL] absoluteString] isEqualToString:[self dataLocation]] )
        {
            NSURL* baseURL = [NSURL URLWithString:[self dataLocation]];
            if( [[self authType] isEqualToString:kIX_AuthType_OAuth2] )
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
        
        if( [[self authType] isEqualToString:kIX_AuthType_OAuth2] )
        {
            [self setOAuthTokenStorageID:[[self propertyContainer] getStringPropertyValue:kIXOAuthTokenStorageID defaultValue:nil]];
            [self setOAuthGrantType:[[self propertyContainer] getStringPropertyValue:kIXOAuthGrantType defaultValue:nil]];
            [self setOAuthAuthorizePath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAuthorizePath defaultValue:nil]];
            [self setOAuthAccessTokenPath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAccessTokenPath defaultValue:nil]];
            [self setOAuthScope:[[self propertyContainer] getStringPropertyValue:kIXOAuthScope defaultValue:nil]];
            [self setOAuthRedirectURI:[[self propertyContainer] getStringPropertyValue:kIXOAuthRedirectURI defaultValue:kIX_Default_RedirectURI]];
        }
        else if( [[self authType] isEqualToString:kIX_AuthType_Basic] )
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
    [self fireLoadFinishedEvents:@[kIXAuthFail] shouldCacheResponse:NO];
    
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
                                             [weakSelf fireLoadFinishedEvents:@[kIXAuthFail] shouldCacheResponse:NO];
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
        returnValue = [NSString stringWithFormat:@"%li",(long)[self getRowCount]];
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

-(NSSortDescriptor*)sortDescriptor
{
    NSSortDescriptor* sortDescriptor = nil;
    if( [[self sortDescriptorKey] length] > 0 && ![[self sortOrder] isEqualToString:@"none"])
    {
        BOOL sortAscending = YES;
        if ([self.sortOrder isEqualToString:@"descending"])
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

-(NSUInteger)getRowCount
{
    return 0;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath
{
    return nil;
}

@end
