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

@implementation IXNavigationViewController

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

    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    if( [self isNavigationBarHidden] )
    {
        [[self interactivePopGestureRecognizer] setEnabled:YES];
        [[self interactivePopGestureRecognizer] setDelegate:nil];
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
