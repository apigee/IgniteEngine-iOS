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
#import "IXPathHandler.h"

@interface IXViewController ()

@property (nonatomic,assign) BOOL hasAppeared;
@property (nonatomic,copy) NSString* statusBarPreferredStyleString;

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
        if( [IXPathHandler pathIsLocal:pathToJSON] )
        {
            jsonRootPath = [pathToJSON stringByDeletingLastPathComponent];
        }
        else
        {
            jsonRootPath = [[[NSURL URLWithString:pathToJSON] URLByDeletingLastPathComponent] absoluteString];
        }
        
        _sandbox = [[IXSandbox alloc] initWithBasePath:nil rootPath:jsonRootPath];
        [_sandbox setViewController:self];
        
        _containerControl = [[IXLayout alloc] init];
        [_containerControl setSandbox:_sandbox];
        
        [_sandbox setContainerControl:_containerControl];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setView:[_containerControl contentView]];
    [[self view] setClipsToBounds:YES];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( ![self hasAppeared] )
    {
        [self setHasAppeared:YES];
        [[self sandbox] loadAllDataProviders];
        [self fireViewEventNamed:@"will_first_appear"];
    }
    
    [self applySettings];
    [self layoutControls];

    [self fireViewEventNamed:@"will_appear"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fireViewEventNamed:@"did_appear"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self fireViewEventNamed:@"will_disappear"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
 
    [self fireViewEventNamed:@"did_disappear"];
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

-(void)fireViewEventNamed:(NSString *)eventName
{
    [[[self containerControl] actionContainer] executeActionsForEventNamed:eventName];
}

-(NSString*)getViewPropertyNamed:(NSString*)propertyName
{
    NSString* viewPropertyValue = [[self containerControl] getReadOnlyPropertyValue:propertyName];
    if( viewPropertyValue == nil )
    {
        viewPropertyValue = [[[self containerControl] propertyContainer] getStringPropertyValue:propertyName defaultValue:nil];
    }
    return viewPropertyValue;
}

-(void)applySettings
{
    IXPropertyContainer* propertyContainer = [[self containerControl] propertyContainer];
    NSString* statusBarStyle = [propertyContainer getStringPropertyValue:@"status_bar_style" defaultValue:@"dark"];
    if( ![[self statusBarPreferredStyleString] isEqualToString:statusBarStyle] )
    {
        [self setStatusBarPreferredStyleString:statusBarStyle];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    UIColor* backgroundColor = [propertyContainer getColorPropertyValue:@"background.color" defaultValue:[UIColor clearColor]];
    [[self view] setBackgroundColor:backgroundColor];

    /*
     //TODO - obviously this failed miserably! Go Brandon.
    NSString* backgroundImage = [[self propertyContainer] getStringPropertyValue:@"images.background" defaultValue:nil];
    if (backgroundImage)
    {
        [[self propertyContainer] getImageProperty:backgroundImage
                                      successBlock:^(UIImage *image) {
                                          [[self view] setBackgroundImage:
                                      } failBlock:^(NSError *error) {
                                      }];
    }
    */
    [[self containerControl] applySettings];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle preferredStatusBarStyle = UIStatusBarStyleDefault;
    if( [[self statusBarPreferredStyleString] isEqualToString:@"light"] )
    {
        preferredStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return preferredStatusBarStyle;
}

-(BOOL)prefersStatusBarHidden
{
    return ( [[self statusBarPreferredStyleString] isEqualToString:@"hidden"] );
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self applySettings];
    [self layoutControls];
}

@end
