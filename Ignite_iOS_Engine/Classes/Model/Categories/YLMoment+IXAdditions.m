//
//  YLMoment+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 4/1/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "YLMoment+IXAdditions.h"

@implementation YLMoment (IXAdditions)

+(NSInteger)momentToUnix:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970];
}

+(NSInteger)momentToJS:(YLMoment*)moment
{
    return [moment.date timeIntervalSince1970] * 1000;
}

+(YLMoment*)momentFromUnix:(NSInteger)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:date]];
}

+(YLMoment*)momentFromJS:(NSInteger)date
{
    return [YLMoment momentWithDate:[NSDate dateWithTimeIntervalSince1970:date / 1000]];
}

@end
