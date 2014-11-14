//
//  IXAppManager.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppManager.h"

#import "IXBaseAction.h"
#import "IXBaseDataProvider.h"
#import "IXBaseDataProviderConfig.h"
#import "IXConstants.h"
#import "IXControlCacheContainer.h"
#import "IXDataGrabber.h"
#import "IXDeviceInfo.h"
#import "IXLayout.h"
#import "IXLogger.h"
#import "IXNavigationViewController.h"
#import "IXPathHandler.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"

#import "ApigeeClient.h"
#import "ApigeeDataClient.h"
#import "ApigeeMonitoringOptions.h"
#import "IXMMDrawerController.h"
#import "Reachability.h"
#import "RKLog.h"
#import "SDWebImageManager.h"

// Top Level Containers
IX_STATIC_CONST_STRING kIXAppActions = @"app.actions";
IX_STATIC_CONST_STRING kIXAppAttributes = @"app.attributes";
IX_STATIC_CONST_STRING kIXAppDataProviders = @"app.data_providers";
IX_STATIC_CONST_STRING kIXSessionDefaults = @"session.defaults";

// App Attributes
IX_STATIC_CONST_STRING kIXAppMode = @"mode";
IX_STATIC_CONST_STRING kIXLogLevel = @"log_level";
IX_STATIC_CONST_STRING kIXDefaultView = @"default_view";
IX_STATIC_CONST_STRING kIXDrawerViewLeft = @"drawer.view.left";
IX_STATIC_CONST_STRING kIXDrawerViewLeftMaxWidth = @"drawer.view.left.max.width";
IX_STATIC_CONST_STRING kIXDrawerViewRight = @"drawer.view.right";
IX_STATIC_CONST_STRING kIXDrawerViewRightMaxWidth = @"drawer.view.right.max.width";
IX_STATIC_CONST_STRING kIXDrawerToggleVelocity = @"drawer.toggle.velocity";
IX_STATIC_CONST_STRING kIXEnableLayoutDebugging = @"enable_layout_debugging";
IX_STATIC_CONST_STRING kIXEnableRequestLogging = @"enable_request_logging";
IX_STATIC_CONST_STRING kIXEnableRemoteLogging = @"enable_remote_logging";
IX_STATIC_CONST_STRING kIXShowsNavigationBar = @"shows_navigation_bar";
IX_STATIC_CONST_STRING kIXPreloadImages = @"preload_images";
IX_STATIC_CONST_STRING kIXApigeeOrgID = @"apigee_org_id";
IX_STATIC_CONST_STRING kIXApigeeAppID = @"apigee_app_id";
IX_STATIC_CONST_STRING kIXApigeeBaseURL = @"apigee_base_url";
IX_STATIC_CONST_STRING kIXApigeePushNotifier = @"apigee_push_notifier";

// App Functions
IX_STATIC_CONST_STRING kIXReset = @"reset";
IX_STATIC_CONST_STRING kIXDestorySession = @"session.destroy";

IX_STATIC_CONST_STRING kIXToggleDrawerLeft = @"drawer.toggle.left";
IX_STATIC_CONST_STRING kIXToggleDrawerRight = @"drawer.toggle.right";

IX_STATIC_CONST_STRING kIXEnableDrawerPrefix = @"drawer.enable"; // Function name must have one of the following suffixes.
IX_STATIC_CONST_STRING kIXDisableDrawerPrefix = @"drawer.disable"; // Function name must have one of the following suffixes.

IX_STATIC_CONST_STRING kIXEnableDisableDrawerOpenSuffix = @".open";
IX_STATIC_CONST_STRING kIXEnableDisableDrawerCloseSuffix = @".close";
IX_STATIC_CONST_STRING kIXEnableDisableDrawerOpenAndCloseSuffix = @".open_close";

// Device Readonly Attributes
IX_STATIC_CONST_STRING kIXDeviceModel = @"model";
IX_STATIC_CONST_STRING kIXDeviceType = @"type";
IX_STATIC_CONST_STRING kIXDeviceScreenWidth = @"screen.width";
IX_STATIC_CONST_STRING kIXDeviceScreenHeight = @"screen.height";
IX_STATIC_CONST_STRING kIXDeviceScreenScale = @"screen.scale";
IX_STATIC_CONST_STRING kIXDeviceOSVersion = @"os.version";
IX_STATIC_CONST_STRING kIXDeviceOSVersionInteger = @"os.version.integer";
IX_STATIC_CONST_STRING kIXDeviceOSVersionMajor = @"os.version.major";

// Non attribute constants
IX_STATIC_CONST_STRING kIXAssetsBasePath = @"assets/";
IX_STATIC_CONST_STRING kIXDefaultIndexPath = @"assets/_index.json";
IX_STATIC_CONST_STRING kIXTokenStringFormat = @"%08x%08x%08x%08x%08x%08x%08x%08x";

@interface IXAppManager ()

@property (nonatomic,assign) IXAppMode appMode;
@property (nonatomic,assign) BOOL layoutDebuggingEnabled;
@property (nonatomic,strong) IXSandbox *applicationSandbox;

@property (nonatomic,strong) MMDrawerController *drawerController;
@property (nonatomic,strong) IXNavigationViewController *rootViewController;

@property (nonatomic,copy) NSString *pushToken;
@property (nonatomic,copy) NSString *appIndexFilePath;
@property (nonatomic,copy) NSString *appDefaultViewPath;
@property (nonatomic,copy) NSString *appLeftDrawerViewPath;
@property (nonatomic,copy) NSString *appRightDrawerViewPath;

@property (nonatomic,strong) IXPropertyContainer *deviceProperties;
@property (nonatomic,strong) IXPropertyContainer *appProperties;
@property (nonatomic,strong) IXPropertyContainer *sessionProperties;
@property (nonatomic,strong) IXActionContainer* actionContainer;

@property (nonatomic,strong) Reachability *reachabilty;
@property (nonatomic,strong) ApigeeClient *apigeeClient;

@property (nonatomic,strong) UIWebView *webViewForJS;

@end

@implementation IXAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        _appIndexFilePath = [IXPathHandler localPathWithRelativeFilePath:kIXDefaultIndexPath];
        
        _appProperties = [[IXPropertyContainer alloc] init];
        _deviceProperties = [[IXPropertyContainer alloc] init];
        
        _rootViewController = [[IXNavigationViewController alloc] initWithNibName:nil bundle:nil];
        _drawerController = [[IXMMDrawerController alloc] initWithCenterViewController:_rootViewController
                                                            leftDrawerViewController:nil
                                                           rightDrawerViewController:nil];
        
        [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];

        _reachabilty = [Reachability reachabilityForInternetConnection];
    }
    return self;
}

+(instancetype)sharedAppManager
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
    NSString *hexToken = [NSString stringWithFormat:kIXTokenStringFormat,
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    [self setPushToken:hexToken];
    
    ApigeeDataClient* apigeeDataClient = [[self apigeeClient] dataClient];
    if( apigeeDataClient != nil )
    {
        IXPropertyContainer* appProperties = [self appProperties];
        NSString* apigeePushNotifier = [appProperties getStringPropertyValue:kIXApigeePushNotifier
                                                                defaultValue:nil];
        
        ApigeeClientResponse *response = [apigeeDataClient setDevicePushToken:deviceToken
                                                                  forNotifier:apigeePushNotifier];
        
        if( ![response completedSuccessfully])
        {
            IX_LOG_ERROR(@"Error Setting Push Token with ApigeeClient : %@", [response rawResponse]);
        }
    }

    [_actionContainer executeActionsForEventNamed:kIXAppRegisterForRemoteNotificationsSuccess];
}

-(void)appFailedToRegisterForRemoteNotifications
{
    [_actionContainer executeActionsForEventNamed:kIXAppRegisterForRemoteNotificationsFailed];
}

-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo
{
    IX_LOG_DEBUG(@"Push Notification Info : %@",[userInfo description]);

    IXBaseAction* action = [IXBaseAction actionWithRemoteNotificationInfo:userInfo];
    if( action )
    {
        IXViewController* currentVC = [self currentIXViewController];
        if( [[currentVC containerControl] actionContainer] == nil )
        {
            [[currentVC containerControl] setActionContainer:[[IXActionContainer alloc] init]];
        }
        [action setActionContainer:[[currentVC containerControl] actionContainer]];
        [action execute];
        [action setActionContainer:nil];
    }
}

-(void)startApplication
{
    [[self drawerController] setLeftDrawerViewController:nil];
    [[self drawerController] setRightDrawerViewController:nil];
    [self setAppLeftDrawerViewPath:nil];
    [self setAppRightDrawerViewPath:nil];

    [self setSessionProperties:[[IXPropertyContainer alloc] init]];

    [self setWebViewForJS:[[UIWebView alloc] initWithFrame:CGRectZero]];
    [self setApplicationSandbox:[[IXSandbox alloc] initWithBasePath:nil rootPath:[[self appIndexFilePath] stringByDeletingLastPathComponent]]];
    
    [[IXDataGrabber sharedDataGrabber] grabJSONFromPath:[self appIndexFilePath]
                                                 asynch:NO
                                            shouldCache:NO
                                        completionBlock:^(id jsonObject, NSString* stringValue, NSError *error) {
                                            
                                            if( jsonObject == nil )
                                            {
                                                [self showJSONAlertWithName:[self appIndexFilePath] error:error];
                                            }
                                            else
                                            {
                                                NSArray* appDataProvidersJSONArray = [jsonObject valueForKeyPath:kIXAppDataProviders];
                                                NSArray* appDataProviderConfigs = [IXBaseDataProviderConfig dataProviderConfigsWithJSONArray:appDataProvidersJSONArray];
                                                [[self applicationSandbox] addDataProviders:[IXBaseDataProviderConfig createDataProvidersFromConfigs:appDataProviderConfigs]];
                                                
                                                NSArray* appActionsJSONArray = [jsonObject valueForKeyPath:kIXAppActions];
                                                _actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:appActionsJSONArray];

                                                
                                                NSDictionary* appConfigPropertiesJSONDict = [jsonObject valueForKeyPath:kIXAppAttributes];
                                                [[self appProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:appConfigPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
                                                
                                                NSDictionary* sessionDefaultsPropertiesJSONDict = [jsonObject valueForKeyPath:kIXSessionDefaults];
                                                [[self sessionProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:sessionDefaultsPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
                                                [self loadStoredSessionProperties];

                                                NSDictionary* deviceInfoPropertiesDict = @{
                                                                                           kIXDeviceModel: [IXDeviceInfo deviceModel],
                                                                                           kIXDeviceType: [IXDeviceInfo deviceType],
                                                                                           kIX_ORIENTATION: [IXDeviceInfo interfaceOrientation],
                                                                                           kIXDeviceScreenWidth: [IXDeviceInfo screenWidth],
                                                                                           kIXDeviceScreenHeight: [IXDeviceInfo screenHeight],
                                                                                           kIXDeviceScreenScale: [IXDeviceInfo screenScale],
                                                                                           kIXDeviceOSVersion: [IXDeviceInfo osVersion],
                                                                                           kIXDeviceOSVersionInteger: [IXDeviceInfo osVersionAsInteger],
                                                                                           kIXDeviceOSVersionMajor: [IXDeviceInfo osMajorVersion]
                                                                                           };
                                                
                                                [[self deviceProperties] addPropertiesFromPropertyContainer:[IXPropertyContainer propertyContainerWithJSONDict:deviceInfoPropertiesDict] evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];

                                                [self applyAppProperties];
                                                [self preloadImages];
                                                [self loadApplicationDefaultView];
                                                [[self applicationSandbox] loadAllDataProviders];
                                            }
                                        }];
}

-(void)preloadImages
{
    NSArray* imagesToPreload = [[self appProperties] getCommaSeperatedArrayListValue:kIXPreloadImages defaultValue:nil];
    for( NSString* imagePath in imagesToPreload )
    {
        UIImage* image = [UIImage imageNamed:imagePath];
        if( image )
        {
            NSURL* imageURL = [[NSBundle mainBundle] URLForResource:imagePath withExtension:nil];
            [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:[imageURL absoluteString]];
        }
    }
}

-(void)applyAppProperties
{
    if( [[[self appProperties] getStringPropertyValue:kIXAppMode defaultValue:kIX_RELEASE] isEqualToString:kIX_DEBUG] ) {
        [self setAppMode:IXDebugMode];
        RKLogConfigureByName("*", RKLogLevelOff);
    } else {
        [self setAppMode:IXReleaseMode];
        RKLogConfigureByName("*", RKLogLevelOff);
    }
    
    [[IXLogger sharedLogger] setRequestLoggingEnabled:[[self appProperties] getBoolPropertyValue:kIXEnableRequestLogging defaultValue:NO]];
    [[IXLogger sharedLogger] setRemoteLoggingEnabled:[[self appProperties] getBoolPropertyValue:kIXEnableRemoteLogging defaultValue:NO]];
    [[IXLogger sharedLogger] setAppLogLevel:[[self appProperties] getStringPropertyValue:kIXLogLevel defaultValue:kIX_DEBUG]];
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolPropertyValue:kIXEnableLayoutDebugging defaultValue:NO]];

    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolPropertyValue:kIXShowsNavigationBar defaultValue:YES] animated:YES];
    if( [[self rootViewController] isNavigationBarHidden] )
    {
        [[[self rootViewController] interactivePopGestureRecognizer] setDelegate:nil];
    }
    
    NSString* apigeeOrgName = [[self appProperties] getStringPropertyValue:kIXApigeeOrgID defaultValue:nil];
    NSString* apigeeApplicationID = [[self appProperties] getStringPropertyValue:kIXApigeeAppID defaultValue:nil];
    NSString* apigeeBaseURL = [[self appProperties] getStringPropertyValue:kIXApigeeBaseURL defaultValue:nil];
    
    BOOL apigeeOrgNameAndAppIDAreValid = ( [apigeeOrgName length] > 0 && [apigeeApplicationID length] > 0 );
    [[IXLogger sharedLogger] setApigeeClientAvailable:apigeeOrgNameAndAppIDAreValid];
    if( apigeeOrgNameAndAppIDAreValid )
    {
        ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
        options.crashReportingEnabled = YES;
        options.interceptNetworkCalls = YES;
        
        [self setApigeeClient:[[ApigeeClient alloc] initWithOrganizationId:apigeeOrgName
                                                             applicationId:apigeeApplicationID
                                                                   baseURL:apigeeBaseURL
                                                                   options:options]];
        [[[self apigeeClient] dataClient] setLogging:YES];
    }
    
    [self setAppDefaultViewPath:[[self appProperties] getStringPropertyValue:kIXDefaultView defaultValue:nil]];
    [self setAppLeftDrawerViewPath:[[self appProperties] getStringPropertyValue:kIXDrawerViewLeft defaultValue:nil]];
    [self setAppRightDrawerViewPath:[[self appProperties] getStringPropertyValue:kIXDrawerViewRight defaultValue:nil]];
    [[self drawerController] setAnimationVelocity:[[self appProperties] getFloatPropertyValue:kIXDrawerToggleVelocity defaultValue:840.0f]];
    
    if( [[self appDefaultViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appDefaultViewPath]] )
    {
        [self setAppDefaultViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",kIXAssetsBasePath,[self appDefaultViewPath]]]];
    }
    if( [[self appLeftDrawerViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appLeftDrawerViewPath]] )
    {
        [self setAppLeftDrawerViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",kIXAssetsBasePath,[self appLeftDrawerViewPath]]]];
    }
    if( [[self appRightDrawerViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appRightDrawerViewPath]] )
    {
        [self setAppRightDrawerViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",kIXAssetsBasePath,[self appRightDrawerViewPath]]]];
    }
}

-(void)loadApplicationDefaultView
{
    [IXViewController createViewControllerWithPathToJSON:[self appDefaultViewPath]
                                               loadAsync:NO
                                         completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                             
                                             if( didSucceed && viewController && error == nil )
                                             {
                                                 IXSandbox* appSandbox = [[IXAppManager sharedAppManager] applicationSandbox];
                                                 [appSandbox setViewController:viewController];
                                                 [appSandbox setContainerControl:[viewController containerControl]];

                                                 [[self rootViewController] setViewControllers:[NSArray arrayWithObject:viewController]];
                                             }
                                             else
                                             {
                                                 [self showJSONAlertWithName:kIXDefaultView error:error];
                                             }
                                         }];
    
    if( [[self appLeftDrawerViewPath] length] > 0 ) {
        [IXViewController createViewControllerWithPathToJSON:[self appLeftDrawerViewPath]
                                                   loadAsync:NO
                                             completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                           
                                                 if( didSucceed && viewController && error == nil )
                                                 {
                                                     [[self drawerController] setMaximumLeftDrawerWidth:[[self appProperties] getFloatPropertyValue:kIXDrawerViewLeftMaxWidth defaultValue:280.0f]];
                                                     [[self drawerController] setLeftDrawerViewController:viewController];
                                                     [[[self rootViewController] interactivePopGestureRecognizer] setEnabled:NO];
                                                     [[[self rootViewController] leftScreenPanGestureRecognizer] setEnabled:NO];
                                                 }
                                                 else
                                                 {
                                                     [self showJSONAlertWithName:kIXDrawerViewLeft error:error];
                                                 }
                                             }];
    }
    
    if( [[self appRightDrawerViewPath] length] > 0 ) {
        [IXViewController createViewControllerWithPathToJSON:[self appRightDrawerViewPath]
                                                   loadAsync:NO
                                             completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                           
                                                 if( didSucceed && viewController && error == nil )
                                                 {
                                                     [[self drawerController] setMaximumRightDrawerWidth:[[self appProperties] getFloatPropertyValue:kIXDrawerViewRightMaxWidth defaultValue:280.0f]];
                                                     [[self drawerController] setRightDrawerViewController:viewController];
                                                     [[[self rootViewController] interactivePopGestureRecognizer] setEnabled:NO];
                                                     [[[self rootViewController] rightScreenPanGestureRecognizer] setEnabled:NO];
                                                 }
                                                 else
                                                 {
                                                     [self showJSONAlertWithName:kIXDrawerViewRight error:error];
                                                 }
                                             }];
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

-(void)showJSONAlertWithName:(NSString*)name error:(NSError*)error
{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"JSON Parse Error"]
                                message:[NSString stringWithFormat:@"Your %@ JSON configuration file could not be parsed. Error: %@",name,[error description]]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

-(void)applyFunction:(NSString*)functionName parameters:(IXPropertyContainer*)parameters
{
    if ([functionName isEqualToString:kIXReset])
    {
        // Clear caches.
        [[[SDWebImageManager sharedManager] imageCache] clearMemory];
        [[[SDWebImageManager sharedManager] imageCache] clearDisk];
        [IXDataGrabber clearCache];
        [IXControlCacheContainer clearCache];
        
        [[IXAppManager sharedAppManager] startApplication];
    }
    else if ([functionName isEqualToString:kIXDestorySession])
    {
        [[self sessionProperties] removeAllProperties];
        [self storeSessionProperties];
    }
    else if([functionName isEqualToString:kIXToggleDrawerLeft] )
    {
        if( [[self drawerController] leftDrawerViewController] )
        {
            [[self drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        }
    }
    else if([functionName isEqualToString:kIXToggleDrawerRight] )
    {
        if( [[self drawerController] rightDrawerViewController] )
        {
            [[self drawerController] toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
        }
    }
    else if( [functionName hasPrefix:kIXEnableDrawerPrefix] )
    {
        if( [functionName hasSuffix:kIXEnableDisableDrawerOpenSuffix] ) {
            [[self drawerController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
        } else if( [functionName hasSuffix:kIXEnableDisableDrawerCloseSuffix] ) {
            [[self drawerController] setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
        } else if( [functionName hasSuffix:kIXEnableDisableDrawerOpenAndCloseSuffix] ) {
            [[self drawerController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
            [[self drawerController] setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
        }
    }
    else if( [functionName hasPrefix:kIXDisableDrawerPrefix] )
    {
        if( [functionName hasSuffix:kIXEnableDisableDrawerOpenSuffix] ) {
            [[self drawerController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        } else if( [functionName hasSuffix:kIXEnableDisableDrawerCloseSuffix] ) {
            [[self drawerController] setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
        } else if( [functionName hasSuffix:kIXEnableDisableDrawerOpenAndCloseSuffix] ) {
            [[self drawerController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            [[self drawerController] setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
        }
    }
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

-(void)fireAppEventNamed:(NSString*)appEventName
{
    if( [appEventName length] > 0 )
    {
        [[self actionContainer] setOwnerObject:[[self currentIXViewController] containerControl]];
        [[self actionContainer] executeActionsForEventNamed:appEventName];
        [[self actionContainer] setOwnerObject:nil];
    }
}

-(void)appWillResignActive
{
    IX_LOG_VERBOSE(@"App will resign active.");
    [self fireAppEventNamed:kIXAppWillResignActiveEvent];
}

-(void)appDidEnterBackground
{
    IX_LOG_VERBOSE(@"App did enter background.");
    [self fireAppEventNamed:kIXAppDidEnterBackgroundEvent];
}

-(void)appWillEnterForeground
{
    IX_LOG_VERBOSE(@"App will enter foreground.");
    [self fireAppEventNamed:kIXAppWillEnterForegroundEvent];
}

-(void)appDidBecomeActive
{
    IX_LOG_VERBOSE(@"App did become active.");
    [self fireAppEventNamed:kIXAppDidBecomeActiveEvent];
}

-(void)appWillTerminate
{
    IX_LOG_VERBOSE(@"App will terminate.");
    [self fireAppEventNamed:kIXAppWillTerminateEvent];
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
