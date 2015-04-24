//
//  IXOAuth2DataProvider.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/12/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXOAuth2DataProvider.h"

#import "UIViewController+IXAdditions.h"
#import "NSDictionary+IXAdditions.h"
#import "AFHTTPRequestSerializer+OAuth2.h"

#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXOAuthWebAuthViewController.h"

#import "AFOAuth2Manager.h"

// A note of warning: A user could theoretically overwrite the OAuth authentication
// header by setting a username and password on a standard HTTP datasource. Ensure
// that when using OAuth, basic authentication is not used anywhere else.

// IXOAuth2DataProvider Attributes
IX_STATIC_CONST_STRING kIXOAuthClientID = @"oauth.client_id";
IX_STATIC_CONST_STRING kIXOAuthSecret = @"oauth.client_secret";
// TODO: Additional grant_type support for password, implicit, client credentials
IX_STATIC_CONST_STRING kIXOAuthGrantType = @"oauth.grant_type"; // currently only authorization_code is supported
IX_STATIC_CONST_STRING kIXOAuthRedirectURI = @"oauth.redirect_uri";
IX_STATIC_CONST_STRING kIXOAuthScope = @"oauth.scope";
IX_STATIC_CONST_STRING kIXOAuthResponseType = @"oauth.response_type";

IX_STATIC_CONST_STRING kIXOAuthTokenStorageID = @"storageId"; // required - this param is used to identify stored credentials

IX_STATIC_CONST_STRING kIXOAuthBaseUrl = @"baseUrl";
IX_STATIC_CONST_STRING kIXOAuthAuthorizePath = @"pathSuffix.auth";
IX_STATIC_CONST_STRING kIXOAuthAccessTokenPath = @"pathSuffix.token";

// IXOAuth2DataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXOAuthGrantTypeAuthorizationCode = @"authorization_code"; // currently only authorization_code is supported
IX_STATIC_CONST_STRING kIXOAuthResponseTypeCode = @"code";

// IXOAuth2DataProvider Read Only Attributes
IX_STATIC_CONST_STRING kIXAccessToken = @"token";

// IXOAuth2DataProvider Functions
IX_STATIC_CONST_STRING kIXClearAccessToken = @"destroyToken"; // kIXOAuthTokenStorageID is the parameter for this.

// IXOAuth2DataProvider Events
IX_STATIC_CONST_STRING kIXAuthSuccess = @"auth.success";
IX_STATIC_CONST_STRING kIXAuthFail = @"auth.fail";

@interface AFOAuth2Manager ()
@property (readwrite, nonatomic) NSString *serviceProviderIdentifier;
@property (readwrite, nonatomic) NSString *clientID;
@property (readwrite, nonatomic) NSString *secret;
@end


@interface IXOAuth2DataProvider ()  <IXOAuthWebAuthViewControllerDelegate>

@property (nonatomic,strong) IXOAuthWebAuthViewController* oAuthWebAuthViewController;
@property (nonatomic,strong) AFOAuthCredential* oAuthCredential;

@property (nonatomic,copy) NSString* oAuthBaseUrl;
@property (nonatomic,copy) NSString* oAuthClientID;
@property (nonatomic,copy) NSString* oAuthClientSecret;
@property (nonatomic,copy) NSString* oAuthTokenStorageID;
@property (nonatomic,copy) NSString* oAuthGrantType;
@property (nonatomic,copy) NSString* oAuthAuthorizePath;
@property (nonatomic,copy) NSString* oAuthAccessTokenPath;
@property (nonatomic,copy) NSString* oAuthRedirectURI;
@property (nonatomic,copy) NSString* oAuthScope;
@property (nonatomic,copy) NSString* oAuthResponseType;
@property (nonatomic,strong) AFOAuth2Manager *OAuth2Manager;

@end

// Non Property constants
IX_STATIC_CONST_STRING kIX_Default_RedirectURI = @"ix://callback:oauth";


@implementation IXOAuth2DataProvider

-(void)applySettings
{
    [self setOAuthBaseUrl:[[self propertyContainer] getStringPropertyValue:kIXOAuthBaseUrl defaultValue:nil]];
    [self setOAuthClientID:[[self propertyContainer] getStringPropertyValue:kIXOAuthClientID defaultValue:nil]];
    [self setOAuthClientSecret:[[self propertyContainer] getStringPropertyValue:kIXOAuthSecret defaultValue:nil]];
    [self setOAuthTokenStorageID:[[self propertyContainer] getStringPropertyValue:kIXOAuthTokenStorageID defaultValue:nil]];
    [self setOAuthGrantType:[[self propertyContainer] getStringPropertyValue:kIXOAuthGrantType defaultValue:kIXOAuthGrantTypeAuthorizationCode]];
    [self setOAuthAuthorizePath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAuthorizePath defaultValue:nil]];
    [self setOAuthAccessTokenPath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAccessTokenPath defaultValue:nil]];
    [self setOAuthScope:[[self propertyContainer] getStringPropertyValue:kIXOAuthScope defaultValue:nil]];
    [self setOAuthRedirectURI:[[self propertyContainer] getStringPropertyValue:kIXOAuthRedirectURI defaultValue:kIX_Default_RedirectURI]];
    [self setOAuthResponseType:[[self propertyContainer] getStringPropertyValue:kIXOAuthResponseType defaultValue:kIXOAuthResponseTypeCode]];

    [super applySettings];
}

-(void)createRequest
{
    self.url = self.oAuthBaseUrl;

//    BOOL needsToCreateClient = ([self httpClient] == nil || ![[self httpClient] isKindOfClass:[AFOAuth2Client class]]);
//    if( !needsToCreateClient )
//    {
//        AFOAuth2Client* oauthClient = (AFOAuth2Client*)[self httpClient];
//        needsToCreateClient = ( ![[oauthClient serviceProviderIdentifier] isEqualToString:[baseURL host]] || ![[oauthClient clientID] isEqualToString:[self oAuthClientID]] || ![[oauthClient secret] isEqualToString:[self oAuthSecret]] );
//    }
//    
//    if( needsToCreateClient )
//    {
//        AFOAuth2Client* oauth2Client = [AFOAuth2Client clientWithBaseURL:baseURL clientID:[self oAuthClientID] secret:[self oAuthSecret]];
//        [self setHttpClient:oauth2Client];
//    }
    
    
    
}

-(NSString*)url {
    return self.oAuthBaseUrl;
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
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXAccessToken] )
    {
        returnValue = [[[self oAuthCredential] accessToken] copy];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(NSString*)webViewTokenURL
{
    NSString* accessCodeURLString = [_oAuthBaseUrl stringByAppendingPathComponent:_oAuthAuthorizePath];
    
    NSMutableDictionary* params = [self.queryParams mutableCopy];
    params[kIXOAuthResponseType] = _oAuthResponseType;
    params[kIXOAuthClientID] = _oAuthClientID;
    params[kIXOAuthScope] = _oAuthScope;
    params[kIXOAuthGrantType] = _oAuthGrantType;
    params[kIXOAuthRedirectURI] = _oAuthRedirectURI;
    
    return [accessCodeURLString stringByAppendingString:[NSDictionary ix_urlEncodedQueryParamsStringFromDictionary:params]];
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    if( ![self isPathLocal] )
    {
        if (!_OAuth2Manager) {
            _OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:self.oAuthBaseUrl]
                                                             clientID:_oAuthClientID
                                                               secret:_oAuthClientSecret];
        }
        
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
                    
                    [_OAuth2Manager authenticateUsingOAuthWithURLString:_oAuthAccessTokenPath
                                                          refreshToken:storedCredential.refreshToken
                                                               success:^(AFOAuthCredential *credential) {
                                                                   IX_LOG_VERBOSE(@"%@: Did refresh access token for datasource with ID: %@ \natoken: %@",THIS_FILE,[weakSelf ID],[credential accessToken]);
                                                                   if( [storageID length] > 0 )
                                                                   {
                                                                       [AFOAuthCredential storeCredential:credential withIdentifier:storageID];
                                                                   }
                                                                   [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                                                                   [weakSelf fireLoadFinishedEvents:YES];

                                                               } failure:^(NSError *error) {
                                                                   [AFOAuthCredential deleteCredentialWithIdentifier:storageID];
                                                                   [weakSelf loadData:YES];
                                                               }];
                    return;
                }
                else
                {
                    foundValidStoredCredential = YES;
                    [self setOAuthCredential:storedCredential];
                    
                    [[IXAFHTTPSessionManager sharedManager].requestSerializer setAuthorizationHeaderFieldWithCredential:storedCredential];
                    
                    [[self actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                    [self fireLoadFinishedEvents:YES];
                }
            }
        }
        
        if( !foundValidStoredCredential && [self oAuthWebAuthViewController] == nil )
        {
            NSString* accessCodeURLString = [self webViewTokenURL];
            NSURL* accessCodeURL = [NSURL URLWithString:accessCodeURLString];
            NSURL* redirectURI = [NSURL URLWithString:[self oAuthRedirectURI]];
            
            IXOAuthWebAuthViewController* oauthWebAuthViewController = [[IXOAuthWebAuthViewController alloc] initWithDelegate:self
                                                                                                                accessCodeURL:accessCodeURL
                                                                                                                  redirectURI:redirectURI];
            if( [UIViewController isOkToPresentViewController:oauthWebAuthViewController] )
            {
                [self setOAuthWebAuthViewController:oauthWebAuthViewController];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[IXAppManager sharedAppManager] rootViewController] presentViewController:[self oAuthWebAuthViewController]
                                                                                       animated:YES
                                                                                     completion:nil];
                });
            }
        }
    }
}

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                    didFailWithError:(NSError *)error;
{
    self.response.errorMessage = error.localizedDescription;
    [[self actionContainer] executeActionsForEventNamed:kIXAuthFail];
    [self fireLoadFinishedEvents:NO];
    
    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                didRecieveOAuthToken:(NSString *)accessToken
                           tokenType:(NSString *)tokenType
                             expires:(NSDate *)expires
                        refreshToken:(NSString *)refreshToken
{
    AFOAuthCredential* credential = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:tokenType];
    if( expires != nil ) {
        [credential setRefreshToken:refreshToken expiration:expires];
    }
    [self setOAuthCredential:credential];

    IX_LOG_VERBOSE(@"%@: Did recieve access token for datasource with ID: %@ \ntoken: %@",THIS_FILE,[self ID],[credential accessToken]);

    if( [[self oAuthTokenStorageID] length] > 0 )
    {
        [AFOAuthCredential storeCredential:credential withIdentifier:[self oAuthTokenStorageID]];
    }

    [[self actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
    [self fireLoadFinishedEvents:YES];

    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)ixOAuthWebAuthViewController:(IXOAuthWebAuthViewController *)oAuthWebAuthViewController
                didRecieveOAuthCode:(NSString *)accessCode
{
    
    if (!_OAuth2Manager) {
        _OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:self.oAuthBaseUrl]
                                                         clientID:_oAuthClientID
                                                           secret:_oAuthClientSecret];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [_OAuth2Manager authenticateUsingOAuthWithURLString:_oAuthAccessTokenPath
                                                   code:accessCode
                                            redirectURI:_oAuthRedirectURI
                                                success:^(AFOAuthCredential *credential) {
                                                    [weakSelf setOAuthCredential:credential];
                                                    
                                                    IX_LOG_VERBOSE(@"%@: Did recieve access token for dataprovider with ID: %@ \ntoken: %@",THIS_FILE,[weakSelf ID],[credential accessToken]);
                                                    
                                                    if( [_oAuthTokenStorageID length] > 0 )
                                                    {
                                                        [AFOAuthCredential storeCredential:credential withIdentifier:_oAuthTokenStorageID];
                                                        [[IXAFHTTPSessionManager sharedManager].requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                                                    }
                                                    
                                                    [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                                                    [weakSelf fireLoadFinishedEvents:YES];
                                                    
                                                } failure:^(NSError *error) {
                                                    weakSelf.response.errorMessage = error.localizedDescription;
                                                    [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthFail];
                                                    [weakSelf fireLoadFinishedEvents:NO];
                                                }];
    
    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
