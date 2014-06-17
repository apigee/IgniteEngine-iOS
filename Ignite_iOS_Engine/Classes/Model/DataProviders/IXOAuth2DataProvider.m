//
//  IXOAuth2DataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/12/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXOAuth2DataProvider.h"

#import "UIViewController+IXAdditions.h"

#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXOAuthWebAuthViewController.h"

#import "AFOAuth2Client.h"

// IXOAuth2DataProvider Attributes
IX_STATIC_CONST_STRING kIXOAuthClientID = @"oauth.client_id";
IX_STATIC_CONST_STRING kIXOAuthSecret = @"oauth.secret";
IX_STATIC_CONST_STRING kIXOAuthTokenStorageID = @"oauth.storage_id";
IX_STATIC_CONST_STRING kIXOAuthGrantType = @"oauth.grant_type";
IX_STATIC_CONST_STRING kIXOAuthAuthorizePath = @"oauth.authorize_path";
IX_STATIC_CONST_STRING kIXOAuthAccessTokenPath = @"oauth.access_token_path";
IX_STATIC_CONST_STRING kIXOAuthRedirectURI = @"oauth.redirect_uri";
IX_STATIC_CONST_STRING kIXOAuthScope = @"oauth.scope";

// IXOAuth2DataProvider Read Only Attributes
IX_STATIC_CONST_STRING kIXAccessToken = @"access_token";

// IXOAuth2DataProvider Functions
IX_STATIC_CONST_STRING kIXClearAccessToken = @"clear_access_token"; // kIXOAuthTokenStorageID is the parameter for this.

// IXOAuth2DataProvider Events
IX_STATIC_CONST_STRING kIXAuthSuccess = @"auth_success";
IX_STATIC_CONST_STRING kIXAuthFail = @"auth_fail";

// Non Property constants.
IX_STATIC_CONST_STRING kIX_Default_RedirectURI = @"ix://callback:oauth";

@interface AFOAuth2Client ()
@property (readwrite, nonatomic) NSString *serviceProviderIdentifier;
@property (readwrite, nonatomic) NSString *clientID;
@property (readwrite, nonatomic) NSString *secret;
@end


@interface IXOAuth2DataProvider () <IXOAuthWebAuthViewControllerDelegate>

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

@implementation IXOAuth2DataProvider

-(void)applySettings
{
    [self setOAuthClientID:[[self propertyContainer] getStringPropertyValue:kIXOAuthClientID defaultValue:nil]];
    [self setOAuthSecret:[[self propertyContainer] getStringPropertyValue:kIXOAuthSecret defaultValue:nil]];
    [self setOAuthTokenStorageID:[[self propertyContainer] getStringPropertyValue:kIXOAuthTokenStorageID defaultValue:nil]];
    [self setOAuthGrantType:[[self propertyContainer] getStringPropertyValue:kIXOAuthGrantType defaultValue:nil]];
    [self setOAuthAuthorizePath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAuthorizePath defaultValue:nil]];
    [self setOAuthAccessTokenPath:[[self propertyContainer] getStringPropertyValue:kIXOAuthAccessTokenPath defaultValue:nil]];
    [self setOAuthScope:[[self propertyContainer] getStringPropertyValue:kIXOAuthScope defaultValue:nil]];
    [self setOAuthRedirectURI:[[self propertyContainer] getStringPropertyValue:kIXOAuthRedirectURI defaultValue:kIX_Default_RedirectURI]];
    
    [super applySettings];
}

-(void)createHTTPClient
{
    NSURL* baseURL = [NSURL URLWithString:[self dataBaseURL]];

    BOOL needsToCreateClient = ([self httpClient] == nil || ![[self httpClient] isKindOfClass:[AFOAuth2Client class]]);
    if( !needsToCreateClient )
    {
        AFOAuth2Client* oauthClient = (AFOAuth2Client*)[self httpClient];
        needsToCreateClient = ( ![[oauthClient serviceProviderIdentifier] isEqualToString:[baseURL host]] || ![[oauthClient clientID] isEqualToString:[self oAuthClientID]] || ![[oauthClient secret] isEqualToString:[self oAuthSecret]] );
    }
    
    if( needsToCreateClient )
    {
        AFOAuth2Client* oauth2Client = [AFOAuth2Client clientWithBaseURL:baseURL clientID:[self oAuthClientID] secret:[self oAuthSecret]];
        [self setHttpClient:oauth2Client];
    }
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

-(NSString*)buildAccessCodeURL
{
    NSMutableString* accessCodeURLString = [NSMutableString stringWithString:[[self dataBaseURL] stringByAppendingString:[self oAuthAuthorizePath]]];
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

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    if( [[self httpClient] isKindOfClass:[AFOAuth2Client class]] && ![self isPathLocal] )
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
                                                             [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:NO];
                                                             
                                                         } failure:^(NSError *error) {
                                                             
                                                             [AFOAuthCredential deleteCredentialWithIdentifier:storageID];
                                                             [weakOAuth2Client setParameterEncoding:paramEncoding];
                                                             [weakSelf loadData:YES];
                                                             
                                                         }];
                    return;
                }
                else
                {
                    foundValidStoredCredential = YES;
                    [self setOAuthCredential:storedCredential];
                    [oauth2Client setAuthorizationHeaderWithCredential:storedCredential];
                    
                    [[self actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                    [self fireLoadFinishedEvents:YES shouldCacheResponse:NO];
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
    [self setResponseErrorMessage:[error description]];
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
    NSString* oauthStorageID = [self oAuthTokenStorageID];

    AFOAuth2Client* oAuth2Client = (AFOAuth2Client*)[self httpClient];
    AFHTTPClientParameterEncoding paramEncoding = [oAuth2Client parameterEncoding];
    [oAuth2Client setParameterEncoding:AFFormURLParameterEncoding];
    
    __weak typeof(self) weakSelf = self;
    [oAuth2Client authenticateUsingOAuthWithPath:[self oAuthAccessTokenPath]
                                            code:accessCode
                                     redirectURI:[self oAuthRedirectURI]
                                         success:^(AFOAuthCredential *credential) {
                                             
                                             [[weakSelf httpClient] setParameterEncoding:paramEncoding];
                                             [weakSelf setOAuthCredential:credential];
                                             
                                             IX_LOG_VERBOSE(@"%@ : Did recieve access token for dataprovider with ID :%@ accessToken : %@",THIS_FILE,[weakSelf ID],[credential accessToken]);
                                             
                                             if( [oauthStorageID length] > 0 )
                                             {
                                                 [AFOAuthCredential storeCredential:credential withIdentifier:oauthStorageID];
                                             }
                                             
                                             [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthSuccess];
                                             [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:NO];
                                             
                                         } failure:^(NSError *error) {
                                             
                                             [[weakSelf httpClient] setParameterEncoding:paramEncoding];
                                             [weakSelf setResponseErrorMessage:[error description]];
                                             [[weakSelf actionContainer] executeActionsForEventNamed:kIXAuthFail];
                                             [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                                         }];
    
    if( [UIViewController isOkToDismissViewController:oAuthWebAuthViewController] )
    {
        [self setOAuthWebAuthViewController:nil];
        [oAuthWebAuthViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
