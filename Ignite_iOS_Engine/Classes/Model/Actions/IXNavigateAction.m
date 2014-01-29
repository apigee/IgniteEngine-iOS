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
#import "IXLayout.h"

@implementation IXNavigateAction

-(void)execute
{
    NSString* navigateStackType = [[self actionProperties] getStringPropertyValue:@"nav_stack_type" defaultValue:@"push"];
    UIViewAnimationTransition animationTransition = [IXNavigateAction stringToViewAnimationTransition:[[self actionProperties] getStringPropertyValue:@"nav_animation_type" defaultValue:@"default"]];

    if( [navigateStackType isEqualToString:@"push"] )
    {
        [self performPushNavigation:animationTransition];
    }
    else if( [navigateStackType isEqualToString:@"pop"] )
    {
        [self performPopNavigation:animationTransition];
    }
}

+(UIViewAnimationTransition)stringToViewAnimationTransition:(NSString*)string
{
    UIViewAnimationTransition transition = UIViewAnimationTransitionNone;
    if( [string isEqualToString:@"flip_from_left"] )
    {
        transition = UIViewAnimationTransitionFlipFromLeft;
    }
    else if( [string isEqualToString:@"flip_from_right"] )
    {
        transition = UIViewAnimationTransitionFlipFromRight;
    }
    else if( [string isEqualToString:@"curl_up"] )
    {
        transition = UIViewAnimationTransitionCurlUp;
    }
    else if( [string isEqualToString:@"curl_down"] )
    {
        transition = UIViewAnimationTransitionCurlDown;
    }
    return transition;
}

-(void)performPopNavigation:(UIViewAnimationTransition)animationTranisitionType
{
    IXNavigationViewController* navController = [[IXAppManager sharedAppManager] rootViewController];
    if( [[navController viewControllers] count] > 1 )
    {
        NSString* popToViewID = [[self actionProperties] getStringPropertyValue:@"nav_pop_to_view_id" defaultValue:nil];
        UIViewController* viewControllerToPopTo = [navController viewControllerWithID:popToViewID];
                
        if ( animationTranisitionType == UIViewAnimationOptionTransitionNone )
        {
            [self finishPopToNavigationTo:viewControllerToPopTo animated:YES];
        }
        else
        {
            CGFloat delay = [[self actionProperties] getFloatPropertyValue:@"nav_animation_delay" defaultValue:0.0f];
            CGFloat duration = [[self actionProperties] getFloatPropertyValue:@"nav_animation_duration" defaultValue:0.75f];
            [UIView animateWithDuration:duration
                                  delay:delay
                                options:0
                             animations:^{
                                 
                                 [self finishPopToNavigationTo:viewControllerToPopTo animated:NO];
                                 [UIView setAnimationTransition:animationTranisitionType
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
}

-(void)performPushNavigation:(UIViewAnimationTransition)animationTranisitionType
{
    NSString* navigateTo = [[self actionProperties] getPathPropertyValue:@"to" basePath:nil defaultValue:nil];
    NSString* pathToJSON = [[NSBundle mainBundle] pathForResource:navigateTo ofType:nil];
    if( pathToJSON )
    {
        [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:pathToJSON
                                                     asynch:YES
                                            completionBlock:^(id jsonObject, NSError *error) {
                                                
                                                IXViewController* viewController = nil;
                                                id viewDictJSONValue = [jsonObject objectForKey:@"view"];
                                                if( [viewDictJSONValue isKindOfClass:[NSDictionary class]] )
                                                {
                                                    viewController = [IXJSONParser viewControllerWithViewDictionary:viewDictJSONValue];
                                                }
                                                
                                                if( viewController != nil )
                                                {
                                                    UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
                                                    if ( animationTranisitionType == UIViewAnimationOptionTransitionNone )
                                                    {
                                                        [navController pushViewController:viewController animated:YES];
                                                    }
                                                    else
                                                    {
                                                        CGFloat delay = [[self actionProperties] getFloatPropertyValue:@"nav_animation_delay" defaultValue:0.0f];
                                                        CGFloat duration = [[self actionProperties] getFloatPropertyValue:@"nav_animation_duration" defaultValue:0.75f];
                                                        [UIView animateWithDuration:duration
                                                                              delay:delay
                                                                            options:0
                                                                         animations:^{
                                                                             
                                                                             [navController pushViewController:viewController animated:NO];
                                                                             [UIView setAnimationTransition:animationTranisitionType
                                                                                                    forView:[navController view]
                                                                                                      cache:NO];
                                                                         } completion:nil];
                                                    }
                                                }
                                            }];
    }
}

@end
