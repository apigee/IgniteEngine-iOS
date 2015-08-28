//
//  IXNavigationViewController.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
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

#import "IXNavigationViewController.h"

#import "IXViewController.h"
#import "IXLayout.h"
#import "SDWebImageManager.h"
#import "IXDataLoader.h"
#import "IXAttributeContainer.h"
#import "IXControlCacheContainer.h"

@interface IXNavigationViewController () <UINavigationControllerDelegate>

@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer* rightScreenPanGestureRecognizer;
@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer* leftScreenPanGestureRecognizer;

@end

@implementation IXNavigationViewController

-(void)dealloc
{
    [self setDelegate:nil];
    [_leftScreenPanGestureRecognizer removeTarget:self action:@selector(handleScreenEdgePan:)];
    [_rightScreenPanGestureRecognizer removeTarget:self action:@selector(handleScreenEdgePan:)];
}

-(id)init
{
    return [self initWithNibName:nil bundle:nil];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self != nil )
    {
        [self setDelegate:self];
        [[self navigationBar] setBackgroundColor:[UIColor clearColor]];
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [[UIImage alloc] init];        
//        [self setNavigationBarHidden:NO animated:NO];
//        [self setToolbarHidden:YES animated:NO];
        
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
//        [[UINavigationBar appearance] ]
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"picture.png"] forBarMetrics:UIBarMetricsDefault];
//        [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
//        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x067AB5)];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    if( [self rightScreenPanGestureRecognizer] == nil )
    {
        [self setRightScreenPanGestureRecognizer:[[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)]];
        [[self rightScreenPanGestureRecognizer] setEdges:UIRectEdgeRight];
        [[self view] addGestureRecognizer:[self rightScreenPanGestureRecognizer]];
    }
    if( [self leftScreenPanGestureRecognizer] == nil )
    {
        [self setLeftScreenPanGestureRecognizer:[[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)]];
        [[self leftScreenPanGestureRecognizer] requireGestureRecognizerToFail:[self interactivePopGestureRecognizer]];
        [[self leftScreenPanGestureRecognizer] setEdges:UIRectEdgeLeft];
        [[self view] addGestureRecognizer:[self leftScreenPanGestureRecognizer]];
    }
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    if( [self isNavigationBarHidden] )
    {
        [[self interactivePopGestureRecognizer] setEnabled:YES];
        [[self interactivePopGestureRecognizer] setDelegate:nil];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[self leftScreenPanGestureRecognizer] removeTarget:self action:@selector(handleScreenEdgePan:)];
    [[self view] removeGestureRecognizer:[self leftScreenPanGestureRecognizer]];
    [self setLeftScreenPanGestureRecognizer:nil];
    [self setLeftScreenPanGestureRecognizer:[[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)]];
    [[self leftScreenPanGestureRecognizer] setEdges:UIRectEdgeLeft];

    if( [[self viewControllers] count] > 1 )
    {
        [[self leftScreenPanGestureRecognizer] requireGestureRecognizerToFail:[self interactivePopGestureRecognizer]];
    }
    
    [[self view] addGestureRecognizer:[self leftScreenPanGestureRecognizer]];
}

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer*)screenEdgePanGestureRecognizer
{
    if( [screenEdgePanGestureRecognizer state] == UIGestureRecognizerStateEnded )
    {
        if( [[self visibleViewController] isKindOfClass:[IXViewController class]] )
        {
            IXViewController* viewController = (IXViewController*)[self visibleViewController];
            if( screenEdgePanGestureRecognizer == [self rightScreenPanGestureRecognizer] )
            {
                [viewController fireViewEventNamed:@"screen_pan_right"];
            }
            else if( screenEdgePanGestureRecognizer == [self leftScreenPanGestureRecognizer] )
            {
                [viewController fireViewEventNamed:@"screen_pan_left"];
            }
        }
    }
}

-(IXViewController*)viewControllerWithID:(NSString*)viewControllerID
{
    IXViewController* viewControllerWithID = nil;
    if( [viewControllerID length] > 0 )
    {
        if( [viewControllerID isEqualToString:@"root"] )
        {
            viewControllerWithID = [[self viewControllers] firstObject];
        }
        else
        {
            for( UIViewController* viewController in [[[self viewControllers] reverseObjectEnumerator] allObjects] )
            {
                if( [viewController isKindOfClass:[IXViewController class]] )
                {
                    IXViewController* ixViewController = (IXViewController*)viewController;
                    if( [[[ixViewController containerControl] ID] isEqualToString:viewControllerID] )
                    {
                        viewControllerWithID = ixViewController;
                        break;
                    }
                }
            }
        }
    }
    return viewControllerWithID;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [IXDataLoader clearCache];
    [IXControlCacheContainer clearCache];
    for( UIViewController* viewController in [self viewControllers] )
    {
        if( [viewController isKindOfClass:[IXViewController class]] )
        {
            IXViewController* vc = (IXViewController*)viewController;
            [[vc containerControl] conserveMemory];
        }
    }
}

@end
