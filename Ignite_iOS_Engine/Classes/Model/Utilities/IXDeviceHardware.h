//
//  IXDeviceHardware.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 2/28/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//  Derived from http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

#import <Foundation/Foundation.h>

@interface IXDeviceHardware : NSObject

+ (NSString *) getDevicePropertyNamed:(NSString*)propertyName;

@end
