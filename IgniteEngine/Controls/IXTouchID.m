//
//  IXTouchID.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 9/18/14.
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

#import "IXTouchID.h"

#import <LocalAuthentication/LocalAuthentication.h>

// IXTouchID Functions
IX_STATIC_CONST_STRING kIXAuthenticate = @"authenticate";

// IXTouchID Attributes
static NSString* const kIXTitle = @"title";

// IXTouchID Events
static NSString* const kIXAuthenticationSuccess = @"success";
static NSString* const kIXAuthenticationFailed = @"error";
static NSString* const kIXAuthenticationCancelled = @"cancelled";
static NSString* const kIXAuthenticationPassword = @"willUsePassword";
static NSString* const kIXAuthenticationUnconfigured = @"unconfigured";
static NSString* const kIXAuthenticationUnavailable = @"unavailable";

@interface IXTouchID ()

@property (nonatomic,strong) LAContext* context;

@end

@implementation IXTouchID


-(void)buildView
{
    [super buildView];
    _context = [[LAContext alloc] init];
}

-(void)applySettings
{
    [super applySettings];
    //test

}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXAuthenticate] )
    {
        //LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString* title = [[self attributeContainer] getStringValueForAttribute:kIXTitle defaultValue:@"Please authenticate."];
        if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            
            [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:title
                                reply:^(BOOL success, NSError *error) {
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        if (success) {
                                            /* why is there a delay between when the user authenticates successfully
                                             and the action execution?

                                             - Can take as long as 20s before an Alert/Modify occurs visually.
                                             - Appears to be a UI-only issue -- meaning that the action fires,
                                             but the effect of the action is delayed visually.
                                             - When it occurs, the UI is blocked and unresponsive
                                             - Appears to only occur when the action affects the UI -- Log is immediate

                                             */
                                            IX_LOG_VERBOSE(@"User authenticated successfully.");
                                            [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationSuccess];

                                        } else {

                                            switch (error.code) {
                                                case LAErrorAuthenticationFailed:
                                                    [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationFailed];
                                                    IX_LOG_VERBOSE(@"Authenticated failed.");
                                                    break;

                                                case LAErrorUserCancel:
                                                    [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationCancelled];
                                                    IX_LOG_VERBOSE(@"User cancelled authentication.");
                                                    break;

                                                case LAErrorUserFallback:
                                                    [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationPassword];
                                                    IX_LOG_VERBOSE(@"User pressed 'Enter Password'");
                                                    break;

                                                default:
                                                    [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationUnconfigured];
                                                    IX_LOG_VERBOSE(@"TouchID not configured.");
                                                    break;
                                            }
                                        }

                                    }];
                                }];
        } else {
            [[self actionContainer] executeActionsForEventNamed:kIXAuthenticationUnavailable];
            IX_LOG_VERBOSE(@"TouchID not available.");
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end