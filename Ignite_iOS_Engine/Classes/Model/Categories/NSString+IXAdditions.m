//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

static NSString* const kIXYES = @"YES";
static NSString* const kIXNO = @"NO";

static NSString* const kIXFloatFormat = @"%f";

@implementation NSString (IXAdditions)

+(NSString*)stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? kIXYES : kIXNO;
}

+(NSString*)stringFromFloat:(float)floatValue
{
    return [NSString stringWithFormat:kIXFloatFormat,floatValue];
}

@end
