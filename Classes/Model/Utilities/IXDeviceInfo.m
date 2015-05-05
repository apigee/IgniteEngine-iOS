//
//  IXDeviceInfo.m
//  Ignite Engine
//
//  Created by Brandon on 2/28/14.
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
//  Used to determine EXACT version of device software is running on.

#import "IXDeviceInfo.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "IXAppManager.h"
#import "IXConstants.h"

@implementation IXDeviceInfo

+ (NSString *) verboseModel{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *model = [NSString stringWithUTF8String:machine];
    free(machine);
    return model;
}

+ (NSString *) deviceModel{
    NSString *model = [IXDeviceInfo verboseModel];
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

+(NSString *)deviceType
{
    //potential return values: iPod touch, iPhone, iPhone Simulator, iPad, iPad Simulator
    return [[UIDevice currentDevice] model];
}


+(NSString *)interfaceOrientation
{
    IX_LOG_VERBOSE(@"Call to get interface orientation");
    switch ([IXAppManager currentInterfaceOrientation])
    {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"Portrait-UpsideDown";
            break;
        case UIInterfaceOrientationLandscapeRight:
            return @"Landscape-Right";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return @"Landscape-Left";
            break;
        default:
            return @"Unknown";
            break;
    }
}

+(NSString *)screenHeight
{
    IX_LOG_VERBOSE(@"Call to get screen height");
    return [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.height];
}

+(NSString *)screenWidth
{
    IX_LOG_VERBOSE(@"Call to get screen width");
    return [NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.width];
}

+(NSString *)screenScale
{
    IX_LOG_VERBOSE(@"Call to get screen scale");
    return [NSString stringWithFormat:@"%.1f", [[UIScreen mainScreen] scale]];
}

+(NSString *)osVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+(NSString *)osVersionAsInteger
{
    NSString *ver = [[IXDeviceInfo osVersion]
            stringByReplacingOccurrencesOfString:kIX_PERIOD_SEPERATOR
            withString:kIX_EMPTY_STRING];
        
    if ([ver intValue] > 0 && [ver intValue] < 10)
        return [NSString stringWithFormat:@"%@00", ver];
    else if ([ver intValue] > 10 && [ver intValue] < 100)
        return [NSString stringWithFormat:@"%@0", ver];
    else if ([ver intValue] > 100)
        return [NSString stringWithFormat:@"%@", ver];
    else
        return ver;
}

+(NSString *)osMajorVersion
{
    return [[IXDeviceInfo osVersion] substringToIndex:1];
}



@end
