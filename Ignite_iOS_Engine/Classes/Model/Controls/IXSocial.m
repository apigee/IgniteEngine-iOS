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

@interface  IXSocial ()

@property (nonatomic,strong) SLComposeViewController* composeViewController;
@property (nonatomic,copy) SLComposeViewControllerCompletionHandler composeViewControllerCompletionBlock;
@property (nonatomic,assign) BOOL isPresentingComposeController;

@property (nonatomic,strong) NSString* shareServiceType;
@property (nonatomic,strong) NSString* shareInitialText;
@property (nonatomic,strong) NSString* shareImagePath;
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
        [self presentComposeViewController:[parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES]];
    }
    else if( [functionName isEqualToString:@"dismiss_share_controller"] )
    {
        [self dismissComposeViewController:[parameterContainer getBoolPropertyValue:@"animated" defaultValue:YES]];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:@"facebook_available"] )
    {
        returnValue = [NSString stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]];
    }
    else if( [propertyName isEqualToString:@"twitter_available"] )
    {
        returnValue = [NSString stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]];
    }
    else if( [propertyName isEqualToString:@"sina_weibo_available"] )
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
    if( [typeSetting isEqualToString:@"twitter"] )
        return SLServiceTypeTwitter;
    else if( [typeSetting isEqualToString:@"facebook"] )
        return SLServiceTypeFacebook;
    else if( [typeSetting isEqualToString:@"sina_weibo"] )
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
            
            [[[IXAppManager sharedInstance] rootViewController] presentViewController:[self composeViewController] animated:animated completion:nil];
        }
    }
}

@end
