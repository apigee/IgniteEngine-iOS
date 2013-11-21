//
//  IxAppManager.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/8.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxAppManager.h"

#import "IxConstants.h"
#import "IxBaseControl.h"
#import "IxBaseDataprovider.h"
#import "IxBaseObject.h"
#import "IxBaseConditionalObject.h"
#import "IxBaseAction.h"
#import "IxSandbox.h"
#import "IxJSONParser.h"
#import "IxPropertyContainer.h"
#import "IxActionContainer.h"
#import "IxProperty.h"
#import "IxAlertAction.h"
#import "ColorUtils.h"
#import "IxViewController.h"
#import "IxNavigationViewController.h"


@interface IxAppManager ()

@property (nonatomic,strong) UIWebView* webViewForJS;

@end

@implementation IxAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        _webViewForJS = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        _applicationSandbox = [[IxSandbox alloc] init];
        
        _appProperties = [[IxPropertyContainer alloc] init];
        [_appProperties setSandbox:_applicationSandbox];
        
        _sessionProperties = [[IxPropertyContainer alloc] init];
        [_sessionProperties setSandbox:_applicationSandbox];
        
        _rootViewController = [[IxNavigationViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

+(IxAppManager*)sharedInstance
{
    static IxAppManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IxAppManager alloc] init];
    });
    return sharedInstance;
}

-(IxViewController*)currentIxViewController
{
    return (IxViewController*) [[self rootViewController] topViewController];
}

-(void)runAlertTest
{
    [self testAlertAction];
}

-(void)startApplication
{
    [self setAppConfigPath:[[NSBundle mainBundle] pathForResource:@"assets/IxAppConfig" ofType:@"json"]];
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self appConfigPath]] )
    {
        NSData* jsonData = [NSData dataWithContentsOfFile:[self appConfigPath]];
        if( jsonData != nil )
        {
            id jsonValue = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            
            id appDictJSONValue = [jsonValue objectForKey:@"app"];
            if( [appDictJSONValue isKindOfClass:[NSDictionary class]] )
            {
                id appPropertiesJSONValue = (NSDictionary*)[appDictJSONValue objectForKey:@"properties"];
                if( [appPropertiesJSONValue isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary* appConfigPropertiesJSONDict = (NSDictionary*)appPropertiesJSONValue;
                    [self setAppProperties:[IxJSONParser propertyContainerWithPropertyDictionary:appConfigPropertiesJSONDict]];
                    NSLog(@"\n%@",[[self appProperties] description]);
                }
            }
            id sessionDefaultsJSONValue = [jsonValue objectForKey:@"session_defaults"];
            if( [sessionDefaultsJSONValue isKindOfClass:[NSDictionary class]] )
            {
                NSDictionary* sessionDefaultsPropertiesJSONDict = (NSDictionary*)sessionDefaultsJSONValue;
                [self setSessionProperties:[IxJSONParser propertyContainerWithPropertyDictionary:sessionDefaultsPropertiesJSONDict]];
            }
        }
    }
    
    [self setAppMode:[[self appProperties] getStringPropertyValue:@"mode" defaultValue:@"release"]];
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:@"enable_layout_debugging" defaultValue:YES]];
    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:@"shows_navigation_bar" defaultValue:YES] animated:YES];

    IxViewController* viewController = nil;
    NSString* defaultViewProperty = [[self appProperties] getStringPropertyValue:@"default_view" defaultValue:nil];
    [self setAppDefaultViewPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"assets/%@",defaultViewProperty] ofType:nil]];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self appDefaultViewPath]] )
    {
        NSData* jsonData = [NSData dataWithContentsOfFile:[self appDefaultViewPath]];
        if( jsonData != nil )
        {
            id jsonValue = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            id viewDictJSONValue = [jsonValue objectForKey:@"view"];
            if( [viewDictJSONValue isKindOfClass:[NSDictionary class]] )
            {
                viewController = [IxJSONParser viewControllerWithViewDictionary:viewDictJSONValue];
            }
        }
    }
    
    if( viewController != nil )
    {
        [[self rootViewController] setViewControllers:[NSArray arrayWithObject:viewController]];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"JSON IS PROBABLY BROKE SUCKER" message:@"fix it..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

+(UIInterfaceOrientation)currentInterfaceOrientation
{
    return [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] interfaceOrientation];
}

-(NSString*)evaluateJavascript:(NSString*)javascript
{
    if( javascript == nil )
        return nil;
    
    return [[self webViewForJS] stringByEvaluatingJavaScriptFromString:javascript];
}

-(void)testAlertAction
{
    IxBaseControl* baseControl = [[IxBaseControl alloc] init];
    
    IxAlertAction* alertAction = [[IxAlertAction alloc] init];
    alertAction.eventName = kIx_TOUCH;
    
    IxProperty* titleProperty = [[IxProperty alloc] initWithPropertyName:kIx_TITLE rawValue:@"SOME TITLE"];
    IxProperty* titleProperty2 = [[IxProperty alloc] initWithPropertyName:kIx_TITLE rawValue:@"SOME TITLE 2"];
    IxProperty* titleProperty3 = [[IxProperty alloc] initWithPropertyName:kIx_TITLE rawValue:@"SOME TITLE POOOOPPPPP"];
    
    IxProperty* subTitleProperty = [[IxProperty alloc] initWithPropertyName:kIx_SUB_TITLE rawValue:@"SOME SUB TITLE"];
    IxProperty* subTitleProperty2 = [[IxProperty alloc] initWithPropertyName:kIx_SUB_TITLE rawValue:@"SOME SUB TITLE2"];

    [[alertAction actionProperties] addProperty:titleProperty];
    [[alertAction actionProperties] addProperty:subTitleProperty];
    
    IxAlertAction* alertAction2 = [[IxAlertAction alloc] init];
    alertAction2.eventName = kIx_TOUCH;
    
    [[alertAction2 actionProperties] addProperty:titleProperty2];
    [[alertAction2 actionProperties] addProperty:titleProperty3];
    [[alertAction2 actionProperties] addProperty:subTitleProperty2];
    
    [[baseControl actionContainer] addAction:alertAction];
    [[baseControl actionContainer] addAction:alertAction2];
    
    [[baseControl actionContainer] executeActionsForEventNamed:kIx_TOUCH];
}

@end
