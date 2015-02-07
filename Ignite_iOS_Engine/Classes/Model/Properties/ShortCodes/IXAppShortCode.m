//
//  IXAppShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppShortCode.h"

#import "IXAppManager.h"
#import "IXPropertyContainer.h"
#import "NSString+IXAdditions.h"

#import "ApigeeDataClient.h"

IX_STATIC_CONST_STRING kIXPushToken = @"pushToken";
IX_STATIC_CONST_STRING kIXApigeeDeviceUUID = @"apigeeDeviceUuid";
IX_STATIC_CONST_STRING kIXBundleVersion = @"bundleVersion";
IX_STATIC_CONST_STRING kIXIsAllowedPush = @"isAllowed.push";
IX_STATIC_CONST_STRING kIXIsAllowedLocation = @"isAllowed.location";
IX_STATIC_CONST_STRING kIXIsAllowedMicrophone = @"isAllowed.microphone";

@implementation IXAppShortCode

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
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
