//
//  IXDeviceEvaluation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 3/11/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXDeviceEvaluation.h"
#import "IXConstants.h"
#import "IXDeviceInfo.h"
#import "IXAttribute.h"
#import "IXBaseObject.h"
#import "IXAppManager.h"
#import "IXLocationManager.h"
#import "NSString+IXAdditions.h"

// Other properties : "orientation"
IX_STATIC_CONST_STRING kIXModel = @"model";
IX_STATIC_CONST_STRING kIXType = @"type";

IX_STATIC_CONST_STRING kIXScreenWidth = @"screen.w";
IX_STATIC_CONST_STRING kIXScreenHeight = @"screen.h";
IX_STATIC_CONST_STRING kIXScreenScaleFactor = @"screen.scale";

IX_STATIC_CONST_STRING kIXOSVersion = @"osVersion";
IX_STATIC_CONST_STRING kIXOSVersionInteger = @"osVersion.integer";
IX_STATIC_CONST_STRING kIXOSVersionMajor = @"osVersion.major";

IX_STATIC_CONST_STRING kIXLocation = @"location"; // Return format: lat:long
IX_STATIC_CONST_STRING kIXLocationLat = @"location.lat";
IX_STATIC_CONST_STRING kIXLocationLong = @"location.long";

@implementation IXDeviceEvaluation

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
        else if( [methodName hasPrefix:kIXLocation] )
        {
            if( [methodName isEqualToString:kIXLocationLat] )
            {
                returnValue = [NSString ix_stringFromFloat:[[[IXLocationManager sharedLocationManager] lastKnownLocation] coordinate].latitude];
            }
            else if( [methodName isEqualToString:kIXLocationLong] )
            {
                returnValue = [NSString ix_stringFromFloat:[[[IXLocationManager sharedLocationManager] lastKnownLocation] coordinate].longitude];
            }
            else if( [methodName isEqualToString:kIXLocation] )
            {
                NSString* latitude = [NSString ix_stringFromFloat:[[[IXLocationManager sharedLocationManager] lastKnownLocation] coordinate].latitude];
                NSString* longitude = [NSString ix_stringFromFloat:[[[IXLocationManager sharedLocationManager] lastKnownLocation] coordinate].longitude];
                returnValue = [NSString stringWithFormat:@"%@:%@",latitude,longitude];
            }
        }
        else if( [methodName length] > 0 )
        {
            returnValue = [[[IXAppManager sharedAppManager] deviceProperties] getStringAttributeValue:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
