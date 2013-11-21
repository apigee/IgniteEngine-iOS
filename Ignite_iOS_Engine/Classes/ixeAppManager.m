//
//  ixeAppManager.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/8.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeAppManager.h"

#import "ixeConstants.h"
#import "ixeBaseControl.h"
#import "ixeBaseDataprovider.h"
#import "ixeBaseObject.h"
#import "ixeBaseConditionalObject.h"
#import "ixeBaseAction.h"
#import "ixeSandbox.h"
#import "ixeJSONParser.h"
#import "ixePropertyContainer.h"
#import "ixeActionContainer.h"
#import "ixeProperty.h"
#import "ixeAlertAction.h"
#import "ColorUtils.h"
#import "ixeViewController.h"
#import "ixeNavigationViewController.h"


@interface ixeAppManager ()

@property (nonatomic,strong) UIWebView* webViewForJS;

@end

@implementation ixeAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        _webViewForJS = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        _applicationSandbox = [[ixeSandbox alloc] init];
        
        _appProperties = [[ixePropertyContainer alloc] init];
        [_appProperties setSandbox:_applicationSandbox];
        
        _sessionProperties = [[ixePropertyContainer alloc] init];
        [_sessionProperties setSandbox:_applicationSandbox];
        
        _rootViewController = [[ixeNavigationViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

+(ixeAppManager*)sharedInstance
{
    static ixeAppManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ixeAppManager alloc] init];
    });
    return sharedInstance;
}

-(ixeViewController*)currentixeViewController
{
    return (ixeViewController*) [[self rootViewController] topViewController];
}

-(void)runAlertTest
{
    [self testAlertAction];
}

-(void)startApplication
{
    [self setAppConfigPath:[[NSBundle mainBundle] pathForResource:@"assets/ixeAppConfig" ofType:@"json"]];
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
                    [self setAppProperties:[ixeJSONParser propertyContainerWithPropertyDictionary:appConfigPropertiesJSONDict]];
                    NSLog(@"\n%@",[[self appProperties] description]);
                }
            }
            id sessionDefaultsJSONValue = [jsonValue objectForKey:@"session_defaults"];
            if( [sessionDefaultsJSONValue isKindOfClass:[NSDictionary class]] )
            {
                NSDictionary* sessionDefaultsPropertiesJSONDict = (NSDictionary*)sessionDefaultsJSONValue;
                [self setSessionProperties:[ixeJSONParser propertyContainerWithPropertyDictionary:sessionDefaultsPropertiesJSONDict]];
            }
        }
    }
    
    [self setAppMode:[[self appProperties] getStringPropertyValue:@"mode" defaultValue:@"release"]];
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:@"enable_layout_debugging" defaultValue:YES]];
    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:@"shows_navigation_bar" defaultValue:YES] animated:YES];

    ixeViewController* viewController = nil;
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
                viewController = [ixeJSONParser viewControllerWithViewDictionary:viewDictJSONValue];
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
    ixeBaseControl* baseControl = [[ixeBaseControl alloc] init];
    
    ixeAlertAction* alertAction = [[ixeAlertAction alloc] init];
    alertAction.eventName = kixe_TOUCH;
    
    ixeProperty* titleProperty = [[ixeProperty alloc] initWithPropertyName:kixe_TITLE rawValue:@"SOME TITLE"];
    ixeProperty* titleProperty2 = [[ixeProperty alloc] initWithPropertyName:kixe_TITLE rawValue:@"SOME TITLE 2"];
    ixeProperty* titleProperty3 = [[ixeProperty alloc] initWithPropertyName:kixe_TITLE rawValue:@"SOME TITLE POOOOPPPPP"];
    
    ixeProperty* subTitleProperty = [[ixeProperty alloc] initWithPropertyName:kixe_SUB_TITLE rawValue:@"SOME SUB TITLE"];
    ixeProperty* subTitleProperty2 = [[ixeProperty alloc] initWithPropertyName:kixe_SUB_TITLE rawValue:@"SOME SUB TITLE2"];

    [[alertAction actionProperties] addProperty:titleProperty];
    [[alertAction actionProperties] addProperty:subTitleProperty];
    
    ixeAlertAction* alertAction2 = [[ixeAlertAction alloc] init];
    alertAction2.eventName = kixe_TOUCH;
    
    [[alertAction2 actionProperties] addProperty:titleProperty2];
    [[alertAction2 actionProperties] addProperty:titleProperty3];
    [[alertAction2 actionProperties] addProperty:subTitleProperty2];
    
    [[baseControl actionContainer] addAction:alertAction];
    [[baseControl actionContainer] addAction:alertAction2];
    
    [[baseControl actionContainer] executeActionsForEventNamed:kixe_TOUCH];
}

@end
