//
//  IXNavigateAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/27/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXNavigateAction.h"

#import "IXPropertyContainer.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXJSONGrabber.h"
#import "IXJSONParser.h"
#import "IXAppManager.h"
#import "IXLogger.h"

// IXNavigateAction Properties
static NSString* const kIXTo = @"to";
static NSString* const kIXNavStackType = @"nav_stack_type";
static NSString* const kIXNavAnimationType = @"nav_animation_type";
static NSString* const kIXNavPopToViewID = @"nav_pop_to_view_id";
static NSString* const kIXNavAnimationDelay = @"nav_animation_delay";
static NSString* const kIXNavAnimationDuration = @"nav_animation_duration";

// kIXNavStackType Types
static NSString* const kIXNavStackTypePush = @"push";
static NSString* const kIXNavStackTypePop = @"pop";
static NSString* const kIXNavStackTypeReplace = @"replace";

// kIXNavAnimationType Types
static NSString* const kIXNavAnimationTypeDefault = @"default";
static NSString* const kIXNavAnimationTypeFlipFromLeft = @"flip_from_left";
static NSString* const kIXNavAnimationTypeFlipFromRight = @"flip_from_right";
static NSString* const kIXNavAnimationTypeCurlUp = @"curl_up";
static NSString* const kIXNavAnimationTypeCurlDown = @"curl_down";

// IXNavigateAction Events
static NSString* const kIXSuccess = @"success";
static NSString* const kIXFailed = @"failed";

static BOOL sIXIsAttemptingNavigation = NO;

@interface IXNavigateAction ()

@property (nonatomic,assign) UIViewAnimationTransition navAnimationTransitionType;
@property (nonatomic,assign) CGFloat navAnimationDelay;
@property (nonatomic,assign) CGFloat navAnimationDuration;

@end

@implementation IXNavigateAction

-(void)navigationActionDidFinish:(BOOL)didSucceed
{
    sIXIsAttemptingNavigation = NO;
    if( didSucceed )
    {
        [self actionDidFinishWithEvents:@[kIXSuccess]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIXFailed]];
    }
}

-(void)execute
{
    if( !sIXIsAttemptingNavigation )
    {
        sIXIsAttemptingNavigation = YES;

        NSString* navigateStackType = [[self actionProperties] getStringPropertyValue:kIXNavStackType defaultValue:kIXNavStackTypePush];
        
        [self setNavAnimationTransitionType:[IXNavigateAction stringToViewAnimationTransition:[[self actionProperties] getStringPropertyValue:kIXNavAnimationType defaultValue:kIXNavAnimationTypeDefault]]];
        [self setNavAnimationDelay:[[self actionProperties] getFloatPropertyValue:kIXNavAnimationDelay defaultValue:0.0f]];
        [self setNavAnimationDuration:[[self actionProperties] getFloatPropertyValue:kIXNavAnimationDuration defaultValue:0.75f]];
        
        if( [navigateStackType isEqualToString:kIXNavStackTypePop] )
        {
            [self performPopNavigation];
        }
        if( [navigateStackType isEqualToString:kIXNavStackTypePush] )
        {
            [self performPushNavigation:NO];
        }
        else if( [navigateStackType isEqualToString:kIXNavStackTypeReplace] )
        {
            [self performPushNavigation:YES];
        }
        else
        {
            [self navigationActionDidFinish:NO];
        }
    }
}

+(UIViewAnimationTransition)stringToViewAnimationTransition:(NSString*)string
{
    UIViewAnimationTransition transition = UIViewAnimationTransitionNone;
    if( [string isEqualToString:kIXNavAnimationTypeFlipFromLeft] )
    {
        transition = UIViewAnimationTransitionFlipFromLeft;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeFlipFromRight] )
    {
        transition = UIViewAnimationTransitionFlipFromRight;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeCurlUp] )
    {
        transition = UIViewAnimationTransitionCurlUp;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeCurlDown] )
    {
        transition = UIViewAnimationTransitionCurlDown;
    }
    return transition;
}

-(void)performPopNavigation
{
    IXNavigationViewController* navController = [[IXAppManager sharedAppManager] rootViewController];
    if( [[navController viewControllers] count] > 1 )
    {
        NSString* popToViewID = [[self actionProperties] getStringPropertyValue:kIXNavPopToViewID defaultValue:nil];
        UIViewController* viewControllerToPopTo = [navController viewControllerWithID:popToViewID];
                
        if ( [self navAnimationTransitionType] == UIViewAnimationOptionTransitionNone )
        {
            [self finishPopToNavigationTo:viewControllerToPopTo animated:YES];
        }
        else
        {
            [UIView animateWithDuration:[self navAnimationDuration]
                                  delay:[self navAnimationDelay]
                                options:0
                             animations:^{
                                 
                                 [self finishPopToNavigationTo:viewControllerToPopTo animated:NO];
                                 [UIView setAnimationTransition:[self navAnimationTransitionType]
                                                        forView:[navController view]
                                                          cache:NO];
                             } completion:nil];
        }
    }
}

-(void)finishPopToNavigationTo:(UIViewController*)viewController animated:(BOOL)animated
{
    UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
    if( [[navController viewControllers] count] > 1 )
    {
        if( viewController )
        {
            if( viewController == [[navController viewControllers] firstObject] )
            {
                [navController popToRootViewControllerAnimated:animated];
            }
            else
            {
                [navController popToViewController:viewController animated:animated];
            }
        }
        else
        {
            [navController popViewControllerAnimated:animated];
        }
    }
    
    [self navigationActionDidFinish:YES];
}

-(void)performPushNavigation:(BOOL)isReplaceStackType
{
    NSString* navigateTo = [[self actionProperties] getPathPropertyValue:kIXTo basePath:nil defaultValue:nil];
    if( navigateTo )
    {
        [IXJSONParser viewControllerWithPathToJSON:navigateTo
                                         loadAsync:YES
                                   completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                       
                                       if( didSucceed && viewController != nil )
                                       {
                                           [self finishPushNavigationTo:viewController
                                                     isReplaceStackType:isReplaceStackType];
                                       }
                                       else
                                       {
                                           DDLogError(@"ERROR: from %@ in %@ : Error performing push navigation. Description : %@",THIS_FILE,THIS_METHOD,[error description]);
                                           [self navigationActionDidFinish:NO];
                                       }
        }];
    }
}

-(void)finishPushNavigationTo:(UIViewController*)viewController isReplaceStackType:(BOOL)isReplaceStackType
{
    if( viewController != nil )
    {
        UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
        if ( [self navAnimationTransitionType] == UIViewAnimationOptionTransitionNone )
        {
            if( isReplaceStackType )
            {
                [navController setViewControllers:@[viewController] animated:YES];
            }
            else
            {
                [navController pushViewController:viewController animated:YES];
            }
            
            [self navigationActionDidFinish:YES];
        }
        else
        {
            [UIView animateWithDuration:[self navAnimationDuration]
                                  delay:[self navAnimationDelay]
                                options:0
                             animations:^{
                                 
                                 if( isReplaceStackType )
                                 {
                                     [navController setViewControllers:@[viewController] animated:NO];
                                 }
                                 else
                                 {
                                     [navController pushViewController:viewController animated:NO];
                                 }
                                 
                                 [UIView setAnimationTransition:[self navAnimationTransitionType]
                                                        forView:[navController view]
                                                          cache:NO];
                                 
                             } completion:^(BOOL finished) {
                                 [self navigationActionDidFinish:YES];
                             }];
        }
    }
}

@end
