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
#import "NSString+IXAdditions.h"

static NSString* const kIXRandomNumber = @"random_number"; //usage: [[app:random_number(40)]]
static NSString* const kIXNow = @"now";

static IXBaseShortCodeFunction const kIXRandomNumberFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    NSUInteger upperBound = [[[parameters firstObject] getPropertyValue] integerValue];
    return [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)upperBound)];
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
    }
    [self setShortCodeFunction:shortCodeFunction];
}

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    NSString* methodName = [self methodName];
    if( [methodName length] > 0 )
    {
        returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:methodName defaultValue:nil];
    }
    return returnValue;
}

@end
