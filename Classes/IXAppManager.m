//
//  IXAppManager.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/8/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXAppManager.h"

@import AVFoundation.AVAudioSession;
@import AVFoundation.AVAudioRecorder;

#import "IXAppDelegate.h"
#import "IXBaseAction.h"
#import "IXBaseDataProvider.h"
#import "IXBaseDataProviderConfig.h"
#import "IXConstants.h"
#import "IXControlCacheContainer.h"
#import "IXDataLoader.h"
#import "IXDeviceInfo.h"
#import "IXLayout.h"
#import "IXLogger.h"
#import "IXNavigationViewController.h"
#import "IXPathHandler.h"
#import "IXAttributeContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "NSURL+IXAdditions.h"

#import "ApigeeClient.h"
#import "ApigeeDataClient.h"
#import "ApigeeMonitoringOptions.h"
#import "IXMMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "Reachability.h"
//#import "RKLog.h"
#import "SDWebImageManager.h"
#import "IXLocationManager.h"

// Top Level Containers
IX_STATIC_CONST_STRING kIXAppActions = @"$app.actions";
IX_STATIC_CONST_STRING kIXAppAttributes = @"$app.attributes";
IX_STATIC_CONST_STRING kIXAppDataProviders = @"$app.datasources";
IX_STATIC_CONST_STRING kIXSessionDefaults = @"$session.defaults";

// App Attributes
IX_STATIC_CONST_STRING kIXAppMode = @"mode";
IX_STATIC_CONST_STRING kIXLogLevel = @"logging.level";
IX_STATIC_CONST_STRING kIXDefaultView = @"view.index";
IX_STATIC_CONST_STRING kIXDrawerViewLeft = @"drawer.l.url";
IX_STATIC_CONST_STRING kIXDrawerViewLeftMaxWidth = @"drawer.l.max.w";
IX_STATIC_CONST_STRING kIXDrawerViewRight = @"drawer.r.url";
IX_STATIC_CONST_STRING kIXDrawerViewRightMaxWidth = @"drawer.r.max.w";
IX_STATIC_CONST_STRING kIXDrawerToggleVelocity = @"drawer.velocity";
IX_STATIC_CONST_STRING kIXDrawerAllowedStates = @"drawer.allowedStates"; //open,close,all,none - must match same property in IXViewController
IX_STATIC_CONST_STRING kIXEnableLayoutDebugging = @"debug.layout.enabled";
IX_STATIC_CONST_STRING kIXEnableRequestLogging = @"logging.datasource.enabled";
IX_STATIC_CONST_STRING kIXEnableRemoteLogging = @"logging.remote.enabled";
IX_STATIC_CONST_STRING kIXLocationAccuracy = @"location.accuracy";
IX_STATIC_CONST_STRING kIXShowsNavigationBar = @"navigationBar.enabled";
IX_STATIC_CONST_STRING kIXPreloadImages = @"preloadImages";
IX_STATIC_CONST_STRING kIXPreloadDrawers = @"preloadDrawers.enabled";
IX_STATIC_CONST_STRING kIXApigeeOrgID = @"apigee.org";
IX_STATIC_CONST_STRING kIXApigeeAppID = @"apigee.app";
IX_STATIC_CONST_STRING kIXApigeeBaseURL = @"apigee.baseUrl";
IX_STATIC_CONST_STRING kIXApigeePushNotifier = @"apigee.notifier";

IX_STATIC_CONST_STRING kIXDrawerViewShadow = @"drawer.shadow.enabled";
IX_STATIC_CONST_STRING kIXDrawerViewAnimation = @"drawer.animation";
IX_STATIC_CONST_STRING kIXDrawerViewAnimationSlide = @"slide";
IX_STATIC_CONST_STRING kIXDrawerViewAnimationSlideAndScale = @"slideAndScale";
IX_STATIC_CONST_STRING kIXDrawerViewAnimationSwingingDoor = @"swingingDoor";
IX_STATIC_CONST_STRING kIXDrawerViewAnimationParallax = @"parallax";
IX_STATIC_CONST_STRING kIXDrawerViewAnimationParallaxFactor = @"drawer.animation.parallaxFactor";

IX_STATIC_CONST_STRING kIXRequestAccessPushAuto = @"requestAccess.push.auto"; // Should app automatically request access to push. If NO must use app function kIXRequestAccessPush to request push
IX_STATIC_CONST_STRING kIXRequestAccessMicrophoneAuto = @"mic.autoRequest.enabled"; // Should app automatically request access to microphone. If NO must use app function kIXRequestAccessPush to request push
IX_STATIC_CONST_STRING kIXRequestAccessLocationAuto = @"location.autoRequest.enabled"; // Should app automatically request access to location. If NO must use app function kIXRequestAccessLocation to track location.  This will begin tracking automatically as well when set to YES.

// App Attribute Values
IX_STATIC_CONST_STRING kIXLocationAccuracyBest = @"best"; // location services
IX_STATIC_CONST_STRING kIXLocationAccuracyBestForNavigation = @"bestForNavigation"; // location services
IX_STATIC_CONST_STRING kIXLocationAccuracyNearestTenMeters = @"nearestTenMeters"; // location services
IX_STATIC_CONST_STRING kIXLocationAccuracyHundredMeters = @"hundredMeters"; // location services
IX_STATIC_CONST_STRING kIXLocationAccuracyKilometer = @"kilometer"; // location services
IX_STATIC_CONST_STRING kIXLocationAccuracyThreeKilometers = @"threeKilometers"; // location services
IX_STATIC_CONST_STRING KIXDrawerAllowedStateOpen = @"open"; // drawer
IX_STATIC_CONST_STRING KIXDrawerAllowedStateClosed = @"closed"; // drawer
IX_STATIC_CONST_STRING KIXDrawerAllowedStateAll = @"all"; // drawer
IX_STATIC_CONST_STRING KIXDrawerAllowedStateNone = @"none"; // drawer

// App Functions
IX_STATIC_CONST_STRING kIXReset = @"reset";
IX_STATIC_CONST_STRING kIXDestorySession = @"destroySession";

IX_STATIC_CONST_STRING kIXToggleDrawerLeft = @"drawer.l.toggle";
IX_STATIC_CONST_STRING kIXToggleDrawerRight = @"drawer.r.toggle";

// TODO: These should be cleaned up and adjusted to drawer.open.enable and drawer.close.disable and drawer.all.enable etc.
//IX_STATIC_CONST_STRING kIXEnableDrawerPrefix = @"drawer.enabled"; // Function name must have one of the following suffixes.
//IX_STATIC_CONST_STRING kIXDisableDrawerPrefix = @"drawer.disable"; // Function name must have one of the following suffixes.
//IX_STATIC_CONST_STRING kIXEnableDisableDrawerOpenSuffix = @".open";
//IX_STATIC_CONST_STRING kIXEnableDisableDrawerCloseSuffix = @".close";
//IX_STATIC_CONST_STRING kIXEnableDisableDrawerOpenAndCloseSuffix = @".openClose";

IX_STATIC_CONST_STRING kIXRequestAccessPush = @"push.auth.request";
IX_STATIC_CONST_STRING kIXRequestAccessMicrophone = @"mic.auth.request";
IX_STATIC_CONST_STRING kIXRequestAccessLocation = @"location.auth.request";

IX_STATIC_CONST_STRING kIXStartLocationTracking = @"location.beginTracking";
IX_STATIC_CONST_STRING kIXStopLocationTracking = @"location.endTracking";

// Device Readonly Attributes
IX_STATIC_CONST_STRING kIXDeviceModel = @"model";
IX_STATIC_CONST_STRING kIXDeviceType = @"type";
IX_STATIC_CONST_STRING kIXDeviceScreenWidth = @"screen.w";
IX_STATIC_CONST_STRING kIXDeviceScreenWidthX = @"screen.width";
IX_STATIC_CONST_STRING kIXDeviceScreenHeight = @"screen.h";
IX_STATIC_CONST_STRING kIXDeviceScreenHeightX = @"screen.height";
IX_STATIC_CONST_STRING kIXDeviceScreenScale = @"screen.scale";
IX_STATIC_CONST_STRING kIXDeviceOSVersion = @"os.version";
IX_STATIC_CONST_STRING kIXDeviceOSVersionInteger = @"os.version.integer";
IX_STATIC_CONST_STRING kIXDeviceOSVersionMajor = @"os.version.major";

// Non attribute constants
IX_STATIC_CONST_STRING kIXAssetsBasePath = @"IXAssets";
IX_STATIC_CONST_STRING kIXDefaultIndexPath = @"IXApp";

// TODO: deprecate in future releases
IX_STATIC_CONST_STRING kIXDefaultIndexPathOld = @"assets/_index.json";
IX_STATIC_CONST_STRING kIXTokenStringFormat = @"%08x%08x%08x%08x%08x%08x%08x%08x";

@interface IXAppManager () <IXLocationManagerDelegate>

@property (nonatomic,assign) IXAppMode appMode;
@property (nonatomic,assign) BOOL layoutDebuggingEnabled;
@property (nonatomic,strong) IXSandbox *applicationSandbox;

//@property (nonatomic,strong) MMDrawerController *drawerController;
@property (nonatomic,strong) IXNavigationViewController *rootViewController;

@property (nonatomic,copy) NSString *pushToken;
@property (nonatomic,copy) NSString *appIndexFilePath;
@property (nonatomic,copy) NSString *appDefaultViewPath;
@property (nonatomic,copy) NSString *appLeftDrawerViewPath;
@property (nonatomic,copy) NSString *appRightDrawerViewPath;

@property (nonatomic,strong) IXAttributeContainer *deviceProperties;
@property (nonatomic,strong) IXAttributeContainer *appProperties;
@property (nonatomic,strong) IXAttributeContainer *sessionProperties;
@property (nonatomic,strong) IXActionContainer* actionContainer;

@property (nonatomic,strong) Reachability *reachabilty;
@property (nonatomic,strong) ApigeeClient *apigeeClient;

@property (nonatomic,strong) UIWebView *webViewForJS;

@property (nonatomic,assign) BOOL accessToPushGranted;
@property (nonatomic,assign) BOOL accessToMicrophoneGranted;
@property (nonatomic,assign) BOOL accessToLocationGranted;

@end

@implementation IXAppManager

-(id)init
{
    self = [super init];
    if( self )
    {
        NSString* defaultIndexPath = [[[NSBundle mainBundle] objectForInfoDictionaryKey:kIXAssetsBasePath] stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:kIXDefaultIndexPath]];
        _appIndexFilePath = [IXPathHandler localPathWithRelativeFilePath:defaultIndexPath];
        if (!_appIndexFilePath) _appIndexFilePath = [IXPathHandler localPathWithRelativeFilePath:kIXDefaultIndexPathOld];
// TODO: deprecate in future releases
        if (!_appIndexFilePath) _appIndexFilePath = [IXPathHandler localPathWithRelativeFilePath:kIXDefaultIndexPathOld];
        
        _appProperties = [[IXAttributeContainer alloc] init];
        _deviceProperties = [[IXAttributeContainer alloc] init];
        
        _rootViewController = [[IXNavigationViewController alloc] initWithNibName:nil bundle:nil];
        _drawerController = [[IXMMDrawerController alloc] initWithCenterViewController:_rootViewController
                                                            leftDrawerViewController:nil
                                                           rightDrawerViewController:nil];
        
        [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
        [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];

        _reachabilty = [Reachability reachabilityForInternetConnection];

        [[IXLocationManager sharedLocationManager] setDelegate:self];
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
        IXAttributeContainer* appProperties = [self appProperties];
        NSString* apigeePushNotifier = [appProperties getStringValueForAttribute:kIXApigeePushNotifier
                                                                defaultValue:nil];
        
        ApigeeClientResponse *response = [apigeeDataClient setDevicePushToken:deviceToken
                                                                  forNotifier:apigeePushNotifier];
        
        if( ![response completedSuccessfully])
        {
            IX_LOG_ERROR(@"Error Setting Push Token with ApigeeClient : %@", [response rawResponse]);
        }
    }

    [_actionContainer executeActionsForEventNamed:kIXAppRegisterForRemoteNotificationsSuccess];
    [self setAccessToPushGranted:YES];
}

-(void)appFailedToRegisterForRemoteNotifications
{
    [_actionContainer executeActionsForEventNamed:kIXAppRegisterForRemoteNotificationsFailed];
    [self setAccessToPushGranted:NO];
}

-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo
{
    IX_LOG_DEBUG(@"Push Notification Info : %@",[userInfo description]);

    [_actionContainer executeActionsForEventNamed:kIXPushRecievedEvent];
    
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

-(BOOL)appDidOpenWithCustomURL:(NSURL *)customURL
{
    IX_LOG_DEBUG(@"App opened with Custom URL : %@",[customURL absoluteString]);
    
    [_actionContainer executeActionsForEventNamed:kIXCustomURLSchemeOpened];

    IXBaseAction* action = [IXBaseAction actionWithCustomURLQueryParams:[customURL ix_parseQueryStringToParamsDict]];
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
        return YES;
    }
    return NO;
}

-(void)startApplication
{
    [[self drawerController] setLeftDrawerViewController:nil];
    [[self drawerController] setRightDrawerViewController:nil];
    [self setAppLeftDrawerViewPath:nil];
    [self setAppRightDrawerViewPath:nil];

    [self setSessionProperties:[[IXAttributeContainer alloc] init]];

    [self setWebViewForJS:[[UIWebView alloc] initWithFrame:CGRectZero]];
    [self setApplicationSandbox:[[IXSandbox alloc] initWithBasePath:nil rootPath:[[self appIndexFilePath] stringByDeletingLastPathComponent]]];
    
    [[IXDataLoader sharedDataLoader] loadJSONFromPath:[self appIndexFilePath]
                                                 async:NO
                                            shouldCache:NO
                                        completion:^(id jsonObject, NSString* stringValue, NSError *error) {
                                            
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
                                                [[self appProperties] addAttributesFromContainer:[IXAttributeContainer attributeContainerWithJSONDict:appConfigPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherAttributesWithSameName:YES];
                                                
                                                NSDictionary* sessionDefaultsPropertiesJSONDict = [jsonObject valueForKeyPath:kIXSessionDefaults];
                                                [[self sessionProperties] addAttributesFromContainer:[IXAttributeContainer attributeContainerWithJSONDict:sessionDefaultsPropertiesJSONDict] evaluateBeforeAdding:NO replaceOtherAttributesWithSameName:YES];
                                                [self loadStoredSessionProperties];

                                                NSDictionary* deviceInfoPropertiesDict = @{
                                                                                           kIXDeviceModel: [IXDeviceInfo deviceModel],
                                                                                           kIXDeviceType: [IXDeviceInfo deviceType],
                                                                                           kIX_ORIENTATION: [IXDeviceInfo interfaceOrientation],
                                                                                           kIXDeviceScreenWidth: [IXDeviceInfo screenWidth],
                                                                                           kIXDeviceScreenWidthX: [IXDeviceInfo screenWidth],
                                                                                           kIXDeviceScreenHeight: [IXDeviceInfo screenHeight],
                                                                                           kIXDeviceScreenHeightX: [IXDeviceInfo screenHeight],
                                                                                           kIXDeviceScreenScale: [IXDeviceInfo screenScale],
                                                                                           kIXDeviceOSVersion: [IXDeviceInfo osVersion],
                                                                                           kIXDeviceOSVersionInteger: [IXDeviceInfo osVersionAsInteger],
                                                                                           kIXDeviceOSVersionMajor: [IXDeviceInfo osMajorVersion]
                                                                                           };
                                                
                                                [[self deviceProperties] addAttributesFromContainer:[IXAttributeContainer attributeContainerWithJSONDict:deviceInfoPropertiesDict] evaluateBeforeAdding:NO replaceOtherAttributesWithSameName:YES];

                                                [self applyAppProperties];
                                                [self preloadImages];
                                                [self loadApplicationDefaultView];
                                                [[self applicationSandbox] loadAllDataProviders];
                                            }
                                        }];
}

-(void)preloadImages
{
    NSArray* imagesToPreload = [[self appProperties] getCommaSeparatedArrayOfValuesForAttribute:kIXPreloadImages defaultValue:nil];
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
    if( [[[self appProperties] getStringValueForAttribute:kIXAppMode defaultValue:kIX_RELEASE] isEqualToString:kIX_DEBUG] ) {
        [self setAppMode:IXDebugMode];
//        RKLogConfigureByName("*", RKLogLevelOff);
    } else {
        [self setAppMode:IXReleaseMode];
//        RKLogConfigureByName("*", RKLogLevelOff);
    }
    
    [[IXLogger sharedLogger] setRequestLoggingEnabled:[[self appProperties] getBoolValueForAttribute:kIXEnableRequestLogging defaultValue:NO]];
    [[IXLogger sharedLogger] setRemoteLoggingEnabled:[[self appProperties] getBoolValueForAttribute:kIXEnableRemoteLogging defaultValue:NO]];
    [[IXLogger sharedLogger] setAppLogLevel:[[self appProperties] getStringValueForAttribute:kIXLogLevel defaultValue:kIX_DEBUG]];
    [self setLayoutDebuggingEnabled:[[self appProperties] getBoolValueForAttribute:kIXEnableLayoutDebugging defaultValue:NO]];

    [[self rootViewController] setNavigationBarHidden:![[self appProperties] getBoolValueForAttribute:kIXShowsNavigationBar defaultValue:YES] animated:YES];
    if( [[self rootViewController] isNavigationBarHidden] )
    {
        [[[self rootViewController] interactivePopGestureRecognizer] setDelegate:nil];
    }
    
    NSString* apigeeOrgName = [[self appProperties] getStringValueForAttribute:kIXApigeeOrgID defaultValue:nil];
    NSString* apigeeApplicationID = [[self appProperties] getStringValueForAttribute:kIXApigeeAppID defaultValue:nil];
    NSString* apigeeBaseURL = [[self appProperties] getStringValueForAttribute:kIXApigeeBaseURL defaultValue:nil];
    
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
    
    [self setAppDefaultViewPath:[[self appProperties] getStringValueForAttribute:kIXDefaultView defaultValue:nil]];
    [self setAppLeftDrawerViewPath:[[self appProperties] getStringValueForAttribute:kIXDrawerViewLeft defaultValue:nil]];
    [self setAppRightDrawerViewPath:[[self appProperties] getStringValueForAttribute:kIXDrawerViewRight defaultValue:nil]];
    [[self drawerController] setAnimationVelocity:[[self appProperties] getFloatValueForAttribute:kIXDrawerToggleVelocity defaultValue:840.0f]];
    
    if( [[self appDefaultViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appDefaultViewPath]] )
    {
        [self setAppDefaultViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:kIXAssetsBasePath],[self appDefaultViewPath]]]];
    }
    if( [[self appLeftDrawerViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appLeftDrawerViewPath]] )
    {
        [self setAppLeftDrawerViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:kIXAssetsBasePath],[self appLeftDrawerViewPath]]]];
    }
    if( [[self appRightDrawerViewPath] length] > 0 && [IXPathHandler pathIsLocal:[self appRightDrawerViewPath]] )
    {
        [self setAppRightDrawerViewPath:[IXPathHandler localPathWithRelativeFilePath:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:kIXAssetsBasePath],[self appRightDrawerViewPath]]]];
    }
    if (self.appLeftDrawerViewPath != nil || self.appRightDrawerViewPath != nil) {
        NSString* drawerAllowedStates = [[self appProperties] getStringValueForAttribute:kIXDrawerAllowedStates defaultValue:nil];
        if ([drawerAllowedStates isEqualToString:KIXDrawerAllowedStateOpen]) {
            [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
            [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
        } else if ([drawerAllowedStates isEqualToString:KIXDrawerAllowedStateClosed]) {
            [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
        } else if ([drawerAllowedStates isEqualToString:KIXDrawerAllowedStateAll]) {
            [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningCenterView];
            [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
        } else if ([drawerAllowedStates isEqualToString:KIXDrawerAllowedStateNone]) {
            [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
        }
    }

    if( [[self appProperties] getBoolValueForAttribute:kIXRequestAccessPushAuto defaultValue:YES] ) {
        [self applyFunction:kIXRequestAccessPush parameters:nil];
    }

    if( [[self appProperties] getBoolValueForAttribute:kIXRequestAccessMicrophoneAuto defaultValue:NO] ) {
        [self applyFunction:kIXRequestAccessMicrophone parameters:nil];
    }

    if( [[self appProperties] getBoolValueForAttribute:kIXRequestAccessLocationAuto defaultValue:YES] ) {
        [self applyFunction:kIXRequestAccessLocation parameters:nil];
        [self applyFunction:kIXStartLocationTracking parameters:nil];
    }
    
    [[self drawerController] setShowsShadow:[[self appProperties] getBoolValueForAttribute:kIXDrawerViewShadow defaultValue:YES] ];
    
    
    
    NSString* animation = [[self appProperties] getStringValueForAttribute:kIXDrawerViewAnimation defaultValue:nil];
    if( [animation length] ) {
        
        if ([animation isEqualToString:kIXDrawerViewAnimationSlide])
        {
            [[self drawerController] setDrawerVisualStateBlock: [MMDrawerVisualState slideVisualStateBlock]];
        }
        else if ([animation isEqualToString:kIXDrawerViewAnimationSlideAndScale])
        {
            [[self drawerController] setDrawerVisualStateBlock: [MMDrawerVisualState slideAndScaleVisualStateBlock]];
        }
        else if ([animation isEqualToString:kIXDrawerViewAnimationSwingingDoor])
        {
            [[self drawerController] setDrawerVisualStateBlock: [MMDrawerVisualState swingingDoorVisualStateBlock]];
        }
        else if ([animation isEqualToString:kIXDrawerViewAnimationParallax])
        {
            [[self drawerController] setDrawerVisualStateBlock: [MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:[[self appProperties] getFloatValueForAttribute:kIXDrawerViewAnimationParallaxFactor defaultValue:2] ]];
        }
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

    BOOL preloadDrawers = [[self appProperties] getBoolValueForAttribute:kIXPreloadDrawers defaultValue:NO];
    if( [[self appLeftDrawerViewPath] length] > 0 ) {
        [IXViewController createViewControllerWithPathToJSON:[self appLeftDrawerViewPath]
                                                   loadAsync:NO
                                             completionBlock:^(BOOL didSucceed, IXViewController *viewController, NSError* error) {
                                           
                                                 if( didSucceed && viewController && error == nil )
                                                 {
                                                     [[self drawerController] setMaximumLeftDrawerWidth:[[self appProperties] getFloatValueForAttribute:kIXDrawerViewLeftMaxWidth defaultValue:280.0f]];
                                                     [[self drawerController] setLeftDrawerViewController:viewController];
                                                     [[[self rootViewController] interactivePopGestureRecognizer] setEnabled:NO];
                                                     [[[self rootViewController] leftScreenPanGestureRecognizer] setEnabled:NO];

                                                     if( preloadDrawers ) {
                                                         [viewController viewWillAppear:YES];
                                                     }
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
                                                     [[self drawerController] setMaximumRightDrawerWidth:[[self appProperties] getFloatValueForAttribute:kIXDrawerViewRightMaxWidth defaultValue:280.0f]];
                                                     [[self drawerController] setRightDrawerViewController:viewController];
                                                     [[[self rootViewController] interactivePopGestureRecognizer] setEnabled:NO];
                                                     [[[self rootViewController] rightScreenPanGestureRecognizer] setEnabled:NO];

                                                     if( preloadDrawers ) {
                                                         [viewController viewWillAppear:YES];
                                                     }
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
    return [[UIApplication sharedApplication] statusBarOrientation];
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

-(void)applyFunction:(NSString*)functionName parameters:(IXAttributeContainer*)parameters
{
    if ([functionName isEqualToString:kIXReset])
    {
        // Clear caches.
        [[[SDWebImageManager sharedManager] imageCache] clearMemory];
        [[[SDWebImageManager sharedManager] imageCache] clearDisk];
        [IXDataLoader clearCache];
        [IXControlCacheContainer clearCache];
        
        [[IXAppManager sharedAppManager] startApplication];
    }
    else if ([functionName isEqualToString:kIXDestorySession])
    {
        [[self sessionProperties] removeAllAttributes];
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
    else if( [functionName isEqualToString:kIXRequestAccessPush] )
    {
        [((IXAppDelegate*)[[UIApplication sharedApplication] delegate]) registerForPushNotifications];
    }
    else if( [functionName isEqualToString:kIXRequestAccessMicrophone] )
    {
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [audioSession setActive:YES error:nil];
        [audioSession requestRecordPermission:^(BOOL granted) {
            [self setAccessToMicrophoneGranted:granted];
            [_actionContainer executeActionsForEventNamed:kIXMicrophoneAuthChanged];
        }];
    }
    else if( [functionName isEqualToString:kIXRequestAccessLocation] )
    {
        [[IXLocationManager sharedLocationManager] requestAccessToLocation];
    }
    else if( [functionName isEqualToString:kIXStartLocationTracking] )
    {
        NSString* parameterLocationAccuracy = [parameters getStringValueForAttribute:kIXLocationAccuracy defaultValue:kIXLocationAccuracyBest];
        NSString* locationAccuracy = [[self appProperties] getStringValueForAttribute:kIXLocationAccuracy defaultValue:parameterLocationAccuracy];
        if( [locationAccuracy isEqualToString:kIXLocationAccuracyBest] || locationAccuracy == nil ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
        } else if( [locationAccuracy isEqualToString:kIXLocationAccuracyBestForNavigation] ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        } else if( [locationAccuracy isEqualToString:kIXLocationAccuracyNearestTenMeters] ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        } else if( [locationAccuracy isEqualToString:kIXLocationAccuracyHundredMeters] ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        } else if( [locationAccuracy isEqualToString:kIXLocationAccuracyKilometer] ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyKilometer];
        } else if( [locationAccuracy isEqualToString:kIXLocationAccuracyThreeKilometers] ) {
            [[IXLocationManager sharedLocationManager] setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        }

        [[IXLocationManager sharedLocationManager] beginLocationTracking];
    }
    else if( [functionName isEqualToString:kIXStopLocationTracking] )
    {
        [[IXLocationManager sharedLocationManager] stopTrackingLocation];
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
        IXAttributeContainer* storedSessionPropertyContainer = [NSKeyedUnarchiver unarchiveObjectWithData:sessionPropertiesData];
        if( [storedSessionPropertyContainer isKindOfClass:[IXAttributeContainer class]] )
        {
            [[self sessionProperties] addAttributesFromContainer:storedSessionPropertyContainer
                                                    evaluateBeforeAdding:NO
                                   replaceOtherAttributesWithSameName:YES];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIX_STORED_SESSION_ATTRIBUTES_KEY];
        }
    }
}

-(void)locationManagerAuthStatusChanged:(CLAuthorizationStatus)status
{
    [_actionContainer executeActionsForEventNamed:kIXLocationAuthChanged];
    [self setAccessToLocationGranted:[[IXLocationManager sharedLocationManager] isAuthorized]];
}

-(void)locationManagerDidUpdateLocation:(CLLocation *)location
{
    [_actionContainer executeActionsForEventNamed:kIXLocationLocationUpdated];
}

@end
