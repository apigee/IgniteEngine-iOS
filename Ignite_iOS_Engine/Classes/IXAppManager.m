//
//  IXAppManager.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppManager.h"

#import "Reachability.h"
#import "RKLog.h"
#import "SDWebImageManager.h"

#import "IXConstants.h"
#import "IXJSONGrabber.h"
#import "IXLogger.h"
#import "IXPathHandler.h"
#import "IXNavigationViewController.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXPropertyContainer.h"
#import "IXViewController.h"
#import "IXDeviceInfo.h"
#import "IXBaseAction.h"
#import "IXLayout.h"
#import "IXBaseDataProvider.h"
#import "IXBaseDataProviderConfig.h"

#import "ApigeeClient.h"
#import "ApigeeDataClient.h"

@interface IXAppManager ()

@property (nonatomic,strong) UIWebView* webViewForJS;

@end

@implementation IXAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        _appConfigPath = [[NSBundle mainBundle] pathForResource:@"assets/_index" ofType:@"json"];
        
        _appProperties = [[IXPropertyContainer alloc] init];
        _deviceProperties = [[IXPropertyContainer alloc] init];

        _rootViewController = [[IXNavigationViewController alloc] initWithNibName:nil bundle:nil];
        _reachabilty = [Reachability reachabilityForInternetConnection];
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

-(void)appDidRegisterRemoteNotificationDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [self setPushToken:hexToken];
    
    ApigeeDataClient* apigeeDataClient = [[self apigeeClient] dataClient];
    if( apigeeDataClient != nil )
    {
        IXPropertyContainer* appProperties = [self appProperties];
        NSString* apigeePushNotifier = [appProperties getStringPropertyValue:@"apigee_push_notifier"
                                                                defaultValue:nil];
        
        ApigeeClientResponse *response = [apigeeDataClient setDevicePushToken:deviceToken
                                                                  forNotifier:apigeePushNotifier];
        
        if( ![response completedSuccessfully])
        {
            IX_LOG_ERROR(@"Error Setting Push Token with ApigeeClient : %@", [response rawResponse]);
        }
    }
}

-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo
{
    // Example Push Notificaiton String = NSString* pushNotification = @"{\"apple\":{\"aps\":{\"alert\":\"[apns-test] Some Text!\",\"sound\":\"chime\",\"badge\":0},\"action\":[\"navigate\",{\"attributes\":{\"to\":\"device://assets/examples/IXButtonControlExample.json\"}}]}}";

    IXBaseAction* action = [IXBaseAction actionWithRemoteNotificationInfo:userInfo[@"apple"]];
    if( action )
    {
        IXViewController* currentVC = [self currentIXViewController];
        [action setActionContainer:[[currentVC containerControl] actionContainer]];
        [action execute];
    }
}

-(void)startApplication
{
    [self setSessionProperties:[[IXPropertyContainer alloc] init]];

    [self setWebViewForJS:[[UIWebView alloc] initWithFrame:CGRectZero]];
    [self setApplicationSandbox:[[IXSandbox alloc] initWithBasePath:nil rootPath:[[self appConfigPath] stringByDeletingLastPathComponent]]];
    
    [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:[self appConfigPath]
                                                 asynch:NO
                                            shouldCache:NO
                                        completionBlock:^(id jsonObject, NSError *error) {
                                            
                                            if( jsonObject == nil )
                                            {
                                                [self showJSONAlertWithName:[self appConfigPath] error:error];
                                            }
                                            else
                                            {
                                                NSArray* appDataProvidersJSONArray = [jsonObject valueForKeyPath:@"app.data_providers"];
                                                NSArray* appDataProviderConfigs = [IXBaseDataProviderConfig dataProviderConfigsWithJSONArray:appDataProvidersJSONArray];
                                                [[self applicationSandbox] addDataProviders:[IXBaseDataProviderConfig createDataProvidersFromConfigs:appDataProviderConfigs]];
                                                
                                                NSDictionary* appConfigPropertiesJSONDict = [jsonObject valueForKeyPath:@"app.attributes"];
                                                [[self appProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:appConfigPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
                                                
                                                NSDictionary* sessionDefaultsPropertiesJSONDict = [jsonObject valueForKeyPath:@"session_defaults"];
                                                [[self sessionProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:sessionDefaultsPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
                                                [self loadStoredSessionProperties];

                                                NSDictionary* deviceInfoPropertiesDict = @{
                                                                                           @"model": [IXDeviceInfo deviceModel],
                                                                                           @"type": [IXDeviceInfo deviceType],
                                                                                           kIX_ORIENTATION: [IXDeviceInfo interfaceOrientation],
                                                                                           @"screen.width": [IXDeviceInfo screenWidth],
                                                                                           @"screen.height": [IXDeviceInfo screenHeight],
                                                                                           @"screen.scale": [IXDeviceInfo screenScale],
                                                                                           @"os.version": [IXDeviceInfo osVersion],
                                                                                           @"os.version.integer": [IXDeviceInfo osVersionAsInteger],
                                                                                           @"os.version.major": [IXDeviceInfo osMajorVersion]
                                                                                           };
                                                
                                                [[self deviceProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:deviceInfoPropertiesDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];

                                                [self applyAppProperties];
                                                [self loadApplicationDefaultView];
                                                [[self applicationSandbox] loadAllDataProviders];
                                            }
                                        }];
    [self preloadImages];
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
    NSString* apigeeOrgName = [[self appProperties] getStringPropertyValue:@"apigee_org_id" defaultValue:nil];
    NSString* apigeeApplicationID = [[self appProperties] getStringPropertyValue:@"apigee_app_id" defaultValue:nil];
    NSString* apigeeBaseURL = [[self appProperties] getStringPropertyValue:@"apigee_base_url" defaultValue:nil];
    
    BOOL apigeeOrgNameAndAppIDAreValid = ( [apigeeOrgName length] > 0 && [apigeeApplicationID length] > 0 );
    [[IXLogger sharedLogger] setApigeeClientAvailable:apigeeOrgNameAndAppIDAreValid];
    if( apigeeOrgNameAndAppIDAreValid )
    {
        [self setApigeeClient:[[ApigeeClient alloc] initWithOrganizationId:apigeeOrgName applicationId:apigeeApplicationID baseURL:apigeeBaseURL]];
        [[[self apigeeClient] dataClient] setLogging:YES];
    }
    
    BOOL requestLoggingEnabled = [[self appProperties] getBoolPropertyValue:@"enable_request_logging" defaultValue:NO];
    [[IXLogger sharedLogger] setRequestLoggingEnabled:requestLoggingEnabled];

    BOOL remoteLoggingEnabled = [[self appProperties] getBoolPropertyValue:@"enable_remote_logging" defaultValue:NO];
    [[IXLogger sharedLogger] setRemoteLoggingEnabled:remoteLoggingEnabled];

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
}

-(void)loadApplicationDefaultView
{
    [IXViewController viewControllerWithPathToJSON:[self appDefaultViewPath]
                                         loadAsync:NO
                                   completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                   
                                       if( didSucceed && viewController && error == nil )
                                       {
                                           [[self rootViewController] setViewControllers:[NSArray arrayWithObject:viewController]];
                                       }
                                       else
                                       {
                                           [self showJSONAlertWithName:@"DEFAULT VIEW" error:error];
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

-(void)storeSessionProperties
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self sessionProperties]];
    if( data != nil )
    {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kIX_STORED_SESSION_ATTRIBUTES_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];        
    }
}

-(void)loadStoredSessionProperties
{
    NSData* sessionPropertiesData = [[NSUserDefaults standardUserDefaults] dataForKey:kIX_STORED_SESSION_ATTRIBUTES_KEY];
    if( sessionPropertiesData )
    {
        IXPropertyContainer* storedSessionPropertyContainer = [NSKeyedUnarchiver unarchiveObjectWithData:sessionPropertiesData];
        if( [storedSessionPropertyContainer isKindOfClass:[IXPropertyContainer class]] )
        {
            [[self sessionProperties] addPropertiesFromPropertyContainer:storedSessionPropertyContainer
                                                    evaluateBeforeAdding:NO
                                   replaceOtherPropertiesWithTheSameName:YES];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIX_STORED_SESSION_ATTRIBUTES_KEY];
        }
    }
}

@end
