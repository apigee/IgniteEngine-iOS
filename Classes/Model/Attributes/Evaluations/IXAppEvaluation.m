//
//  IXAppVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
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

#import "IXAppEvaluation.h"

#import "IXAppManager.h"
#import "IXAttributeContainer.h"
#import "NSString+IXAdditions.h"

#import "ApigeeDataClient.h"

IX_STATIC_CONST_STRING kIXPushToken = @"pushToken";
IX_STATIC_CONST_STRING kIXApigeeDeviceUUID = @"apigee.deviceUuid";
IX_STATIC_CONST_STRING kIXBundleVersion = @"bundleVersion";
IX_STATIC_CONST_STRING kIXIsAllowedPush = @"isAllowed.push";
IX_STATIC_CONST_STRING kIXIsAllowedLocation = @"isAllowed.location";
IX_STATIC_CONST_STRING kIXIsAllowedMicrophone = @"isAllowed.microphone";

@implementation IXAppEvaluation

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    NSString* methodName = [self methodName];
    if( [methodName length] > 0 )
    {
        if( [methodName isEqualToString:kIXPushToken] )
        {
            returnValue = [[IXAppManager sharedAppManager] pushToken];
        }
        else if( [methodName isEqualToString:kIXApigeeDeviceUUID] )
        {
            returnValue = [ApigeeDataClient getUniqueDeviceID];
        }
        else if( [methodName isEqualToString:kIXBundleVersion])
        {
            returnValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        }
        else if( [methodName isEqualToString:kIXIsAllowedPush] )
        {
            returnValue = [NSString ix_stringFromBOOL:[[IXAppManager sharedAppManager] accessToPushGranted]];
        }
        else if( [methodName isEqualToString:kIXIsAllowedLocation] )
        {
            returnValue = [NSString ix_stringFromBOOL:[[IXAppManager sharedAppManager] accessToLocationGranted]];
        }
        else if( [methodName isEqualToString:kIXIsAllowedMicrophone] )
        {
            returnValue = [NSString ix_stringFromBOOL:[[IXAppManager sharedAppManager] accessToMicrophoneGranted]];
        }
        else
        {
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringValueForAttribute:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
