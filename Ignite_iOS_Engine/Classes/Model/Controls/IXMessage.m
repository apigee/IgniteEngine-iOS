//
//  IXMessageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI controls to send emails or text messages.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name            | Type            | Description                                     | Default |
 |-----------------|-----------------|-------------------------------------------------|---------|
 | message.type    | *text<br>email* | The type of message to create                   |         |
 | message.to      | *(string)*      | Send message to? (Email/Phone/iMessage address) |         |
 | message.cc      | *(string)*      | Send a copy to?                                 |         |
 | message.bcc     | *(string)*      | Blind copy to? (Email)                          |         |
 | message.subject | *(string)*      | Message subject (Email)                         |         |
 | message.body    | *(string)*      | Message body (Email/Text)                       |         |
 
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

| Name              | Description                          |
|-------------------|--------------------------------------|
| message_cancelled | Fires when the file is inaccessible  |
| message_failed    | Fires when the message fails to send |
| message_sent      | Fires on message send success        |
 

 ##  <a name="functions">Functions</a>
 
Present Text controller: *present_text_message_controller*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "messageTest",
        "function_name": "present_text_message_controller"
      }
    }

Present Email controller: *present_email_controller*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "messageTest",
        "function_name": "present_email_controller"
      }
    }
 
 ##  <a name="example">Example JSON</a> 
 
 */
//
//  [/Documentation]
/*  -----------------------------  */


/*
 
 CONTROL
 
 - TYPE : "Message"
 
 - PROPERTIES
 
 * name="message.type"          default=""               type="text, email"
 * name="message.to"            default=""               type="String"
 * name="message.cc"            default=""               type="String"
 * name="message.bcc"           default=""               type="String"
 * name="message.subject"       default=""               type="String"
 * name="message.body"          default=""               type="String"
 
 - EVENTS
 
 * name="message_cancelled"
 * name="message_failed"
 * name="message_sent"
 
 
 {
    "type": "Message",
    "properties": {
        "id": "myEmail",
        "width": "100%",
        "height": "50",
        "message": {
            "type": "email",
            "to": "jeremy@anticouni.net",
            "subject": "this is a subject",
            "body": "Uhh nice man I don't know how that works but awesome"
        },
        "color": {
            "background": "#00FFFF"
        }
    }
}
 
 */

#import "IXMessage.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "UIViewController+IXAdditions.h"

#import <MessageUI/MessageUI.h>

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
    
    [self setMessageSubject:[[self propertyContainer] getStringPropertyValue:@"message.subject" defaultValue:nil]];
    [self setMessageBody:[[self propertyContainer] getStringPropertyValue:@"message.body" defaultValue:nil]];
    [self setMessageToRecipients:[[self propertyContainer] getCommaSeperatedArrayListValue:@"message.to" defaultValue:nil]];
    [self setMessageCCRecipients:[[self propertyContainer] getCommaSeperatedArrayListValue:@"message.cc" defaultValue:nil]];
    [self setMessageBCCRecipients:[[self propertyContainer] getCommaSeperatedArrayListValue:@"message.bcc" defaultValue:nil]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName isEqualToString:@"present_text_message_controller"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self presentEmailController:animated];
    }
    else if( [functionName isEqualToString:@"present_email_controller"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
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
            [[self actionContainer] executeActionsForEventNamed:@"message_cancelled"];
            break;
        case MessageComposeResultFailed:
            [[self actionContainer] executeActionsForEventNamed:@"message_failed"];
            break;
        case MessageComposeResultSent:
            [[self actionContainer] executeActionsForEventNamed:@"message_sent"];
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
            [[self actionContainer] executeActionsForEventNamed:@"message_cancelled"];
            break;
        case MFMailComposeResultFailed:
            [[self actionContainer] executeActionsForEventNamed:@"message_failed"];
            break;
        case MFMailComposeResultSent:
            [[self actionContainer] executeActionsForEventNamed:@"message_sent"];
            break;
        default:
            break;
    }
    [self dismissViewController:controller animated:YES];
}

@end
