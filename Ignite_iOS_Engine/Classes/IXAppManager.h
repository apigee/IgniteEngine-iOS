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

/**
 *  Tells the manager that a remote notification has been recieved.
 *  This method should be called from application:didReceiveRemoteNotification: in your application delegate.
 *
 *  @param userInfo The remote notification's user info dictionary.
 */
-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo;

/**
 *  Stores the current sessionProperties object onto the disk for retrieval when the app starts again.
 */
-(void)storeSessionProperties;

/**
 *  Evaluates the given javascript.
 *
 *  @param javascript The javascript to be evaluated.
 *
 *  @return The string result from evaluating the javascript.
 */
-(NSString*)evaluateJavascript:(NSString*)javascript;

/**
 *  Convenience method used to get the current interface orientation of the keyWindow's rootViewController.
 *
 *  @return The current interface orientation.
 */
+(UIInterfaceOrientation)currentInterfaceOrientation;

@end
