//
//  IXAlertAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAlertAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

// IXAlertAction Properties
static NSString* const kIXTitle = @"title";
// Migration path - deprecated
// static NSString* const kIXSubtitle = @"subtitle";
static NSString* const kIXMessage = @"message";

static NSString* const kIXConfirmButtonTitle = @"button.confirm.text";
static NSString* const kIXCancelButtonTitle = @"button.cancel.text";
static NSString* const kIXOtherButtonTitle = @"button.other.text";
static NSString* const kIXButtonTitles = @"button.titles"; //comma separated: OK,Cancel
static NSString* const kIXButtonDefaultIndex = @"button.default"; //0-based index of default action

// IXAlertAction Events
static NSString* const kIXWillPresentAlert = @"will_present_alert";
static NSString* const kIXDidPresentAlert = @"did_present_alert";
//static NSString* const kIXCancelButtonPressed = @"cancel_button_pressed";
//static NSString* const kIXConfirmButtonPressed = @"confirm_button_pressed";
//static NSString* const kIXOtherButtonPressed = @"other_button_pressed";
static NSString* const kIXButtonPressed = @"button_pressed"; //default stand-in for index 0 (for laziness)
static NSString* const kIXButtonIndexPressed = @"button_%u_pressed"; //0-based index of action to execute

@interface IXAlertAction () <UIAlertViewDelegate>
@property (nonatomic,strong) UIAlertView* alertView;
@end

@implementation IXAlertAction

-(void)dealloc
{
    [_alertView setDelegate:nil];
}

-(void)execute
{
    [super execute];
    
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* title = [actionProperties getStringPropertyValue:kIXTitle defaultValue:nil];
    NSString* message = [actionProperties getStringPropertyValue:kIXMessage defaultValue:nil];
    // Deprecation statement, replace Subtitle with Text
//    if (subTitle == nil)
//    {
//        subTitle = [actionProperties getStringPropertyValue:kIXMessage defaultValue:nil];
//    }
    //NSString* confirmButtonTitle = [actionProperties getStringPropertyValue:kIXConfirmButtonTitle defaultValue:kIX_OK];
    //NSString* cancelButtonTitle = [actionProperties getStringPropertyValue:kIXCancelButtonTitle defaultValue:nil];
    NSArray* buttonTitles = [actionProperties getCommaSeperatedArrayListValue:kIXButtonTitles defaultValue:@[kIX_OK]];
    NSInteger defaultButtonIndex = [actionProperties getIntPropertyValue:kIXButtonDefaultIndex defaultValue:buttonTitles.count - 1];
    //failsafe for indexOutOfRange error
    if (defaultButtonIndex > buttonTitles.count - 1)
        defaultButtonIndex = buttonTitles.count - 1;
    
    [[self alertView] setDelegate:nil];
    [[self alertView] dismissWithClickedButtonIndex:[[self alertView] cancelButtonIndex] animated:YES];
    [self setAlertView:[[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil]];
    for ( NSString *title in buttonTitles )  {
        [self.alertView addButtonWithTitle:title];
    }
    
    self.alertView.cancelButtonIndex = defaultButtonIndex;

    
    [[self alertView] show];
}


#pragma mark UIAlertViewDelegate Methods

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:kIXWillPresentAlert];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [[self subActionContainer] executeActionsForEventNamed:kIXDidPresentAlert];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self alertView] setDelegate:nil];
    [self setAlertView:nil];
    
    NSString* actionName = [NSString stringWithFormat:kIXButtonIndexPressed, buttonIndex];
    [self actionDidFinishWithEvents:@[actionName]];
    if (buttonIndex == 0)
    {
        // This is here so we can use the alias action trigger (on) "button_pressed"
        [self actionDidFinishWithEvents:@[kIXButtonPressed]];
    }

// deprecated
//    if( buttonIndex == [alertView cancelButtonIndex] )
//    {
//        [self actionDidFinishWithEvents:@[kIXCancelButtonPressed]];
//    }
//    else
//    {
//        [self actionDidFinishWithEvents:@[kIXConfirmButtonPressed]];
//    }
}

@end

@implementation IXDevalertAction

-(void)execute
{
    if( [[IXAppManager sharedAppManager] appMode] == IXDebugMode )
    {
        [super execute];
    }
}

@end

