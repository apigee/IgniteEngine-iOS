//
//  IXDeviceShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXDeviceShortCode.h"
#import "IXConstants.h"
#import "IXDeviceInfo.h"
#import "IXProperty.h"
#import "IXBaseObject.h"
#import "IXAppManager.h"

// Other properties : "orientation"
static NSString* const kIXModel = @"model";
static NSString* const kIXType = @"type";

static NSString* const kIXScreenWidth = @"screen.width";
static NSString* const kIXScreenHeight = @"screen.height";
static NSString* const kIXScreenScaleFactor = @"screen.scale";

static NSString* const kIXOSVersion = @"os.version";
static NSString* const kIXOSVersionInteger = @"os.version.integer";
static NSString* const kIXOSVersionMajor = @"os.version.major";

@implementation IXDeviceShortCode

-(NSString *)evaluate
{
    NSString* returnValue = nil;
    NSString* methodName = [self methodName];
    if( [methodName length] > 0 )
    {
        if ([methodName isEqualToString:kIX_ORIENTATION])
        {
            returnValue = [IXDeviceInfo interfaceOrientation];
        }
        else if( [methodName isEqualToString:kIXScreenWidth] )
        {
            returnValue = [IXDeviceInfo screenWidth];
        }
        else if( [methodName isEqualToString:kIXScreenHeight] )
        {
            returnValue = [IXDeviceInfo screenHeight];
        }
        else if( [methodName isEqualToString:kIXOSVersion] )
        {
            returnValue = [IXDeviceInfo osVersion];
        }
        else if( [methodName isEqualToString:kIXOSVersionInteger] )
        {
            returnValue = [IXDeviceInfo osVersionAsInteger];
        }
        else if( [methodName isEqualToString:kIXOSVersionMajor] )
        {
            returnValue = [IXDeviceInfo osMajorVersion];
        }
        else if( [methodName isEqualToString:kIXModel] )
        {
            returnValue = [IXDeviceInfo deviceModel];
        }
        else if( [methodName isEqualToString:kIXType] )
        {
            returnValue = [IXDeviceInfo deviceType];
        }
        else if( [methodName length] > 0 )
        {
            returnValue = [[[IXAppManager sharedAppManager] deviceProperties] getStringPropertyValue:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
