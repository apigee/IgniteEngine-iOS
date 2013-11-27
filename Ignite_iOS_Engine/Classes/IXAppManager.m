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
#import "IXJSONGrabber.h"

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

+(IXAppManager*)sharedAppManager
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

-(void)startApplication
{
    [self setAppConfigPath:[[NSBundle mainBundle] pathForResource:@"assets/IXAppConfig" ofType:@"json"]];
    
    [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:[self appConfigPath]
                                                 asynch:NO
                                        completionBlock:^(id jsonObject, NSError *error) {
                                            
                                            if( jsonObject == nil )
                                            {
                                                [self showJSONAlertWithName:@"APP CONFIG" error:error];
                                            }
                                            else
                                            {
                                                NSDictionary* appConfigPropertiesJSONDict = [jsonObject valueForKeyPath:@"app.attributes"];
                                                [self setAppProperties:[IXJSONParser propertyContainerWithPropertyDictionary:appConfigPropertiesJSONDict]];
                                                
                                                NSDictionary* sessionDefaultsPropertiesJSONDict = [jsonObject valueForKeyPath:@"session_defaults"];
                                                [self setSessionProperties:[IXJSONParser propertyContainerWithPropertyDictionary:sessionDefaultsPropertiesJSONDict]];
                                                
                                                [self applyAppProperties];
                                                [self loadApplicationDefaultView];
                                            }
                                        }];
}

-(void)applyAppProperties
{
    if( [[[self appProperties] getStringPropertyValue:@"mode" defaultValue:@"release"] isEqualToString:@"debug"] ) {
        [self setAppMode:IXDebugMode];
    } else {
        [self setAppMode:IXReleaseMode];
    }
    
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:@"enable_layout_debugging" defaultValue:YES]];
    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:@"shows_navigation_bar" defaultValue:YES] animated:YES];
    
    NSString* defaultViewProperty = [[self appProperties] getStringPropertyValue:@"default_view" defaultValue:nil];
    [self setAppDefaultViewPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"assets/%@",defaultViewProperty] ofType:nil]];
}

-(void)loadApplicationDefaultView
{
    [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:[self appDefaultViewPath]
                                                 asynch:NO
                                        completionBlock:^(id jsonObject, NSError *error) {
                                            
                                            if( jsonObject == nil )
                                            {
                                                [self showJSONAlertWithName:@"DEFAULT VIEW" error:error];
                                            }
                                            else
                                            {
                                                IXViewController* viewController = nil;
                                                id viewDictJSONValue = [jsonObject objectForKey:@"view"];
                                                if( [viewDictJSONValue isKindOfClass:[NSDictionary class]] )
                                                {
                                                    viewController = [IXJSONParser viewControllerWithViewDictionary:viewDictJSONValue];
                                                }
                                                
                                                if( viewController != nil )
                                                {
                                                    [[self rootViewController] setViewControllers:[NSArray arrayWithObject:viewController]];
                                                }
                                                else
                                                {
                                                    [self showJSONAlertWithName:@"" error:nil];
                                                }
                                            }
                                        }];
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

-(void)showJSONAlertWithName:(NSString*)name error:(NSError*)error
{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ JSON IS PROBABLY BROKE SUCKER ERROR: %@",name,[error description]]
                                message:@"fix it..."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
