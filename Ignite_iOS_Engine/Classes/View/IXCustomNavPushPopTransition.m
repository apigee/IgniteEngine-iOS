//
//  IXCustomNavPushPopTransition.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 5/2/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCustomNavPushPopTransition.h"

@implementation IXCustomNavPushPopTransition

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _isPushNavigation = NO;
        _duration = 0.25f;
    }
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [self duration];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    CGRect currentViewFrame = [[fromVC view] frame];
    CGFloat currentViewWidth = currentViewFrame.size.width;
    
    CGRect toVCStartFrame = CGRectOffset(currentViewFrame,([self isPushNavigation] ? currentViewWidth : -currentViewWidth),0.0f);
    CGRect fromVCEndFrame = CGRectOffset(currentViewFrame,([self isPushNavigation] ? -currentViewWidth : currentViewWidth),0.0f);

    [[toVC view] setFrame:toVCStartFrame];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
                        options:0.0f
                     animations:^{
                         [[fromVC view] setFrame:fromVCEndFrame];
                         [[toVC view] setFrame:currentViewFrame];
                     }
                     completion:^(BOOL finished) {
                         [fromVC.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
