//
//  IXCustomNavPushPopTransition.m
//  Ignite Engine
//
//  Created by Robert Walsh on 5/2/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXCustomNavPushPopTransition.h"

@implementation IXCustomNavPushPopTransition

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _isPushNavigation = NO;
        _duration = 0.75f;
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
