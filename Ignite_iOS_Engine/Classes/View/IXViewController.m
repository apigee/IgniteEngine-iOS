//
//  IXViewController.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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

@property (nonatomic,assign) BOOL hasAppeared;

@end

@implementation IXViewController

-(instancetype)init
{
    return [self initWithNibName:nil bundle:nil pathToJSON:nil];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil pathToJSON:nil];
}

-(instancetype)initWithPathToJSON:(NSString*)pathToJSON
{
    return [self initWithNibName:nil bundle:nil pathToJSON:pathToJSON];
}

+(instancetype)viewControllerWithPathToJSON:(NSString*)pathToJSON
{
    return [[[self class] alloc] initWithNibName:nil bundle:nil pathToJSON:pathToJSON];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pathToJSON:(NSString*)pathToJSON
{
    self = [super initWithNibName:nil bundle:nil];
    if( self != nil )
    {
        NSString* jsonRootPath = nil;
        if( [IXAppManager pathIsLocal:pathToJSON] )
        {
            jsonRootPath = [pathToJSON stringByDeletingLastPathComponent];
        }
        else
        {
            jsonRootPath = [[[NSURL URLWithString:pathToJSON] URLByDeletingLastPathComponent] absoluteString];
        }
        
        _sandbox = [[IXSandbox alloc] initWithBasePath:nil rootPath:jsonRootPath];
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
    
    [self setView:[_containerControl contentView]];

    // To change the frame to underlap the status bar
//    CGRect frame = [[self view] frame];
//    frame.origin = CGPointMake(0, -[[UIApplication sharedApplication] statusBarFrame].size.height);
//    [[self view] setFrame:frame];
    
    
//    [self setWantsFullScreenLayout:YES];
    [[self view] setClipsToBounds:YES];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];//![[[IXAppManager sharedAppManager] rootViewController] isNavigationBarHidden]];
//    [[self view] addSubview:[_containerControl contentView]];
    // FIXME: need to set some default values here for the container control and add the view properties to it.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( ![self hasAppeared] )
    {
        [self setHasAppeared:YES];
        [[self sandbox] loadAllDataProviders];
        [[[self containerControl] actionContainer] executeActionsForEventNamed:@"will_first_appear"];
    }
    
    [self applySettings];
    [self layoutControls];

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

- (void) viewDidLayoutSubviews {
    // only works for iOS 7+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        
        // snaps the view under the status bar (iOS 6 style)
        viewBounds.origin.y = topBarOffset * -1;
        
        // shrink the bounds of your view to compensate for the offset
        viewBounds.size.height = viewBounds.size.height + (topBarOffset * -1);
//        self.view.bounds = viewBounds;
    }
}

-(void)layoutControls
{
//    CGRect frame = [[self view] frame];
//    CGRect bounds = [[self view] bounds];
//    [[[self containerControl] contentView] setFrame:[[self view] bounds]];
    [[self containerControl] layoutControl];
}

-(void)applySettings
{
    UIColor* backgroundColor = [[self propertyContainer] getColorPropertyValue:@"color.background" defaultValue:[UIColor clearColor]];
    [[self view] setBackgroundColor:backgroundColor];

    [[self containerControl] applySettings];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self applySettings];
    [self layoutControls];
}

@end
