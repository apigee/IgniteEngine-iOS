//
//  ixeMessageControl.m
//  Ignite iOS Engine (ixe)
//
//  Created by Jeremy Anticouni on 11/16.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 
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

#import "ixeMessage.h"
#import "ixeAppManager.h"
#import "ixeNavigationViewController.h"
#import "ixeViewController.h"
#import <MessageUI/MessageUI.h>


@interface  ixeMessage() <MFMessageComposeViewControllerDelegate>

@property (nonatomic,strong) NSString *messageType;
@property (nonatomic,strong) MFMessageComposeViewController *textMessage;
@property (nonatomic,strong) MFMailComposeViewController *emailMessage;

@end

@implementation ixeMessage

-(void)buildView
{
    [super buildView];

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Message was cancelled");
            [[self actionContainer] executeActionsForEventNamed:@"message_cancelled"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message failed");
            [[self actionContainer] executeActionsForEventNamed:@"message_failed"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultSent:
            NSLog(@"Message was sent");
            [[self actionContainer] executeActionsForEventNamed:@"message_sent"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Message was cancelled");
            [[self actionContainer] executeActionsForEventNamed:@"message_cancelled"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message failed");
            [[self actionContainer] executeActionsForEventNamed:@"message_failed"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultSent:
            NSLog(@"Message was sent");
            [[self actionContainer] executeActionsForEventNamed:@"message_sent"];
            [[[ixeAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        default:
            break;
    }
}


-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}



-(void)applySettings
{
    [super applySettings];
    
    //NOTES:
    /*
    */
    
    _messageType = [[self propertyContainer] getStringPropertyValue:@"message.type" defaultValue:@""];
    
    if( _messageType != nil )
    {
        if([_messageType compare:@"text"] == NSOrderedSame)
        {
            // SMS/iMessage
            _textMessage = [[MFMessageComposeViewController alloc] init];
            _textMessage.body = [[self propertyContainer] getStringPropertyValue:@"message.body" defaultValue:nil];

            // Need to add ability to specify multiple recipients:
            _textMessage.recipients = @[[[self propertyContainer] getStringPropertyValue:@"message.to" defaultValue:nil]];
            
            _textMessage.messageComposeDelegate = self;
            
        }
        else if([_messageType compare:@"email"] == NSOrderedSame)
        {
            _emailMessage = [[MFMailComposeViewController alloc] init];
            _emailMessage.mailComposeDelegate  = self;
            [_emailMessage setToRecipients:@[[[self propertyContainer] getStringPropertyValue:@"message.to" defaultValue:nil]]];
            //[messageVC setCcRecipients:@[[[self propertyContainer] getStringPropertyValue:@"message.cc" defaultValue:nil]]];
            //[messageVC setBccRecipients:@[[[self propertyContainer] getStringPropertyValue:@"message.bcc" defaultValue:nil]]];
            [_emailMessage setSubject:@"subject"];
            [_emailMessage setMessageBody:@"body" isHTML:YES];
                        
        }
    }

}

-(void)applyFunction:(NSString*)functionName withParameters:(ixePropertyContainer*)parameterContainer
{
    
    if( [functionName compare:@"text"] == NSOrderedSame )
    {
        NSLog(@"text, bitches!");
        if([MFMessageComposeViewController canSendText])
        {
            [[[ixeAppManager sharedInstance] rootViewController] presentViewController:_textMessage animated:YES completion:nil];
        }
    }
    if( [functionName compare:@"email"] == NSOrderedSame )
    {
        NSLog(@"email, bitches!");
        if([MFMailComposeViewController canSendMail])
        {
            [[[ixeAppManager sharedInstance] rootViewController] presentViewController:_emailMessage animated:YES completion:nil];
        }
    }
}

@end
