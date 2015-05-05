//
//  IXMessageControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/16/13.
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

#import "IXMessage.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "UIViewController+IXAdditions.h"

#import <MessageUI/MessageUI.h>

IX_STATIC_CONST_STRING kIXBcc = @"bcc";
IX_STATIC_CONST_STRING kIXBody = @"body";
IX_STATIC_CONST_STRING kIXCc = @"cc";
IX_STATIC_CONST_STRING kIXTo = @"to";
IX_STATIC_CONST_STRING kIXSubject = @"subject";
IX_STATIC_CONST_STRING kIXType = @"type";
IX_STATIC_CONST_STRING kIXCancelled = @"cancelled";
IX_STATIC_CONST_STRING kIXError = @"error";
IX_STATIC_CONST_STRING kIXSuccess = @"success";
IX_STATIC_CONST_STRING kIXPresentEmail = @"present.email";
IX_STATIC_CONST_STRING kIXPresentSms = @"present.sms";

@interface  IXMessage () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) NSString *messageSubject;
@property (nonatomic,strong) NSString *messageBody;
@property (nonatomic,strong) NSArray *messageToRecipients;
@property (nonatomic,strong) NSArray *messageCCRecipients;
@property (nonatomic,strong) NSArray *messageBCCRecipients;

@property (nonatomic,strong) MFMessageComposeViewController *textMessage;
@property (nonatomic,strong) MFMailComposeViewController *emailMessage;

@end

@implementation IXMessage

-(void)dealloc
{
    [_textMessage setMessageComposeDelegate:nil];
    [self dismissViewController:[self textMessage] animated:NO];
    
    [_emailMessage setMailComposeDelegate:nil];
    [self dismissViewController:[self emailMessage] animated:NO];
}

-(void)buildView
{
    // Overriden without super call because we don't want/need a view for this widget.
}

-(void)applySettings
{
    [super applySettings];
    
    [self setMessageSubject:[[self attributeContainer] getStringValueForAttribute:kIXSubject defaultValue:nil]];
    [self setMessageBody:[[self attributeContainer] getStringValueForAttribute:kIXBody defaultValue:nil]];
    [self setMessageToRecipients:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXTo defaultValue:nil]];
    [self setMessageCCRecipients:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXCc defaultValue:nil]];
    [self setMessageBCCRecipients:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXBcc defaultValue:nil]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
{
    if( [functionName isEqualToString:kIXPresentEmail] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
        }
        [self presentEmailController:animated];
    }
    else if( [functionName isEqualToString:kIXPresentSms] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
        }
        [self presentTextMessageController:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)presentEmailController:(BOOL)animated
{
    if( [MFMailComposeViewController canSendMail] )
    {
        if( [UIViewController isOkToPresentViewController:[self emailMessage]] )
        {
            [[self emailMessage] setMailComposeDelegate:nil];
            [self setEmailMessage:nil];
            
            MFMailComposeViewController* mailComposeViewController = [[MFMailComposeViewController alloc] init];
            [mailComposeViewController setMailComposeDelegate:self];
            [mailComposeViewController setSubject:[self messageSubject]];
            [mailComposeViewController setToRecipients:[self messageToRecipients]];
            [mailComposeViewController setCcRecipients:[self messageCCRecipients]];
            [mailComposeViewController setBccRecipients:[self messageBCCRecipients]];
            [mailComposeViewController setMessageBody:[self messageBody] isHTML:YES];
            [self setEmailMessage:mailComposeViewController];
            
            [[[IXAppManager sharedAppManager] rootViewController] presentViewController:[self emailMessage] animated:animated completion:nil];
        }
    }
}

-(void)presentTextMessageController:(BOOL)animated
{
    if( [MFMessageComposeViewController canSendText] )
    {
        if( [UIViewController isOkToPresentViewController:[self textMessage]] )
        {
            [[self textMessage] setMessageComposeDelegate:nil];
            [self setTextMessage:nil];
            
            MFMessageComposeViewController* messageComposeViewController = [[MFMessageComposeViewController alloc] init];
            [messageComposeViewController setMessageComposeDelegate:self];
            [messageComposeViewController setSubject:[self messageSubject]];
            [messageComposeViewController setRecipients:[self messageToRecipients]];
            [messageComposeViewController setBody:[self messageBody]];
            [self setTextMessage:messageComposeViewController];
            
            [[[IXAppManager sharedAppManager] rootViewController] presentViewController:[self textMessage] animated:YES completion:nil];
        }
    }
}

-(void)dismissViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    if( [UIViewController isOkToDismissViewController:viewController] )
    {
        [viewController dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            [[self actionContainer] executeActionsForEventNamed:kIXCancelled];
            break;
        case MessageComposeResultFailed:
            [[self actionContainer] executeActionsForEventNamed:kIXError];
            break;
        case MessageComposeResultSent:
            [[self actionContainer] executeActionsForEventNamed:kIXSuccess];
            break;
        default:
            break;
    }
    [self dismissViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [[self actionContainer] executeActionsForEventNamed:kIXCancelled];
            break;
        case MFMailComposeResultFailed:
            [[self actionContainer] executeActionsForEventNamed:kIXError];
            break;
        case MFMailComposeResultSent:
            [[self actionContainer] executeActionsForEventNamed:kIXSuccess];
            break;
        default:
            break;
    }
    [self dismissViewController:controller animated:YES];
}

@end
