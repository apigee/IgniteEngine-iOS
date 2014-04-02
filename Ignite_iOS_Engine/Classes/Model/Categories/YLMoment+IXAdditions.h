//
//  YLMoment+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 4/1/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "YLMoment.h"

@interface YLMoment (IXAdditions)

+(CGFloat)momentToUnix:(YLMoment*)moment;
+(CGFloat)momentToJS:(YLMoment*)moment;
+(YLMoment*)momentFromUnix:(NSString*)date;
+(YLMoment*)momentFromJS:(NSString*)date;

@end
