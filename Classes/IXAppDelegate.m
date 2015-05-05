//
//  IXAppDelegate.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
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

#import "IXAppDelegate.h"

#import "IXWindow.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXLogger.h"
#import "IXAttributeContainer.h"

#import "ApigeeClient.h"
#import "ApigeeDataClient.h"
#import "MMDrawerController.h"

@implementation IXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setIxWindow:[[IXWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [[self ixWindow] setRootViewController:[[IXAppManager sharedAppManager] drawerController]];
    
    [[IXAppManager sharedAppManager] startApplication];
    
    [[self ixWindow] makeKeyAndVisible];
    
    NSDictionary* remoteNotificationInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if( remoteNotificationInfo != nil )
    {
        [[IXAppManager sharedAppManager] appDidRecieveRemoteNotification:remoteNotificationInfo];
    }
    
    return YES;
}

- (void)registerForPushNotifications
{
    UIApplication* application = [UIApplication sharedApplication];

    // Push notification support for iOS 8
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationCategory* category = [self registerActions];
        NSMutableSet* categories = [NSMutableSet set];
        [categories addObject:category];
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
        [application registerUserNotificationSettings:notificationSettings];
    } else {
        [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
#else
    [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [[IXAppManager sharedAppManager] appDidRegisterRemoteNotificationDeviceToken:newDeviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[IXAppManager sharedAppManager] appFailedToRegisterForRemoteNotifications];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[IXAppManager sharedAppManager] appDidRecieveRemoteNotification:userInfo];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    if([identifier isEqualToString: @"action_one"]) {
        IX_LOG_INFO(@"Push Interaction: %@", identifier);
    }
    if([identifier isEqualToString: @"action_two"]) {
        IX_LOG_INFO(@"Push Interaction: %@", identifier);
    }
    completionHandler();
}

#endif

- (UIMutableUserNotificationCategory*)registerActions {
    UIMutableUserNotificationAction* action = [[UIMutableUserNotificationAction alloc] init];
    action.identifier = @"action_one";
    action.title = @"one";
    action.activationMode = UIUserNotificationActivationModeForeground;
    action.destructive = true;
    action.authenticationRequired = false;
    
    UIMutableUserNotificationAction* action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.identifier = @"action_two";
    action2.title = @"two";
    action2.activationMode = UIUserNotificationActivationModeBackground;
    action2.destructive = false;
    action2.authenticationRequired = false;
    
    UIMutableUserNotificationCategory* category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = @"category_name";
    [category setActions:@[action2,action] forContext: UIUserNotificationActionContextDefault];
    return category;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[IXAppManager sharedAppManager] appDidOpenWithCustomURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[IXAppManager sharedAppManager] storeSessionProperties];
    [[IXAppManager sharedAppManager] appWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[IXAppManager sharedAppManager] storeSessionProperties];
    [[IXAppManager sharedAppManager] appDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[IXAppManager sharedAppManager] appWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[IXAppManager sharedAppManager] appDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[IXAppManager sharedAppManager] storeSessionProperties];
    [[IXAppManager sharedAppManager] appWillTerminate];
}

@end
