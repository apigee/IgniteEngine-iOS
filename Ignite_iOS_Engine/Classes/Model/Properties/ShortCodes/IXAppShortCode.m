//
//  IXAppShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppShortCode.h"

#import "IXProperty.h"
#import "IXBaseObject.h"
#import "IXAppManager.h"

#import "YLMoment.h"
#import "ApigeeDataClient.h"

#import "NSString+IXAdditions.h"

static NSString* const kIXPushToken = @"push_token";
static NSString* const kIXApigeeDeviceUUID = @"apigee.device.uuid";
static NSString* const kIXRandomNumber = @"random_number"; //usage: [[app:random_number(40)]]
static NSString* const kIXDestroySessionAttributes = @"session.destroy";
static NSString* const kIXNow = @"now";

static IXBaseShortCodeFunction const kIXRandomNumberFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    if (parameters.count > 1)
    {
        NSUInteger lowerBound = [[[parameters firstObject] getPropertyValue] integerValue];
        NSUInteger upperBound = [[[parameters objectAtIndex:1] getPropertyValue] integerValue];
        return [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)upperBound) + lowerBound];
    }
    else if (parameters.count == 1)
    {   
        NSUInteger upperBound = [[[parameters firstObject] getPropertyValue] integerValue];
        return [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)upperBound)];
    }
    else
        return 0;
};
static IXBaseShortCodeFunction const kIXDestroySessionAttributesFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    [[[IXAppManager sharedAppManager] sessionProperties] removeAllProperties];
    [[IXAppManager sharedAppManager] storeSessionProperties];
    return nil;
};

static IXBaseShortCodeFunction const kIXNowFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    YLMoment* moment = [YLMoment now];
    if (parameters.count == 1)
    {
        return [NSString ix_formatDateString:[moment format] fromDateFormat:nil toDateFormat:[[parameters objectAtIndex:0] originalString]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@", [moment format]];
    }
};

@implementation IXAppShortCode

-(void)setFunctionName:(NSString *)functionName
{
    [super setFunctionName:functionName];
    IXBaseShortCodeFunction shortCodeFunction = nil;
    if( [functionName length] > 0 )
    {
        if( [functionName isEqualToString:kIXRandomNumber] ){
            shortCodeFunction = kIXRandomNumberFunction;
        }
        else if( [functionName isEqualToString:kIXNow] ){
            shortCodeFunction = kIXNowFunction;
        }
        else if( [functionName isEqualToString:kIXDestroySessionAttributes] ){
            shortCodeFunction = kIXDestroySessionAttributesFunction;
        }
    }
    [self setShortCodeFunction:shortCodeFunction];
}

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
