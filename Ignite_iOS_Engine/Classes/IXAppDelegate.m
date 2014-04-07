//
//  IXAppDelegate.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppDelegate.h"

#import "IXWindow.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "JASidePanelController.h"
#import "IXLogger.h"
#import "IXPropertyContainer.h"

#import "ApigeeClient.h"
#import "ApigeeDataClient.h"

@implementation IXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setIxWindow:[[IXWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [[self ixWindow] setRootViewController:[[IXAppManager sharedAppManager] rootViewController]];
    
    [[IXAppManager sharedAppManager] startApplication];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSDictionary* remoteNotificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if( remoteNotificationInfo != nil )
    {
        //[self handlePushNotification:remoteNotificationInfo forApplication:application];
    }
    
    [[self ixWindow] makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    IXAppManager* sharedAppManager = [IXAppManager sharedAppManager];

    ApigeeDataClient* apigeeDataClient = [[sharedAppManager apigeeClient] dataClient];
    if( apigeeDataClient != nil )
    {
        IXPropertyContainer* appProperties = [sharedAppManager appProperties];
        NSString* apigeePushNotifier = [appProperties getStringPropertyValue:@"apigee_push_notifier"
                                                                defaultValue:nil];
        
        ApigeeClientResponse *response = [apigeeDataClient setDevicePushToken:newDeviceToken
                                                                  forNotifier:apigeePushNotifier];
        
        if( ![response completedSuccessfully])
        {
            DDLogError(@"Error Setting Push Token with ApigeeClient : %@", [response rawResponse]);
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
