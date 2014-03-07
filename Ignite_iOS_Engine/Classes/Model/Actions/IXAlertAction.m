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
static NSString* const kIXSubtitle = @"subtitle";
static NSString* const kIXConfirmButtonTitle = @"button.confirm.text";
static NSString* const kIXShowsCancelButton = @"shows_cancel_button";
static NSString* const kIXCancelButtonTitle = @"button.cancel.text";

// IXAlertAction Events
static NSString* const kIXWillPresentAlert = @"will_present_alert";
static NSString* const kIXDidPresentAlert = @"did_present_alert";
static NSString* const kIXCancelButtonPressed = @"cancel_button_pressed";
static NSString* const kIXConfirmButtonPressed = @"confirm_button_pressed";

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
    NSString* subTitle = [actionProperties getStringPropertyValue:kIXSubtitle defaultValue:nil];
    NSString* confirmButtonTitle = [actionProperties getStringPropertyValue:kIXConfirmButtonTitle defaultValue:kIX_OK];
    
    NSString* cancelButtonTitle = [actionProperties getStringPropertyValue:kIXCancelButtonTitle defaultValue:nil];

    [[self alertView] setDelegate:nil];
    [[self alertView] dismissWithClickedButtonIndex:[[self alertView] cancelButtonIndex] animated:YES];
    [self setAlertView:[[UIAlertView alloc] initWithTitle:title
                                                  message:subTitle
                                                 delegate:self
                                        cancelButtonTitle:cancelButtonTitle
                                        otherButtonTitles:confirmButtonTitle,nil]];

    
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

    if( buttonIndex == [alertView cancelButtonIndex] )
    {
        [self actionDidFinishWithEvents:@[kIXCancelButtonPressed]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIXConfirmButtonPressed]];
    }
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

