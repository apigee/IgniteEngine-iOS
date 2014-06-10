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

static NSString* const kIXPushToken = @"push_token";
static NSString* const kIXApigeeDeviceUUID = @"apigee.device.uuid";

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
        if( [methodName isEqualToString:kIXApigeeDeviceUUID] )
        {
            returnValue = [ApigeeDataClient getUniqueDeviceID];
        }
        else
        {
            returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:methodName defaultValue:nil];
        }
    }
    return returnValue;
}

@end
