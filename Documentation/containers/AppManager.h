//
//  AppManager.h
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/8/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Description of app manager goes here, mmmkaaay?
*/

@implementation AppManager

/***************************************************************/

/** AppManager has the following containers:
 
 @param app.actions Array of actions that fire on app-level events<br><pre>array</pre>
 @param app.attributes Object of app-level attributes<br><pre>object</pre>
 @param app.datasources Array of datasources available app-wide<br><pre>array</pre>
 
 */

-(void)Containers
{
}
/***************************************************************/
/***************************************************************/

/** AppManager has the following attributes:
 
 @param mode App mode<ul><li>*debug*</li><li>release</li></ul>
 @param logLevel Logging leven<ul><li>*debug*</li><li>release</li><li>error</li><li>verbose</li></ul>
 @param controller.default Default controller to display when app opens<br><pre>string</pre>
 @param drawerController.l.url Controller to display as left drawer view controller<br><pre>string</pre>
 @param drawerController.l.max.w Width to slide the current view controller, revealing left drawer view controller<br><pre>float</pre>
 @param drawerController.r.url Controller to display as right drawer view controller<br><pre>string</pre>
 @param drawerController.r.max.w Width to slide the current view controller, revealing right drawer view controller<br><pre>float</pre>
 @param drawerController.toggleVelocity Velocity of current view controller slide animation<br><pre>float</pre>
 @param debug.layout.enabled Enable layout debugging<br><pre>bool</pre>
 @param logging.datasource.enabled Enable datasource logging<br><pre>bool</pre>
 @param logging.remote.enabled Enable remote logging<br><pre>bool</pre>
 @param location.accuracy Accuracy of location tracking<ul><li>*best*</li><li>bestForNavigation</li><li>nearestTenMeters</li><li>hundredMeters</li><li>kilometer</li><li>threeKilometers</li></ul>
 @param navigationBar.enabled Enable stock Navigation Bar<br><pre>bool</pre>
 @param preloadImages Object containing images to preload<br><pre>object</pre>
 @param apigee.OrgId Apigee BaaS Org ID<br><pre>string</pre>
 @param apigee.AppId Apigee BaaS App ID<br><pre>string</pre>
 @param apigee.BaseUrl Apigee BaaS base url<br><pre>string</pre>
 @param apigee.NotifierId Apigee BaaS Push Notifier ID<br><pre>string</pre>
 @param push.autoRequest.enabled Automatically request authorization for push notifications<br><pre>bool</pre>
 @param mic.autoRequest.enabled Automatically request authorization to microphone<br><pre>bool</pre>
 @param location.autoRequest.enabled Automatically request authorization for device location<br><pre>bool</pre>
 @param best Location accuracy: Use the highest-level of accuracy<br><pre>string</pre>
 @param bestForNavigation Location accuracy: Use the highest possible accuracy and combine it with additional sensor data. This level of accuracy is intended for use in navigation applications that require precise position information at all times and are intended to be used only while the device is plugged in.<br><pre>string</pre>
 @param nearestTenMeters Location accuracy: Accurate to within ten meters of the desired target.<br><pre>string</pre>
 @param hundredMeters Location accuracy: Accurate to within one hundred meters.<br><pre>string</pre>
 @param kilometer Location accuracy: Accurate to the nearest kilometer.<br><pre>string</pre>
 @param threeKilometers Location accuracy: Accurate to the nearest three kilometers.<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** AppManager fires the following events:
 
 @param willResignActive Fires will the app will move from the active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the app and it begins the transition to the background state. An app in the inactive state continues to run but does not dispatch incoming events to responders.
 @param didEnterBackground Fires when the app entered the background. Use this method to release shared resources, invalidate timers, and store enough app state information to restore your app to its current state in case it is terminated later.
 @param willEnterForeground Fires when the app will transition from the background to the active state. You can use this method to undo many of the changes you made to your app upon entering the background.
 @param didBecomeActive Fires when the app moved from the inactive to active state. This can occur because your app was launched by the user or the system.
 @param willTerminate Fires when app is about to be terminated and purged from memory entirely. You should use this method to perform any final clean-up tasks for your app, such as freeing shared resources, saving user data, and invalidating timers.
 @param push.register.success Fires when the app successfully registered with Apple Push Notification service (APNs).
 @param push.register.error Fires when the app cannot successfully register with Apple Push Notification service (APNs).
 @param push.received Fires when the app receives a push notification
 @param customUrl.opened Fires when app is opened using a custom URL
 @param location.auth.changed Fires when location authorization has changed
 @param location.changed Fires when device location has changed
 @param mic.auth.changed Fires when device micrphone authorization has changed
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** AppManager has the following functions:
 
 @param reset Resets app. Clears image and data cache and reloads app.
 @param destroySession Destroys all session variables.
 @param drawerController.l.toggle Toggles left drawer controller.
 @param drawerController.r.toggle Toggles right drawer controller.
 @param drawerController.enable.open Enables opening left and right drawer controllers.
 @param drawerController.disable.open Disables opening left and right drawer controllers.
 @param drawerController.enable.close Enables closing left and right drawer controllers.
 @param drawerController.disable.close Disables closing left and right drawer controllers.
 @param drawerController.enable.openClose Enables opening and closing left and right drawer controllers.
 @param drawerController.disable.openClose Disables opening and closing left and right drawer controllers.
 @param push.auth.request Request authorization for push notifications
 @param mic.auth.request Request authorization for access to device microphone
 @param location.auth.request Request authorization for access to device location
 @param location.beginTracking Begin location tracking
 @param location.endTracking End location tracking
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** AppManager returns the following values:
 
 @param model Returns device model<br><pre>string</pre>
 @param type Returns device type<br><pre>string</pre>
 @param screen.w Returns device screen width<br><pre>float</pre>
 @param screen.h Returns device screen height<br><pre>float</pre>
 @param screen.scale Returns device screen scale<br><pre>float</pre>
 @param osVersion Returns device OS version<br><pre>string</pre>
 @param osVersion.integer Returns device OS version integer<br><pre>string</pre>
 @param osVersion.major Returns device OS version major<br><pre>string</pre>
 
 */

-(void)Returns
{
}
/***************************************************************/


@end