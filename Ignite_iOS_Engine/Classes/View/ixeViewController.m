//
//  ixeViewController.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeViewController.h"

#import "ixeSandbox.h"
#import "ixeAppManager.h"
#import "ixeNavigationViewController.h"
#import "ixePropertyContainer.h"
#import "ixeActionContainer.h"
#import "ixeLayout.h"
#import "ixeTextInput.h"
#import "ixeClickableScrollView.h"

@interface ixeViewController ()

@end

@implementation ixeViewController

-(id)init
{
    return [self initWithNibName:nil bundle:nil];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self != nil )
    {
        _sandbox = [[ixeSandbox alloc] init];
        [_sandbox setViewController:self];
        
        _propertyContainer = [[ixePropertyContainer alloc] init];
        [_propertyContainer setSandbox:_sandbox];
        
        _containerControl = [[ixeLayout alloc] init];
        [_containerControl setID:@"view"];
        [_containerControl setSandbox:_sandbox];
        
        [_sandbox setContainerControl:_containerControl];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // To change the frame to underlap the status bar
    //    CGRect frame = [[self view] frame];
    //    frame.origin = CGPointMake(0, -[[UIApplication sharedApplication] statusBarFrame].size.height);
    //    [[self view] setFrame:frame];
    
    
    [self setWantsFullScreenLayout:YES];
    [[self view] setClipsToBounds:YES];
    
    [self setAutomaticallyAdjustsScrollViewInsets:![[[ixeAppManager sharedInstance] rootViewController] isNavigationBarHidden]];
    [[self view] addSubview:[_containerControl contentView]];
    // FIXME: need to set some default values here for the container control and add the view properties to it.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self applySettings];
    [self layoutControls];
    [[self sandbox] loadAllDataProviders];

    [[[self containerControl] actionContainer] executeActionsForEventNamed:@"will_appear"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[[self containerControl] actionContainer] executeActionsForEventNamed:@"did_appear"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[self containerControl] actionContainer] executeActionsForEventNamed:@"will_disappear"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[[self containerControl] actionContainer] executeActionsForEventNamed:@"did_disappear"];
}

-(void)layoutControls
{
    [[_containerControl contentView] setFrame:[[self view] bounds]];
    [_containerControl layoutControl];
}

-(void)applySettings
{
    UIColor* backgroundColor = [[self propertyContainer] getColorPropertyValue:@"color.background" defaultValue:[UIColor clearColor]];
    [[self view] setBackgroundColor:backgroundColor];

    [_containerControl applySettings];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self applySettings];
    [self layoutControls];
}

@end
