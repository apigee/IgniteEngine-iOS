//
//  IXDeviceHardware.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 2/28/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//  Used to determine EXACT version of device software is running on.

#import "IXDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import "IXAppManager.h"

static NSString* const kIXModel = @"model";
static NSString* const kIXType = @"type";
static NSString* const kIXOrientation = @"orientation";

static NSString* const kIXScreenPrefix = @"screen.";
static NSString* const kIXScreenWidthSuffix = @"width";
static NSString* const kIXScreenHeightSuffix = @"height";
static NSString* const kIXScreenScaleFactorSuffix = @"scale";

static NSString* const kIXOSPrefix = @"os.";
static NSString* const kIXOSVersionSuffix = @"version";
static NSString* const kIXOSVersionIntegerSuffix = @"version.integer";
static NSString* const kIXOSVersionMajorSuffix = @"version.major";

static NSString* sIXDeviceModelString = nil;

@implementation IXDeviceHardware

+ (NSString *) getDevicePropertyNamed:(NSString*)propertyName
{
    NSString* returnValue = nil;
    if ([propertyName isEqualToString:kIXModel])
    {
        if( sIXDeviceModelString == nil )
        {
            sIXDeviceModelString = [IXDeviceHardware modelString];
        }
        returnValue = [sIXDeviceModelString copy];
    }
    else if ([propertyName isEqualToString:kIXType])
    {
        //potential return values: iPod touch, iPhone, iPhone Simulator, iPad, iPad Simulator
        returnValue = [[UIDevice currentDevice] model];
    }
    else if ([propertyName isEqualToString:kIXOrientation])
    {
        switch ([IXAppManager currentInterfaceOrientation])
        {
            case UIInterfaceOrientationPortrait:
                returnValue = @"Portrait";
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                returnValue = @"Portrait-UpsideDown";
                break;
            case UIInterfaceOrientationLandscapeRight:
                returnValue = @"Landscape-Right";
                break;
            case UIInterfaceOrientationLandscapeLeft:
                returnValue = @"Landscape-Left";
                break;
        }
    }
    else if ([propertyName hasPrefix:kIXScreenPrefix] )
    {
        if( [propertyName hasSuffix:kIXScreenWidthSuffix] )
        {
            returnValue = [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.width];
        }
        else if( [propertyName hasSuffix:kIXScreenHeightSuffix] )
        {
            returnValue = [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.height];
        }
        else if( [propertyName hasSuffix:kIXScreenScaleFactorSuffix] )
        {
            returnValue = [NSString stringWithFormat:@"%.1f", [[UIScreen mainScreen] scale]];
        }
    }
    else if( [propertyName hasPrefix:kIXOSPrefix] )
    {
        if ([propertyName hasSuffix:kIXOSVersionSuffix])
        {
            returnValue = [[UIDevice currentDevice] systemVersion];
        }
        else if ([propertyName hasSuffix:kIXOSVersionIntegerSuffix])
        {
            returnValue = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@""];
        }
        else if ([propertyName hasSuffix:kIXOSVersionMajorSuffix])
        {
            returnValue = [[[UIDevice currentDevice] systemVersion] substringToIndex:1];
        }
    }
    return returnValue;
}

+ (NSString *) model{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *model = [NSString stringWithUTF8String:machine];
    free(machine);
    return model;
}

+ (NSString *) modelString{
    NSString *model = [IXDeviceHardware model];
    if ([model isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([model isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([model isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([model isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([model isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([model isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([model isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([model isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([model isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([model isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([model isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([model isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([model isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([model isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([model isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([model isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([model isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([model isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([model isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([model isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([model isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([model isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([model isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([model isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([model isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([model isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([model isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([model isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([model isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([model isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([model isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([model isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([model isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([model isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([model isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([model isEqualToString:@"i386"])         return @"Simulator";
    if ([model isEqualToString:@"x86_64"])       return @"Simulator";
    return model;
}

@end
