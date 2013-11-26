//
//  IXMessageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
#import "SDWebImageManager.h"

@interface  IXSocial ()

@property (nonatomic,strong) SLComposeViewController* composeViewController;
@property (nonatomic,copy) SLComposeViewControllerCompletionHandler completionHandler;
@property (nonatomic,assign) BOOL isPresentingComposeController;

@property (nonatomic,strong) NSString* shareServiceType;
@property (nonatomic,strong) NSString* shareInitialText;
@property (nonatomic,strong) NSString* shareImagePath;
@property (nonatomic,strong) UIImage* shareImage;

@end

@implementation IXSocial

-(void)dealloc
{
    if( [self isPresentingComposeController] )
    {
        [self dismissComposeViewController:NO];
    }
}

-(void)buildView
{
    __weak IXSocial* weakSelf = self;
    [self setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result)
        {
            case SLComposeViewControllerResultDone:
            {
                [[weakSelf actionContainer] executeActionsForEventNamed:@"share_done"];
                break;
            }
            case SLComposeViewControllerResultCancelled:
            {
                [[weakSelf actionContainer] executeActionsForEventNamed:@"share_cancelled"];
                break;
            }
            default:
            {
                break;
            }
        }
        [weakSelf dismissComposeViewController:YES];
    }];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setShareServiceType:[IXSocial getServiceType:[[self propertyContainer] getStringPropertyValue:@"share.platform" defaultValue:nil]]];
    [self setShareInitialText:[[self propertyContainer] getStringPropertyValue:@"share.text" defaultValue:nil]];
    [self setShareImagePath:[[self propertyContainer] getStringPropertyValue:@"share.image" defaultValue:nil]];

    __weak IXSocial* weakSelf = self;
    [[self propertyContainer] getImageProperty:@"share.image"
                                  successBlock:^(UIImage *image) {
                                      [weakSelf setShareImage:image];
                                  } failBlock:^(NSError *error) {
                                  }];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:@"present_share_controller"] )
    {
        BOOL animated = [parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES];
        [self presentComposeViewController:animated];
    }
    else if( [functionName isEqualToString:@"dismiss_share_controller"] )
    {
        BOOL animated = [parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES];
        [self dismissComposeViewController:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
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

-(void)dismissComposeViewController:(BOOL)animated
{
    if( ![[self composeViewController] isBeingPresented] && ![[self composeViewController] isBeingDismissed] && [[self composeViewController] presentingViewController] )
    {
        [[self composeViewController] dismissViewControllerAnimated:animated completion:nil];
    }
}

-(void)presentComposeViewController:(BOOL)animated
{
    if( [self composeViewController] )
    {
        [self dismissComposeViewController:YES];
        [self setComposeViewController:nil];
    }
    
    if( [SLComposeViewController isAvailableForServiceType:[self shareServiceType]] )
    {
        [self setComposeViewController:[SLComposeViewController composeViewControllerForServiceType:[self shareServiceType]]];
        if( [self composeViewController] )
        {
            [[self composeViewController] setCompletionHandler:[self completionHandler]];
            [[self composeViewController] setInitialText:[self shareInitialText]];
            [[self composeViewController] addImage:[self shareImage]];
            
            [[[IXAppManager sharedInstance] rootViewController] presentViewController:[self composeViewController] animated:animated completion:nil];
        }
    }
}


@end
