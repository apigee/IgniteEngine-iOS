//
//  IXNavigationViewController.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXNavigationViewController.h"

#import "IXViewController.h"
#import "IXLayout.h"

@interface IXNavigationViewController ()

@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer* rightScreenPanGestureRecognizer;
@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer* leftScreenPanGestureRecognizer;

@end

@implementation IXNavigationViewController

-(void)dealloc
{
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
        [[self navigationBar] setBackgroundColor:[UIColor clearColor]];
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

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer*)screenEdgePanGestureRecognizer
{
    if( [screenEdgePanGestureRecognizer state] == UIGestureRecognizerStateEnded )
    {
        if( [[self visibleViewController] isKindOfClass:[IXViewController class]] )
        {
            IXViewController* viewController = (IXViewController*)[self visibleViewController];
            if( screenEdgePanGestureRecognizer == [self rightScreenPanGestureRecognizer] )
            {
                [[viewController actionContainer] executeActionsForEventNamed:@"screen_pan_right"];
            }
            else if( screenEdgePanGestureRecognizer == [self leftScreenPanGestureRecognizer] )
            {
                [[viewController actionContainer] executeActionsForEventNamed:@"screen_pan_left"];
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

@end
