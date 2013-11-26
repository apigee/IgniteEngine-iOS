//
//  IXAppManager.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppManager.h"

#import "IXConstants.h"
#import "IXBaseControl.h"
#import "IXBaseDataprovider.h"
#import "IXBaseObject.h"
#import "IXBaseConditionalObject.h"
#import "IXBaseAction.h"
#import "IXSandbox.h"
#import "IXJSONParser.h"
#import "IXPropertyContainer.h"
#import "IXActionContainer.h"
#import "IXProperty.h"
#import "IXAlertAction.h"
#import "ColorUtils.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"


@interface IXAppManager ()

@property (nonatomic,strong) UIWebView* webViewForJS;

@end

@implementation IXAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        _webViewForJS = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        _applicationSandbox = [[IXSandbox alloc] init];
        
        _appProperties = [[IXPropertyContainer alloc] init];
        [_appProperties setSandbox:_applicationSandbox];
        
        _sessionProperties = [[IXPropertyContainer alloc] init];
        [_sessionProperties setSandbox:_applicationSandbox];
        
        _rootViewController = [[IXNavigationViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

+(IXAppManager*)sharedInstance
{
    static IXAppManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IXAppManager alloc] init];
    });
    return sharedInstance;
}

-(IXViewController*)currentIXViewController
{
    return (IXViewController*) [[self rootViewController] topViewController];
}

-(void)runAlertTest
{
    [self testAlertAction];
}

-(void)startApplication
{
    [self setAppConfigPath:[[NSBundle mainBundle] pathForResource:@"assets/IXAppConfig" ofType:@"json"]];
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
                    [self setAppProperties:[IXJSONParser propertyContainerWithPropertyDictionary:appConfigPropertiesJSONDict]];
                    NSLog(@"\n%@",[[self appProperties] description]);
                }
            }
            id sessionDefaultsJSONValue = [jsonValue objectForKey:@"session_defaults"];
            if( [sessionDefaultsJSONValue isKindOfClass:[NSDictionary class]] )
            {
                NSDictionary* sessionDefaultsPropertiesJSONDict = (NSDictionary*)sessionDefaultsJSONValue;
                [self setSessionProperties:[IXJSONParser propertyContainerWithPropertyDictionary:sessionDefaultsPropertiesJSONDict]];
            }
        }
    }
    
    if( [[[self appProperties] getStringPropertyValue:@"mode" defaultValue:@"release"] isEqualToString:@"debug"] )
    {
        [self setAppMode:IXDebugMode];
    }
    else
    {
        [self setAppMode:IXReleaseMode];
    }
    
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:@"enable_layout_debugging" defaultValue:YES]];
    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:@"shows_navigation_bar" defaultValue:YES] animated:YES];

    IXViewController* viewController = nil;
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
                viewController = [IXJSONParser viewControllerWithViewDictionary:viewDictJSONValue];
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

+(BOOL)pathIsLocal:(NSString*)path
{
    return ![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"];
}

-(NSString*)evaluateJavascript:(NSString*)javascript
{
    if( javascript == nil )
        return nil;
    
    return [[self webViewForJS] stringByEvaluatingJavaScriptFromString:javascript];
}

-(void)testAlertAction
{
    IXBaseControl* baseControl = [[IXBaseControl alloc] init];
    
    IXAlertAction* alertAction = [[IXAlertAction alloc] init];
    alertAction.eventName = kIX_TOUCH;
    
    IXProperty* titleProperty = [[IXProperty alloc] initWithPropertyName:kIX_TITLE rawValue:@"SOME TITLE"];
    IXProperty* titleProperty2 = [[IXProperty alloc] initWithPropertyName:kIX_TITLE rawValue:@"SOME TITLE 2"];
    IXProperty* titleProperty3 = [[IXProperty alloc] initWithPropertyName:kIX_TITLE rawValue:@"SOME TITLE POOOOPPPPP"];
    
    IXProperty* subTitleProperty = [[IXProperty alloc] initWithPropertyName:kIX_SUB_TITLE rawValue:@"SOME SUB TITLE"];
    IXProperty* subTitleProperty2 = [[IXProperty alloc] initWithPropertyName:kIX_SUB_TITLE rawValue:@"SOME SUB TITLE2"];

    [[alertAction actionProperties] addProperty:titleProperty];
    [[alertAction actionProperties] addProperty:subTitleProperty];
    
    IXAlertAction* alertAction2 = [[IXAlertAction alloc] init];
    alertAction2.eventName = kIX_TOUCH;
    
    [[alertAction2 actionProperties] addProperty:titleProperty2];
    [[alertAction2 actionProperties] addProperty:titleProperty3];
    [[alertAction2 actionProperties] addProperty:subTitleProperty2];
    
    [[baseControl actionContainer] addAction:alertAction];
    [[baseControl actionContainer] addAction:alertAction2];
    
    [[baseControl actionContainer] executeActionsForEventNamed:kIX_TOUCH];
}

@end
