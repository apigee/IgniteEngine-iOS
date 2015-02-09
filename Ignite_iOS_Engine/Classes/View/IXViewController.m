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
#import "IXControlCacheContainer.h"

// Attributes
IX_STATIC_CONST_STRING kIXStatusBarStyle = @"statusBar.style";
IX_STATIC_CONST_STRING kIXBgColor = @"bg.color";

// Attribute values
IX_STATIC_CONST_STRING kIXStatusBarStyleDark = @"dark";
IX_STATIC_CONST_STRING kIXStatusBarStyleLight = @"light";
IX_STATIC_CONST_STRING kIXStatusBarStyleHidden = @"hidden";

// Events
IX_STATIC_CONST_STRING kIXWillFirstAppear = @"willFirstAppear";
IX_STATIC_CONST_STRING kIXWillAppear = @"willAppear";
IX_STATIC_CONST_STRING kIXDidAppear = @"didAppear";
IX_STATIC_CONST_STRING kIXWillDisappear = @"willDisappear";
IX_STATIC_CONST_STRING kIXDidDisappear = @"didDisappear";

// Functions
IX_STATIC_CONST_STRING kIXStateSave = @"state.save";
IX_STATIC_CONST_STRING kIXStateClear = @"state.clear";
IX_STATIC_CONST_STRING kIXCacheId = @"cache.id";

// NSCoding Key Constants
static NSString* const kIXSandboxNSCodingKey = @"sandbox";
static NSString* const kIXContainerControlNSCodingKey = @"containerControl";

@interface IXViewController ()

@property (nonatomic,strong) IXSandbox* sandbox;
@property (nonatomic,strong) IXLayout* containerControl;
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

+(void)createViewControllerWithPathToJSON:(NSString*)pathToJSON loadAsync:(BOOL)loadAsync completionBlock:(IXViewControllerCreationCompletionBlock)completionBlock
{
    IXViewController* viewController = [[[self class] alloc] initWithNibName:nil bundle:nil pathToJSON:pathToJSON];
    [IXControlCacheContainer populateControl:[viewController containerControl]
                              withJSONAtPath:pathToJSON
                                   loadAsync:loadAsync
                             completionBlock:^(BOOL didSucceed,IXBaseControl* populatedControl,NSError* error) {
                                 if( completionBlock )
                                 {
                                     if( didSucceed )
                                     {
                                         completionBlock(didSucceed,viewController,error);
                                     }
                                     else
                                     {
                                         completionBlock(didSucceed,nil,error);
                                     }
                                 }
                             }];
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
        [_containerControl setTopLevelViewControllerLayout:YES];
        [_containerControl setSandbox:_sandbox];
        
        [_sandbox setContainerControl:_containerControl];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self sandbox] forKey:kIXSandboxNSCodingKey];
    [aCoder encodeObject:[self containerControl] forKey:kIXContainerControlNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithNibName:nil bundle:nil];
    if( self != nil )
    {
        [self setSandbox:[aDecoder decodeObjectForKey:kIXSandboxNSCodingKey]];
        [[self sandbox] setViewController:self];
        
        [self setContainerControl:[aDecoder decodeObjectForKey:kIXContainerControlNSCodingKey]];
        [[self containerControl] setTopLevelViewControllerLayout:YES];
        [[self containerControl] setSandbox:[self sandbox]];
        
        [[self sandbox] setContainerControl:[self containerControl]];
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
    
    [self applySettings];
    [self layoutControls];
    
    if( ![self hasAppeared] )
    {
        [self setHasAppeared:YES];
        [[self sandbox] loadAllDataProviders];
        [self fireViewEventNamed:kIXWillFirstAppear];
    }
    
    [self fireViewEventNamed:kIXWillAppear];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fireViewEventNamed:kIXDidAppear];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self fireViewEventNamed:kIXWillDisappear];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
 
    [self fireViewEventNamed:kIXDidDisappear];
}

//- (void) viewDidLayoutSubviews {
//    // only works for iOS 7+
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect viewBounds = self.view.bounds;
//        CGFloat topBarOffset = self.topLayoutGuide.length;
//        
//        // snaps the view under the status bar (iOS 6 style)
//        viewBounds.origin.y = topBarOffset * -1;
//        
//        // shrink the bounds of your view to compensate for the offset
//        viewBounds.size.height = viewBounds.size.height + (topBarOffset * -1);
////        self.view.bounds = viewBounds;
//    }
//}

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

-(void)applyViewControllerSpecificSettings
{
    IXPropertyContainer* propertyContainer = [[self containerControl] propertyContainer];
    NSString* statusBarStyle = [propertyContainer getStringPropertyValue:kIXStatusBarStyle defaultValue:kIXStatusBarStyleDark];
    if( ![[self statusBarPreferredStyleString] isEqualToString:statusBarStyle] )
    {
        [self setStatusBarPreferredStyleString:statusBarStyle];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    UIColor* backgroundColor = [propertyContainer getColorPropertyValue:kIXBgColor defaultValue:[UIColor clearColor]];
    [[self view] setBackgroundColor:backgroundColor];
}

-(void)applySettings
{
    [self applyViewControllerSpecificSettings];
    [[self containerControl] applySettings];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStateSave] )
    {
        NSString* viewID = [[self containerControl] ID];
        if( [viewID length] > 0 )
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
            if( data != nil )
            {
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:viewID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    else if( [functionName isEqualToString:kIXStateClear] )
    {
        NSString* viewID = [parameterContainer getStringPropertyValue:kIXCacheId defaultValue:nil];
        if( viewID != nil )
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:viewID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle preferredStatusBarStyle = UIStatusBarStyleDefault;
    if( [[self statusBarPreferredStyleString] isEqualToString:kIXStatusBarStyleLight] )
    {
        preferredStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return preferredStatusBarStyle;
}

-(BOOL)prefersStatusBarHidden
{
    return ( [[self statusBarPreferredStyleString] isEqualToString:kIXStatusBarStyleHidden] );
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self applySettings];
    [self layoutControls];
}

@end
