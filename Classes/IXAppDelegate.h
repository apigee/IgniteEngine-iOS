//
//  IXAppDelegate.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXWindow;

@interface IXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IXWindow *ixWindow;

- (void)registerForPushNotifications;

@end
