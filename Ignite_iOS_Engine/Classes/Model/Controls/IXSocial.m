//
//  IXMessageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "Message"
 
 - PROPERTIES
 
 * name="share.platform"        default=""               type="facebook, twitter, weibo"
 * name="share.text"            default=""               type="String"
 * name="share.url"             default=""               type="String"
 * name="share.image"           default=""               type="String"
 
 - EVENTS
 
 * name="share_done"
 * name="share_cancelled"
 
 {
 "type": "Social",
 "properties": {
 "visible": "NO",
 "id": "myEmail",
 "width": "100%",
 "height": "50",
 "share": {
 "platform": "facebook",
 "text": "initial text goes here",
 "url": "http://google.com",
 "image": "/assets/images/social.jpg"
 },
 "color": {
 "background": "#00FFFF"
 }
 }
 },
 
 */

#import "IXSocial.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

@interface  IXSocial()

@property (nonatomic, strong) SLComposeViewController* SLComposeViewController;

@end

@implementation IXSocial

-(void)buildView
{
    [super buildView];

}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}

- (void)socialComposeController:(SLComposeViewController *)controller didFinishWithResult:(SLComposeViewControllerResult)result error:(NSError *)error
{
    switch (result)
    {
        case SLComposeViewControllerResultCancelled:
            NSLog(@"Share was cancelled");
            [[self actionContainer] executeActionsForEventNamed:@"share_cancelled"];
            [[[IXAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        case SLComposeViewControllerResultDone:
            NSLog(@"Share failed");
            [[self actionContainer] executeActionsForEventNamed:@"share_failed"];
            [[[IXAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            break;
        default:
            break;
    }
}


+(NSString*)getServiceType:(NSString*)typeSetting
{
    if( [typeSetting isEqualToString:@"twitter"] )
        return SLServiceTypeTwitter;
    else if( [typeSetting isEqualToString:@"facebook"] )
        return SLServiceTypeFacebook;
    else if( [typeSetting isEqualToString:@"weibo"] )
        return SLServiceTypeSinaWeibo;
    return nil;
}

-(void)applySettings
{
    [super applySettings];
    
    //NOTES:
    /*
        If no accounts are configured, it should pop the alert stating this.
        Completion handler doesn't work :|
    */
    
    // Twitter, Facebook, Weibo

    NSString* sharePlatform = [IXSocial getServiceType:[[self propertyContainer] getStringPropertyValue:@"share.platform" defaultValue:@""]];
    
    if( sharePlatform != nil )
    {
        if( [SLComposeViewController isAvailableForServiceType:sharePlatform] )
        {
            SLComposeViewController *controller = [SLComposeViewController
                                                   composeViewControllerForServiceType:sharePlatform];
            [controller setInitialText:[[self propertyContainer] getStringPropertyValue:@"share.text" defaultValue:nil]];
            [controller addURL:[NSURL URLWithString:[[self propertyContainer] getStringPropertyValue:@"share.url" defaultValue:nil]]];
            [controller addImage:[UIImage imageNamed:[[self propertyContainer] getStringPropertyValue:@"share.image" defaultValue:nil]]];

            [[[IXAppManager sharedInstance] rootViewController] presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Network not available: %@",sharePlatform);
        }
       
        [[self SLComposeViewController] setCompletionHandler:^(SLComposeViewControllerResult result){
            
            switch (result) {
                case SLComposeViewControllerResultDone:
                    NSLog(@"Share done");
                    [[self actionContainer] executeActionsForEventNamed:@"share_done"];
                    [[[IXAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
                    break;
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Share was cancelled");
                    [[self actionContainer] executeActionsForEventNamed:@"share_cancelled"];
                    [[[IXAppManager sharedInstance] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
                    break;
                default:
                    break;
            }
            
        }];
    }
    
}


@end
