//
//  IXNavigateAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/27/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXNavigateAction.h"

#import "IXPropertyContainer.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXSandbox.h"
#import "IXCustomNavPushPopTransition.h"
#import "IXLayout.h"

// IXNavigateAction Properties
static NSString* const kIXTo = @"to";
static NSString* const kIXNavStackType = @"nav_stack_type";
static NSString* const kIXNavAnimationType = @"nav_animation_type";
static NSString* const kIXNavPopToViewID = @"nav_pop_to_view_id";
static NSString* const kIXNavAnimationDelay = @"nav_animation_delay";
static NSString* const kIXNavAnimationDuration = @"nav_animation_duration";

// kIXNavStackType Types
static NSString* const kIXNavStackTypePush = @"push";
static NSString* const kIXNavStackTypePop = @"pop";
static NSString* const kIXNavStackTypeReplace = @"replace";
static NSString* const kIXNavStackTypeExternal = @"external";

// kIXNavAnimationType Types
static NSString* const kIXNavAnimationTypeFlipFromLeft = @"flip_from_left";
static NSString* const kIXNavAnimationTypeFlipFromRight = @"flip_from_right";
static NSString* const kIXNavAnimationTypeFlipFromTop = @"flip_from_top";
static NSString* const kIXNavAnimationTypeFlipFromBottom = @"flip_from_bottom";
static NSString* const kIXNavAnimationTypeCurlUp = @"curl_up";
static NSString* const kIXNavAnimationTypeCurlDown = @"curl_down";
static NSString* const kIXNavAnimationTypeCrossDissolve = @"cross_dissolve";
static NSString* const kIXNavAnimationTypeMoveIn = @"move_in";

// IXNavigateAction Events: kIX_SUCCESS and kIX_FAILED

static BOOL sIXIsAttemptingNavigation = NO;
typedef void(^IXNavAnimationCompletionBlock)();

@interface IXNavigateAction () <UINavigationControllerDelegate>

@property (nonatomic,assign) BOOL usesCustomPushAndPopNavigationTransition;
@property (nonatomic,assign) BOOL isReplaceStackType;
@property (nonatomic,assign) UIViewAnimationOptions navAnimationTransitionType;
@property (nonatomic,assign) CGFloat navAnimationDelay;
@property (nonatomic,assign) CGFloat navAnimationDuration;

@end

@implementation IXNavigateAction

+(BOOL)isAttemptingNavigation
{
    return sIXIsAttemptingNavigation;
}

+(UIViewAnimationOptions)stringToViewAnimationTransition:(NSString*)string
{
    UIViewAnimationOptions transition = UIViewAnimationOptionTransitionNone;
    if( [string isEqualToString:kIXNavAnimationTypeFlipFromLeft] )
    {
        transition = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeFlipFromRight] )
    {
        transition = UIViewAnimationOptionTransitionFlipFromRight;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeFlipFromTop] )
    {
        transition = UIViewAnimationOptionTransitionFlipFromTop;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeFlipFromBottom] )
    {
        transition = UIViewAnimationOptionTransitionFlipFromBottom;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeCurlUp] )
    {
        transition = UIViewAnimationOptionTransitionCurlUp;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeCurlDown] )
    {
        transition = UIViewAnimationOptionTransitionCurlDown;
    }
    else if( [string isEqualToString:kIXNavAnimationTypeCrossDissolve] )
    {
        transition = UIViewAnimationOptionTransitionCrossDissolve;
    }
    return transition;
}

-(void)navigationActionDidFinish:(BOOL)didSucceed
{
    UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
    [navController setDelegate:(id<UINavigationControllerDelegate>)navController];
    
    sIXIsAttemptingNavigation = NO;
    if( didSucceed )
    {
        IXSandbox* appSandbox = [[IXAppManager sharedAppManager] applicationSandbox];
        [appSandbox setViewController:[[IXAppManager sharedAppManager] currentIXViewController]];
        [appSandbox setContainerControl:[[[IXAppManager sharedAppManager] currentIXViewController] containerControl]];
        
        [self actionDidFinishWithEvents:@[kIX_SUCCESS]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIX_FAILED]];
    }
}

-(void)execute
{
    if( !sIXIsAttemptingNavigation )
    {
        UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
        [navController setDelegate:(id<UINavigationControllerDelegate>)navController];

        sIXIsAttemptingNavigation = YES;

        NSString* navigateStackType = [[self actionProperties] getStringPropertyValue:kIXNavStackType defaultValue:kIXNavStackTypePush];
        
        NSString* navAnimationTransitionType = [[self actionProperties] getStringPropertyValue:kIXNavAnimationType defaultValue:kIX_DEFAULT];
        
        if( [navAnimationTransitionType isEqualToString:kIXNavAnimationTypeMoveIn] )
        {
            [self setNavAnimationTransitionType:UIViewAnimationOptionTransitionNone];
            [self setUsesCustomPushAndPopNavigationTransition:YES];
        }
        else
        {
            [self setNavAnimationTransitionType:[IXNavigateAction stringToViewAnimationTransition:navAnimationTransitionType]];
            [self setUsesCustomPushAndPopNavigationTransition:NO];
        }
        
        [self setNavAnimationDelay:[[self actionProperties] getFloatPropertyValue:kIXNavAnimationDelay defaultValue:0.0f]];
        [self setNavAnimationDuration:[[self actionProperties] getFloatPropertyValue:kIXNavAnimationDuration defaultValue:0.75f]];
        
        if( [navigateStackType isEqualToString:kIXNavStackTypePop] )
        {
            [self performPopNavigation];
        }
        else if( [navigateStackType isEqualToString:kIXNavStackTypePush] )
        {
            [self performPushNavigation];
        }
        else if( [navigateStackType isEqualToString:kIXNavStackTypeExternal] )
        {
            [self performExternalNavigation];
        }
        else if( [navigateStackType isEqualToString:kIXNavStackTypeReplace] )
        {
            [self setIsReplaceStackType:YES];
            [self performPushNavigation];
        }
        else
        {
            [self navigationActionDidFinish:NO];
        }
    }
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                 animationControllerForOperation:(UINavigationControllerOperation)operation
                                              fromViewController:(UIViewController *)fromVC
                                                toViewController:(UIViewController *)toVC
{
    IXCustomNavPushPopTransition* customNavPushPopTransition = [[IXCustomNavPushPopTransition alloc] init];
    [customNavPushPopTransition setIsPushNavigation:(operation == UINavigationControllerOperationPush)];
    [customNavPushPopTransition setDuration:[self navAnimationDuration]];
    return customNavPushPopTransition;
}

-(void)performPopNavigation
{
    IXNavigationViewController* navController = [[IXAppManager sharedAppManager] rootViewController];
    if( [[navController viewControllers] count] > 1 )
    {
        NSString* popToViewID = [[self actionProperties] getStringPropertyValue:kIXNavPopToViewID defaultValue:nil];
        UIViewController* viewControllerToPopTo = [navController viewControllerWithID:popToViewID];
        if( viewControllerToPopTo == nil )
        {
            // If the view controller to pop to is nil then get the previous view controller and pop to that.
            IXViewController* currentVC = [[IXAppManager sharedAppManager] currentIXViewController];
            NSUInteger index = [[navController viewControllers] indexOfObject:currentVC];
            if( index > 0 )
            {
                index--;
            }
            viewControllerToPopTo = [[navController viewControllers] objectAtIndex:index];
        }
        
        if( viewControllerToPopTo == nil )
        {
            [self navigationActionDidFinish:NO];
        }
        else
        {
            if ( [self navAnimationTransitionType] == UIViewAnimationOptionTransitionNone )
            {
                UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
                
                if( [self usesCustomPushAndPopNavigationTransition] )
                {
                    [navController setDelegate:self];
                }
                
                if( viewControllerToPopTo == [[navController viewControllers] firstObject] )
                {
                    [navController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    [navController popToViewController:viewControllerToPopTo animated:YES];
                }                
                [self navigationActionDidFinish:YES];
            }
            else
            {
                if( [self navAnimationDelay] > 0.0f )
                {
                    [self performSelector:@selector(animatePopToNavigationTo:)
                               withObject:viewControllerToPopTo
                               afterDelay:[self navAnimationDelay]];
                }
                else
                {
                    [self animatePopToNavigationTo:viewControllerToPopTo];
                }
            }

        }
    }
}

-(void)animatePopToNavigationTo:(UIViewController*)viewController
{
    UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
    if( [[navController viewControllers] count] > 1 && viewController != nil )
    {
        [self performAnimationToView:[viewController view]];
        
        if( viewController == [[navController viewControllers] firstObject] )
        {
            [navController popToRootViewControllerAnimated:NO];
        }
        else
        {
            [navController popToViewController:viewController animated:NO];
        }
    }
    else
    {
        [self navigationActionDidFinish:NO];
    }
}

-(void)performPushNavigation
{
    NSString* archivedViewControllerID = [[self actionProperties] getStringPropertyValue:@"cache_id" defaultValue:nil];
    IXViewController* archivedViewController = nil;
    if( [archivedViewControllerID length] > 0 )
    {        
        NSData* archivedViewControllerData = [[NSUserDefaults standardUserDefaults] dataForKey:archivedViewControllerID];
        if( archivedViewControllerData )
        {
            @try {
                archivedViewController = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewControllerData];
            } @catch (NSException *exception) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:archivedViewControllerID];
            }
        }
    }
    
    if( archivedViewController != nil )
    {
        [self finishPushNavigationTo:archivedViewController];
    }
    else
    {
        NSString* navigateTo = [[self actionProperties] getPathPropertyValue:kIXTo basePath:nil defaultValue:nil];
        if( navigateTo )
        {
            [IXViewController viewControllerWithPathToJSON:navigateTo
                                                 loadAsync:YES
                                           completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                               
                                               if( didSucceed && viewController != nil )
                                               {
                                                   [self finishPushNavigationTo:viewController];
                                               }
                                               else
                                               {
                                                   IX_LOG_ERROR(@"ERROR: from %@ in %@ : Error performing push navigation. Description : %@",THIS_FILE,THIS_METHOD,[error description]);
                                                   [self navigationActionDidFinish:NO];
                                               }
                                           }];
        }
        else
        {
            [self navigationActionDidFinish:NO];
        }
    }
}

-(void)finishPushNavigationTo:(IXViewController*)viewController
{
    if( viewController != nil )
    {
        UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
        if ( [self navAnimationTransitionType] == UIViewAnimationOptionTransitionNone )
        {
            if( [self usesCustomPushAndPopNavigationTransition] )
            {
                [navController setDelegate:self];
            }

            if( [self isReplaceStackType] )
            {
                [navController setViewControllers:@[viewController] animated:YES];
            }
            else
            {
                [navController pushViewController:viewController animated:YES];
            }
            
            [self navigationActionDidFinish:YES];
        }
        else
        {
            if( [self navAnimationDelay] > 0.0f )
            {
                [self performSelector:@selector(animatePushToViewController:)
                           withObject:viewController
                           afterDelay:[self navAnimationDelay]];
            }
            else
            {
                [self animatePushToViewController:viewController];
            }
        }
    }
    else
    {
        [self navigationActionDidFinish:NO];
    }
}

-(void)animatePushToViewController:(UIViewController*)viewController
{
    if( viewController != nil )
    {
        [self performAnimationToView:[viewController view]];
        
        UINavigationController* navController = [[IXAppManager sharedAppManager] rootViewController];
        if( [self isReplaceStackType] )
        {
            [navController setViewControllers:@[viewController] animated:NO];
        }
        else
        {
            [navController pushViewController:viewController animated:NO];
        }
    }
    else
    {
        [self navigationActionDidFinish:NO];
    }
}

-(void)performExternalNavigation
{
    BOOL didSucceed = NO;
    NSString* navigateTo = [[self actionProperties] getStringPropertyValue:kIXTo defaultValue:nil];
    if( [navigateTo length] > 0 )
    {
        NSURL* externalURL = [NSURL URLWithString:navigateTo];
        if( externalURL && [[UIApplication sharedApplication] canOpenURL:externalURL] )
        {
            didSucceed = [[UIApplication sharedApplication] openURL:externalURL];
        }
    }
    [self navigationActionDidFinish:didSucceed];
}

-(void)performAnimationToView:(UIView*)toView
{
    [UIView transitionFromView:[[[IXAppManager sharedAppManager] currentIXViewController] view]
                        toView:toView
                      duration:[self navAnimationDuration]
                       options:[self navAnimationTransitionType]
                    completion:^(BOOL finished) {
                        [self navigationActionDidFinish:YES];
                    }];
}

@end
