//
//  IXAppDelegate.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXWindow;

@interface IXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IXWindow *ixWindow;

- (void)registerForPushNotifications;

@end
