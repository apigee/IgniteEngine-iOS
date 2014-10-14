//
//  IXAppManager.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    IXDebugMode,
    IXReleaseMode
} IXAppMode;

@class IXNavigationViewController;
@class IXPropertyContainer;
@class IXSandbox;
@class IXViewController;
@class IXActionContainer;

@class ApigeeClient;
@class MMDrawerController;
@class Reachability;

@interface IXAppManager : NSObject

@property (nonatomic,assign,readonly) IXAppMode appMode;
@property (nonatomic,assign,readonly,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;
@property (nonatomic,strong,readonly) IXSandbox *applicationSandbox;

@property (nonatomic,strong,readonly) MMDrawerController *drawerController;
@property (nonatomic,strong,readonly) IXNavigationViewController *rootViewController;
@property (nonatomic,assign,readonly) IXViewController* currentIXViewController;

@property (nonatomic,copy,readonly) NSString *pushToken;
@property (nonatomic,copy,readonly) NSString *appDefaultViewPath;
@property (nonatomic,copy,readonly) NSString *appLeftDrawerViewPath;
@property (nonatomic,copy,readonly) NSString *appRightDrawerViewPath;

@property (nonatomic,strong,readonly) IXPropertyContainer *deviceProperties;
@property (nonatomic,strong,readonly) IXPropertyContainer *appProperties;
@property (nonatomic,strong,readonly) IXPropertyContainer *sessionProperties;

@property (nonatomic,strong,readonly) Reachability *reachabilty;
@property (nonatomic,strong,readonly) ApigeeClient *apigeeClient;

/**
 *  The singleton application manager which manages the entire IX application
 *
 *  @return The singleton instance of IXAppManager
 */
+(instancetype)sharedAppManager;

/**
 *  Starts the application.
 */
-(void)startApplication;

/**
 *  Applies the appProperties instance variable.
 */
-(void)applyAppProperties;

/**
 *  Tells the manager when that the application has registered a device token.
 *  This method should be called from application:didRegisterForRemoteNotificationsWithDeviceToken: in your application delegate.
 *
 *  @param deviceToken The applications remote notification device token.
 */
-(void)appDidRegisterRemoteNotificationDeviceToken:(NSData *)deviceToken;

-(void)appFailedToRegisterForRemoteNotifications;

/**
 *  Tells the manager that a remote notification has been recieved.
 *  This method should be called from application:didReceiveRemoteNotification: in your application delegate.
 *
 *  Example Push Notificaiton String = NSString* pushNotification = @"{\"apple\":{\"aps\":{\"alert\":\"[apns-test] Some Text!\",\"sound\":\"chime\",\"badge\":0},\"action\":[\"navigate\",{\"attributes\":{\"to\":\"device://assets/examples/IXButtonControlExample.json\"}}]}}";
 *
 *  @param userInfo The remote notification's user info dictionary.
 */
-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo;

/**
 *  Stores the current sessionProperties object onto the disk for retrieval when the app starts again.
 */
-(void)storeSessionProperties;

/**
 *  Sent when the application is about to move from active to inactive state.
 */
-(void)appWillResignActive;

/**
 *  Sent when the application moved from foreground to background state.
 */
-(void)appDidEnterBackground;

/**
 *  Sent when the application is about to move from background to foreground state.
 */
-(void)appWillEnterForeground;

/**
 *  Sent when the application became active. Fires on first load + when moving from background to foreground.
 */
-(void)appDidBecomeActive;

/**
 *  Called when the application is about to terminate.
 */
-(void)appWillTerminate;

/**
 *  Evaluates the given javascript.
 *
 *  @param javascript The javascript to be evaluated.
 *
 *  @return The string result from evaluating the javascript.
 */
-(NSString*)evaluateJavascript:(NSString*)javascript;

/**
 *  Applies the application level function.
 *
 *  @param functionName The name of the function to apply.
 *  @param parameters   The parameters that the function will use. (can be nil if unneeded)
 */
-(void)applyFunction:(NSString*)functionName parameters:(IXPropertyContainer*)parameters;

/**
 *  Convenience method used to get the current interface orientation of the keyWindow's rootViewController.
 *
 *  @return The current interface orientation.
 */
+(UIInterfaceOrientation)currentInterfaceOrientation;

@end
