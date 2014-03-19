//
//  IXDeviceShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXDeviceShortCode.h"

#import "IXConstants.h"

#import "IXDeviceHardware.h"
#import "IXAppManager.h"
#import "IXProperty.h"

// Other properties : "orientation"
static NSString* const kIXModel = @"model";
static NSString* const kIXType = @"type";

static NSString* const kIXScreenPrefix = @"screen.";
static NSString* const kIXScreenWidthSuffix = @"width";
static NSString* const kIXScreenHeightSuffix = @"height";
static NSString* const kIXScreenScaleFactorSuffix = @"scale";

static NSString* const kIXOSPrefix = @"os.";
static NSString* const kIXOSVersionSuffix = @"version";
static NSString* const kIXOSVersionIntegerSuffix = @"version.integer";
static NSString* const kIXOSVersionMajorSuffix = @"version.major";

static NSString* sIXDeviceModelString = nil;

@implementation IXDeviceShortCode

-(NSString *)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        propertyName = [parameterProperty getPropertyValue];
    }
    
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
    else if ([propertyName isEqualToString:kIX_ORIENTATION])
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
            returnValue = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:kIX_PERIOD_SEPERATOR
                                                                                              withString:kIX_EMPTY_STRING];
        }
        else if ([propertyName hasSuffix:kIXOSVersionMajorSuffix])
        {
            returnValue = [[[UIDevice currentDevice] systemVersion] substringToIndex:1];
        }
    }
    return returnValue;
}

@end
