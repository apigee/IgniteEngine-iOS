//
//  IXViewController.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXViewController.h"

#import "IXSandbox.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXPropertyContainer.h"
#import "IXActionContainer.h"
#import "IXLayout.h"
#import "IXTextInput.h"
#import "IXClickableScrollView.h"

@interface IXViewController ()

@end

@implementation IXViewController

-(id)init
{
    return [self initWithNibName:nil bundle:nil];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self != nil )
    {
        _sandbox = [[IXSandbox alloc] init];
        [_sandbox setViewController:self];
        
        _propertyContainer = [[IXPropertyContainer alloc] init];
        [_propertyContainer setSandbox:_sandbox];
        
        _containerControl = [[IXLayout alloc] init];
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
    
    [self setAutomaticallyAdjustsScrollViewInsets:![[[IXAppManager sharedInstance] rootViewController] isNavigationBarHidden]];
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
