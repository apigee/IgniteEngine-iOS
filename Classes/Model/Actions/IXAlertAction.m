//
//  IXAlertAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
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

#import "IXAlertAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXAttributeContainer.h"

// IXAlertAction Attributes
static NSString* const kIXTitle = @"title";
static NSString* const kIXMessage = @"message";
static NSString* const kIXButtonTitles = @"button.titles"; //comma separated: OK,Cancel
//static NSString* const kIXButtonDefaultIndex = @"button.default"; //0-based index of default action

// as of iOS7 we can no longer customize which is the highlighted button - the last (right-most or bottom) is always default.
// ref: http://stackoverflow.com/questions/19125249/highlight-top-button-in-uialertview

// IXAlertAction Events
static NSString* const kIXWillPresentAlert = @"willPresent";
static NSString* const kIXDidPresentAlert = @"didPresent";
static NSString* const kIXButtonPressed = @"button.pressed"; //default stand-in for index 0 (for laziness)
static NSString* const kIXButtonIndexPressed = @"button.%lu.pressed"; //0-based index of action to execute

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
    
    IXAttributeContainer* actionProperties = [self actionProperties];
    
    NSString* title = [actionProperties getStringValueForAttribute:kIXTitle defaultValue:nil];
    NSString* message = [actionProperties getStringValueForAttribute:kIXMessage defaultValue:nil];
    
    NSArray* buttonTitles = [actionProperties getCommaSeparatedArrayOfValuesForAttribute:kIXButtonTitles defaultValue:@[kIX_OK]];
    
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
    
    NSString* actionName = [NSString stringWithFormat:kIXButtonIndexPressed, (long)buttonIndex];
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

