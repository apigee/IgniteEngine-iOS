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
#import "IXBaseDataProvider.h"
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
#import "RKLog.h"
#import "SDWebImageManager.h"
#import "IXPathHandler.h"
#import "IXLogger.h"

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
        
        _appConfigPath = [[NSBundle mainBundle] pathForResource:@"assets/IXAppConfig" ofType:@"json"];
        _applicationSandbox = [[IXSandbox alloc] initWithBasePath:nil rootPath:[_appConfigPath stringByDeletingLastPathComponent]];
        
        _appProperties = [[IXPropertyContainer alloc] init];
        _sessionProperties = [[IXPropertyContainer alloc] init];
        
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

-(void)preloadImages
{
    NSArray* imagesToPreload = [[self appProperties] getCommaSeperatedArrayListValue:@"preload_images" defaultValue:nil];
    for( NSString* imagePath in imagesToPreload )
    {
        NSURL* imageURL = [[NSBundle mainBundle] URLForResource:imagePath withExtension:nil];
        if( imageURL )
        {
            [[SDWebImageManager sharedManager] downloadWithURL:imageURL
                                                       options:0
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                                     }];
        }
    }
}

-(void)applyAppProperties
{
    NSString* appLogLevel = [[self appProperties] getStringPropertyValue:@"log_level" defaultValue:@"debug"];
    [[IXLogger sharedLogger] setAppLogLevel:appLogLevel];

    if( [[[self appProperties] getStringPropertyValue:@"mode" defaultValue:@"release"] isEqualToString:@"debug"] ) {
        [self setAppMode:IXDebugMode];
        RKLogConfigureByName("*", RKLogLevelOff);
    } else {
        [self setAppMode:IXReleaseMode];
        RKLogConfigureByName("*", RKLogLevelOff);
    }
    
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:@"enable_layout_debugging" defaultValue:NO]];
    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:@"shows_navigation_bar" defaultValue:YES] animated:YES];
    
    if( [[self rootViewController] isNavigationBarHidden] )
    {
        [[[self rootViewController] interactivePopGestureRecognizer] setDelegate:nil];
    }
    
    NSString* defaultViewProperty = [[self appProperties] getStringPropertyValue:@"default_view" defaultValue:nil];
    if( [IXPathHandler pathIsLocal:defaultViewProperty] )
    {
        [self setAppDefaultViewPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"assets/%@",defaultViewProperty] ofType:nil]];
        [self setAppDefaultViewRootPath:[[NSBundle mainBundle] pathForResource:@"assets" ofType:nil]];
    }
    else
    {
        [self setAppDefaultViewPath:defaultViewProperty];
        
        NSURL* url = [NSURL URLWithString:defaultViewProperty];
        [self setAppDefaultViewRootPath:[[url URLByDeletingLastPathComponent] absoluteString]];
    }
    [self preloadImages];
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
                                                    viewController = [IXJSONParser viewControllerWithViewDictionary:viewDictJSONValue
                                                                                                         pathToJSON:[self appDefaultViewPath]];
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

-(NSString*)evaluateJavascript:(NSString*)javascript
{
    if( javascript == nil )
        return nil;
    
    return [[self webViewForJS] stringByEvaluatingJavaScriptFromString:javascript];
}

-(void)showJSONAlertWithName:(NSString*)name error:(NSError*)error
{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"JSON Parse Error"]
                                message:[NSString stringWithFormat:@"Your root JSON configuration file %@ could not be parsed.",name]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
