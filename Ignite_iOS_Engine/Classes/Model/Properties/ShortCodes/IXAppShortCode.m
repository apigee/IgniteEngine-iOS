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

#import "ApigeeDataClient.h"

IX_STATIC_CONST_STRING kIXPushToken = @"push_token";
IX_STATIC_CONST_STRING kIXApigeeDeviceUUID = @"apigee.device.uuid";
IX_STATIC_CONST_STRING kIXBundleVersion = @"bundle.version";

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
        else
        {
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
