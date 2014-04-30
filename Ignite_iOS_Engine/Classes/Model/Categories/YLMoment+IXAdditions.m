//
//  YLMoment+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 4/1/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "YLMoment+IXAdditions.h"

@implementation YLMoment (IXAdditions)

+(CGFloat)momentToUnix:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970];
}

+(CGFloat)momentToJS:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970] * 1000;
}

+(YLMoment*)momentFromUnix:(NSString*)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:[date longLongValue]]];
}

+(YLMoment*)momentFromJS:(NSString*)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:[date longLongValue] / 1000]];
}

@end
