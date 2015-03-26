//
//  IXDeviceHardware.h
//  Ignite Engine
//
//  Created by Brandon on 2/28/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//  Derived from http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

#import <Foundation/Foundation.h>

@interface IXDeviceInfo : NSObject

+ (NSString *) deviceModel;
+ (NSString *) deviceType;
+ (NSString *) interfaceOrientation;
+ (NSString *) screenHeight;
+ (NSString *) screenWidth;
+ (NSString *) screenScale;
+ (NSString *) osVersion;
+ (NSString *) osVersionAsInteger;
+ (NSString *) osMajorVersion;


@end
