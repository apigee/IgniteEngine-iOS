//
//  IXMessageControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXSocial.h"

@import Social;

#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "UIViewController+IXAdditions.h"
#import "NSString+IXAdditions.h"

#import "SDWebImageManager.h"

// Social Properties
IX_STATIC_CONST_STRING kIX_SharePlatform = @"platform"; // kIX_SharePlatform Types Accepted
IX_STATIC_CONST_STRING kIX_ShareText = @"text";
IX_STATIC_CONST_STRING kIX_ShareImage = @"image";
IX_STATIC_CONST_STRING kIX_ShareUrl = @"url";

// kIX_SharePlatform Types
IX_STATIC_CONST_STRING kIX_SharePlatform_Facebook = @"facebook";
IX_STATIC_CONST_STRING kIX_SharePlatform_Twitter = @"twitter";
IX_STATIC_CONST_STRING kIX_SharePlatform_Flickr = @"flickr";
IX_STATIC_CONST_STRING kIX_SharePlatform_Vimeo = @"vimeo";
IX_STATIC_CONST_STRING kIX_SharePlatform_SinaWeibo = @"sinaWeibo";

// Social Read-Only Properties
IX_STATIC_CONST_STRING kIX_Facebook_Available = @"isAllowed.facebook";
IX_STATIC_CONST_STRING kIX_Twitter_Available = @"isAllowed.twitter";
IX_STATIC_CONST_STRING kIX_Flickr_Available = @"isAllowed.flickr";
IX_STATIC_CONST_STRING kIX_Vimeo_Available = @"isAvailable.vimeo";
IX_STATIC_CONST_STRING kIX_Sina_Weibo_Available = @"isAllowed.sinaWeibo";
IX_STATIC_CONST_STRING kIXLastError = @"error.message";

// Social Events
IX_STATIC_CONST_STRING kIX_Share_Done = @"success";
IX_STATIC_CONST_STRING kIX_Share_Error = @"error";
IX_STATIC_CONST_STRING kIX_Share_Cancelled = @"cancelled";

// Social Functions
IX_STATIC_CONST_STRING kIX_Present_Share_Controller = @"present"; // Params : "animated"
IX_STATIC_CONST_STRING kIX_Dismiss_Share_Controller = @"dismiss"; // Params : "animated"

@interface  IXSocial ()

@property (nonatomic,strong) SLComposeViewController* composeViewController;
@property (nonatomic,copy) SLComposeViewControllerCompletionHandler composeViewControllerCompletionBlock;

@property (nonatomic,strong) NSString* shareServiceType;
@property (nonatomic,strong) NSString* shareInitialText;
@property (nonatomic,strong) UIImage* shareImage;
@property (nonatomic,strong) NSURL* shareUrl;
@property (nonatomic,strong) NSString* errorMessage;

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

    [self setShareUrl:[NSURL URLWithString:[[self propertyContainer] getStringPropertyValue:kIX_ShareUrl defaultValue:nil]]];

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
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self presentComposeViewController:animated];
    }
    else if( [functionName isEqualToString:kIX_Dismiss_Share_Controller] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [self dismissComposeViewController:animated];
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
        returnValue = [NSString ix_stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]];
    }
    else if( [propertyName isEqualToString:kIX_Twitter_Available] )
    {
        returnValue = [NSString ix_stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]];
    }
    else if( [propertyName isEqualToString:kIX_Sina_Weibo_Available] )
    {
        returnValue = [NSString ix_stringFromBOOL:[SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]];
    }
    else if( [propertyName isEqualToString:kIXLastError] )
    {
        returnValue = [[self errorMessage] copy];
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
    else
    {
        [self setErrorMessage:[NSString stringWithFormat:@"Service for %@ is unavailable.",[self shareServiceType]]];
        [[self actionContainer] executeActionsForEventNamed:kIX_Share_Error];
    }
}

@end
