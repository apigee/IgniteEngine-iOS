//
//  IXAppManager.h
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

#import <Foundation/Foundation.h>

typedef enum {
    IXDebugMode,
    IXReleaseMode
} IXAppMode;

@class IXNavigationViewController;
@class IXAttributeContainer;
@class IXSandbox;
@class IXViewController;

@class ApigeeClient;
@class MMDrawerController;
@class Reachability;

@interface IXAppManager : NSObject

@property (nonatomic,assign,readonly) IXAppMode appMode;
@property (nonatomic,assign,readonly,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;
@property (nonatomic,strong,readonly) IXSandbox *applicationSandbox;

@property (nonatomic,strong) MMDrawerController *drawerController;
@property (nonatomic,strong,readonly) IXNavigationViewController *rootViewController;
@property (nonatomic,assign,readonly) IXViewController* currentIXViewController;

@property (nonatomic,copy,readonly) NSString *pushToken;
@property (nonatomic,copy,readonly) NSString *appDefaultViewPath;
@property (nonatomic,copy,readonly) NSString *appLeftDrawerViewPath;
@property (nonatomic,copy,readonly) NSString *appRightDrawerViewPath;

@property (nonatomic,strong,readonly) IXAttributeContainer *deviceProperties;
@property (nonatomic,strong,readonly) IXAttributeContainer *appProperties;
@property (nonatomic,strong,readonly) IXAttributeContainer *sessionProperties;

@property (nonatomic,strong,readonly) Reachability *reachabilty;
@property (nonatomic,strong,readonly) ApigeeClient *apigeeClient;

@property (nonatomic,assign,readonly) BOOL accessToPushGranted;
@property (nonatomic,assign,readonly) BOOL accessToMicrophoneGranted;
@property (nonatomic,assign,readonly) BOOL accessToLocationGranted;

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
 *  Tells the manager that a the app opened with a custom URL scheme
 *
 *  Example of custom url scheme: NSString* customURLOpen = @"mycustomurlscheme://open.com?_type=alert&title=App%20Opened";
 *
 *  @param customURL The custom url used to open this app.
 *
 *  @return YES if the app was opened and an action was created and executed with its query parameters.
 */
-(BOOL)appDidOpenWithCustomURL:(NSURL *)customURL;

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
-(void)applyFunction:(NSString*)functionName parameters:(IXAttributeContainer*)parameters;

/**
 *  Convenience method used to get the current interface orientation of the keyWindow's rootViewController.
 *
 *  @return The current interface orientation.
 */
+(UIInterfaceOrientation)currentInterfaceOrientation;

@end
