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

#import "UIViewController+IXAdditions.h"
#import "NSString+IXAdditions.h"

#import "SDWebImageManager.h"

// Social Properties
static NSString* const kIX_SharePlatform = @"share.platform"; // kIX_SharePlatform Types Accepted
static NSString* const kIX_ShareText = @"share.text";
static NSString* const kIX_ShareImage = @"share.image";

// kIX_SharePlatform Types
static NSString* const kIX_SharePlatform_Facebook = @"facebook";
static NSString* const kIX_SharePlatform_Twitter = @"twitter";
static NSString* const kIX_SharePlatform_SinaWeibo = @"sina_weibo";

// Social Read-Only Properties
static NSString* const kIX_Facebook_Available = @"facebook_available";
static NSString* const kIX_Twitter_Available = @"twitter_available";
static NSString* const kIX_Sina_Weibo_Available = @"sina_weibo_available";

// Social Events
static NSString* const kIX_Share_Done = @"share_done";
static NSString* const kIX_Share_Cancelled = @"share_cancelled";

// Social Functions
static NSString* const kIX_Present_Share_Controller = @"present_share_controller"; // Params : "animated"
static NSString* const kIX_Dismiss_Share_Controller = @"dismiss_share_controller"; // Params : "animated"

@interface  IXSocial ()

@property (nonatomic,strong) SLComposeViewController* composeViewController;
@property (nonatomic,copy) SLComposeViewControllerCompletionHandler composeViewControllerCompletionBlock;

@property (nonatomic,strong) NSString* shareServiceType;
@property (nonatomic,strong) NSString* shareInitialText;
@property (nonatomic,strong) UIImage* shareImage;

@end

@implementation IXSocial

-(void)dealloc
{
    [self dismissComposeViewController:NO];
}

-(void)buildView
{
    __weak IXSocial* weakSelf = self;
    [self setComposeViewControllerCompletionBlock:^(SLComposeViewControllerResult result){
        switch (result)
        {
            case SLComposeViewControllerResultDone:
            {
                [[weakSelf actionContainer] executeActionsForEventNamed:kIX_Share_Done];
                break;
            }
            case SLComposeViewControllerResultCancelled:
            {
                [[weakSelf actionContainer] executeActionsForEventNamed:kIX_Share_Cancelled];
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
    
    [self setShareServiceType:[IXSocial getServiceType:[[self propertyContainer] getStringPropertyValue:kIX_SharePlatform defaultValue:nil]]];
    [self setShareInitialText:[[self propertyContainer] getStringPropertyValue:kIX_ShareText defaultValue:nil]];

    __weak IXSocial* weakSelf = self;
    [[self propertyContainer] getImageProperty:kIX_ShareImage
                                  successBlock:^(UIImage *image) {
                                      [weakSelf setShareImage:image];
                                  } failBlock:^(NSError *error) {
                                  }];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIX_Present_Share_Controller] )
    {
        [self presentComposeViewController:[parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:YES]];
    }
    else if( [functionName isEqualToString:kIX_Dismiss_Share_Controller] )
    {
        [self dismissComposeViewController:[parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:YES]];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIX_Facebook_Available] )
    {
        returnValue = [NSString stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]];
    }
    else if( [propertyName isEqualToString:kIX_Twitter_Available] )
    {
        returnValue = [NSString stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]];
    }
    else if( [propertyName isEqualToString:kIX_Sina_Weibo_Available] )
    {
        returnValue = [NSString stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

+(NSString*)getServiceType:(NSString*)typeSetting
{
    if( [typeSetting isEqualToString:kIX_SharePlatform_Twitter] )
        return SLServiceTypeTwitter;
    else if( [typeSetting isEqualToString:kIX_SharePlatform_Facebook] )
        return SLServiceTypeFacebook;
    else if( [typeSetting isEqualToString:kIX_SharePlatform_SinaWeibo] )
        return SLServiceTypeSinaWeibo;
    return nil;
}

-(void)dismissComposeViewController:(BOOL)animated
{
    if( [UIViewController isOkToDismissViewController:[self composeViewController]] )
    {
        [[self composeViewController] dismissViewControllerAnimated:animated completion:nil];
    }
}

-(void)presentComposeViewController:(BOOL)animated
{
    if( [self composeViewController] )
    {
        [self dismissComposeViewController:NO];
        [self setComposeViewController:nil];
    }

    if( [SLComposeViewController isAvailableForServiceType:[self shareServiceType]] )
    {
        [self setComposeViewController:[SLComposeViewController composeViewControllerForServiceType:[self shareServiceType]]];
        if( [self composeViewController] )
        {
            [[self composeViewController] setCompletionHandler:[self composeViewControllerCompletionBlock]];
            [[self composeViewController] setInitialText:[self shareInitialText]];
            [[self composeViewController] addImage:[self shareImage]];
            
            [[[IXAppManager sharedAppManager] rootViewController] presentViewController:[self composeViewController] animated:animated completion:nil];
        }
    }
}

@end
