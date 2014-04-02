//
//  YLMoment+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 4/1/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "YLMoment.h"

@interface YLMoment (IXAdditions)

+(NSInteger)momentToUnix:(YLMoment*)moment;
+(NSInteger)momentToJS:(YLMoment*)moment;
+(YLMoment*)momentFromUnix:(NSInteger)date;
+(YLMoment*)momentFromJS:(NSInteger)date;

@end
