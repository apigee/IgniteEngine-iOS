//
//  IXDeviceVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 3/11/14.
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

IX_STATIC_CONST_STRING kIXOSVersion = @"os.version";
IX_STATIC_CONST_STRING kIXOSVersionInteger = @"os.version.integer";
IX_STATIC_CONST_STRING kIXOSVersionMajor = @"os.version.major";
IX_STATIC_CONST_STRING kIXOSName = @"os.name";

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
        if ([methodName isEqualToString:kIXOSName])
        {
            return @"ios";
        }
        else if ([methodName isEqualToString:kIX_ORIENTATION])
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
            returnValue = [[[IXAppManager sharedAppManager] deviceProperties] getStringValueForAttribute:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
