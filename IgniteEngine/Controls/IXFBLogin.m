//
//  IXFBLogin.m
//  Ignite Engine
//
//  Created by Jeremy on 7/1/15.
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

#import "IXFBLogin.h"
#import "IXAttributeContainer.h"
#import "IXAppManager.h"

// Attributes
IX_STATIC_CONST_STRING kIXFBLoginType = @"type";
IX_STATIC_CONST_STRING kIXFBLoginReadPermissions = @"permissions.read";
IX_STATIC_CONST_STRING kIXFBLoginPublishPermissions = @"permissions.publish";
IX_STATIC_CONST_STRING kIXFBLoginBehavior = @"loginBehavior";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXFBLoginButton = @"button";
IX_STATIC_CONST_STRING kIXFBLoginFunction = @"function";
IX_STATIC_CONST_STRING kIXFBLoginBehaviorNative = @"native";
IX_STATIC_CONST_STRING kIXFBLoginBehaviorWeb = @"web";
IX_STATIC_CONST_STRING kIXFBLoginBehaviorBrowser = @"browser";
IX_STATIC_CONST_STRING kIXFBLoginBehaviorSystem = @"system";

// Returns
IX_STATIC_CONST_STRING kIXFBAccessToken = @"token";

// Functions
IX_STATIC_CONST_STRING kIXFBLogin = @"login";
IX_STATIC_CONST_STRING kIXFBLogout = @"logout";

// Events
IX_STATIC_CONST_STRING kIXFBLoginSuccess = @"login.success";
IX_STATIC_CONST_STRING kIXFBLoginError = @"login.error";
IX_STATIC_CONST_STRING kIXFBLoginCancelled = @"login.cancelled";
IX_STATIC_CONST_STRING kIXFBLogoutSuccess = @"logout.success";

@interface IXFBLogin () <FBSDKLoginButtonDelegate>

@end

@implementation IXFBLogin : IXBaseControl

-(void)dealloc
{
    self.loginButton.delegate = nil;
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.loginButton sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.loginButton setFrame:rect];
}

-(void)buildView
{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [super buildView];
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* type = [[self attributeContainer] getStringValueForAttribute:kIXFBLoginType defaultValue:@"function"];
    
    // FBLoginType: Button
    if ([type isEqualToString:kIXFBLoginButton]) {
        if( _loginButton == nil ) {
            //  Initialize the FBSDKLoginButton and add to contentView
            _loginButton = [[FBSDKLoginButton alloc] init];
            _loginButton.delegate = self;
            [[self contentView] addSubview:_loginButton];
        }
        _loginButton.loginBehavior = [self loginBehaviorFromString:[[self attributeContainer] getStringValueForAttribute:kIXFBLoginBehavior defaultValue:kIXFBLoginBehaviorNative]];
        _loginButton.readPermissions = [[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXFBLoginReadPermissions defaultValue:@[@"email"]];
    }
    // FBLoginType: Function
    else if ([type isEqualToString:kIXFBLoginFunction]) {
        //  Initialize the FBSDKLoginManager and wait for a function call
        _loginManager = [[FBSDKLoginManager alloc] init];
        _loginManager.loginBehavior = [self loginBehaviorFromString:[[self attributeContainer] getStringValueForAttribute:kIXFBLoginBehavior defaultValue:kIXFBLoginBehaviorNative]];
    }
}

//  Handle the login events for the loginButton
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (result.isCancelled) {
        [self loginCancelled];
    }
    else if (error || result.token == nil) {
        [self loginError:error];
    }
    else {
        [self loginSuccess];
    }
}

//  Handle the logout event for the loginButton
- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    [self logoutSuccess];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXFBLogin] )
    {
        [_loginManager logInWithReadPermissions:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXFBLoginReadPermissions defaultValue:@[]] fromViewController:self.sandbox.viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            //  Handle the login events for the loginManager
            if (result.isCancelled) {
                [self loginCancelled];
            }
            else if (error || result.token == nil) {
                [self loginError:error];
            }
            else {
                [self loginSuccess];
            }
        }];
    }
    else if( [functionName isEqualToString:kIXFBLogout] )
    {
        //  Handle the logout event for the loginManager
        [self logoutSuccess];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

- (FBSDKLoginBehavior)loginBehaviorFromString:(NSString*)loginBehavior
{
    FBSDKLoginBehavior returnBehavior = FBSDKLoginBehaviorNative;
    if ([loginBehavior isEqualToString:kIXFBLoginBehaviorBrowser])
        returnBehavior = FBSDKLoginBehaviorBrowser;
    else if ([loginBehavior isEqualToString:kIXFBLoginBehaviorWeb])
        returnBehavior = FBSDKLoginBehaviorWeb;
    else if ([loginBehavior isEqualToString:kIXFBLoginBehaviorSystem])
        returnBehavior = FBSDKLoginBehaviorSystemAccount;
    return returnBehavior;
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXFBAccessToken] )
    {
        returnValue = _fbAccessToken;
        IX_LOG_VERBOSE(@"fbAccessToken: %@", _fbAccessToken);
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

- (void) loginError:(NSError *)error {
    [[self actionContainer] executeActionsForEventNamed:kIXFBLoginError];
    IX_LOG_VERBOSE(@"Error: %@", error);
}

- (void) loginCancelled {
    [[self actionContainer] executeActionsForEventNamed:kIXFBLoginCancelled];
    IX_LOG_VERBOSE(@"Cancelled.");
}

- (void) loginSuccess {
    _fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    [[self actionContainer] executeActionsForEventNamed:kIXFBLoginSuccess];
    IX_LOG_VERBOSE(@"Success! fbAccessToken: %@", _fbAccessToken);
}

- (void) logoutSuccess {
    _fbAccessToken = nil;
    [[self actionContainer] executeActionsForEventNamed:kIXFBLogoutSuccess];
    IX_LOG_VERBOSE(@"Logout Success");
}

@end