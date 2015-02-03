//
//  IXMessageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/**
 
 Send an email or SMS/iMessage.
 

 <div id="container">
<li><a href="../images/IXMessage_0.png" data-imagelightbox="c"><img src="../images/IXMessage_0.png"></a></li>
<li><a href="../images/IXMessage_1.png" data-imagelightbox="c"><img src="../images/IXMessage_1.png"></a></li>
<li><a href="../images/IXMessage_2.png" data-imagelightbox="c"><img src="../images/IXMessage_2.png"></a></li>
</ul>
</div>
 
*/

/*
 *      /Docs
 *
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

/*
* Docs
*
*/

/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param message.type The type of message to create<br>*textemail*
    @param message.to Send message to? (Email/Phone/iMessage address)<br>*(string)*
    @param message.cc Send a copy to?<br>*(string)*
    @param message.bcc Blind copy to? (Email)<br>*(string)*
    @param message.subject Message subject (Email)<br>*(string)*
    @param message.body Message body (Email/Text)<br>*(string)*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>
*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param message_cancelled Fires when the file is inaccessible
    @param message_failed Fires when the message fails to send
    @param message_sent Fires on message send success
 
*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


    @param present_text_message_controller 
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "messageTest",
    "function_name": "present_text_message_controller"
  }
}
 
 </pre>

    @param present_email_controller 
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "messageTest",
    "function_name": "present_email_controller"
  }
}
 

 </pre>

*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>


 <pre class="brush: js; toolbar: false;">
 
{
  "_id": "messageTest",
  "_type": "Message",
  "actions": [
    {
      "on": "message_sent",
      "_type": "Alert",
      "attributes": {
        "title": "Message sent!"
      }
    },
    {
      "on": "message_cancelled",
      "_type": "Alert",
      "attributes": {
        "title": "Message cancelled!"
      }
    }
  ],
  "attributes": {
    "message.type": "text",
    "message.to": "555-867-5309"
  }
}
 
 </pre>

*/

-(void)example
{
}

/***************************************************************/

/*
* /Docs
*
*/

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
    if( [functionName isEqualToString:@"present_email_controller"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self presentEmailController:animated];
    }
    else if( [functionName isEqualToString:@"present_text_message_controller"] )
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
