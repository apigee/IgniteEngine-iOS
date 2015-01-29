//
//  IXTouchID.m
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 9/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Brandon Shelley
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    Native iOS TouchID accessor.
 
 ####
 #### Attributes
 |  Name                                |   Type                    |   Description                                         |   Default
 |:-------------------------------------|:-------------------------:|:------------------------------------------------------|:-------------:|
 | *title*                              |   *(string)*               |   TouchID title                                      |   *nil*
 
 ####
 #### Inherits
 >  IXBaseControl
 
 ####
 #### Events
 |  Name                                |   Description                                         |
 |:-------------------------------------|:------------------------------------------------------|
 | *success*                            |   The user did authenticate successfully.
 | *failed*                             |   The user did not authenticate successfully.
 | *cancelled*                          |   The user cancelled the operation.
 | *password*                           |   ???
 | *unconfigured*                       |   TouchID is not configured on the device.
 | *unavailable*                        |   TouchID is not available or not supported on the device.

 ####
 #### Functions
 
 *authenticate*
    
    {
        "_type": "Function",
        "on": "success",
        "attributes": {
            "function_name": "authenticate"
        }
    }
 
 ####
 #### Example JSON
 
    {
        "_type": "TouchID",
        "_id": "TouchID",
        "actions": [
            {
                "_type": "Alert",
                "on": "success",
                "attributes": {
                    "title": "success"
                }
            }
        ]
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXTouchID.h"

#import <LocalAuthentication/LocalAuthentication.h>

// IXTouchID Functions
IX_STATIC_CONST_STRING kIXAuthenticate = @"authenticate";

// IXTouchID Attributes
static NSString* const kIXTitle = @"title";

// IXTouchID Events
static NSString* const kIXAuthenticationSuccess = @"success";
static NSString* const kIXAuthenticationFailed = @"failed";
static NSString* const kIXAuthenticationCancelled = @"cancelled";
static NSString* const kIXAuthenticationPassword = @"password";
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXAuthenticate] )
    {
        //LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString* title = [[self propertyContainer] getStringPropertyValue:kIXTitle defaultValue:@"Please authenticate."];
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
