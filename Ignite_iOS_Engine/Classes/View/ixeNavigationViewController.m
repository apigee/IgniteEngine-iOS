//
//  ixeNavigationViewController.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeNavigationViewController.h"

@implementation ixeNavigationViewController

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
        [self setNavigationBarHidden:NO animated:NO];
        [self setToolbarHidden:YES animated:NO];
        
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//        [self setAutomaticallyAdjustsScrollViewInsets:NO];
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
}

@end
