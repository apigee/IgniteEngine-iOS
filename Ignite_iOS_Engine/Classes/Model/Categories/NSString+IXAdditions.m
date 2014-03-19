//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

static NSString* const kIXTrue = @"true";
static NSString* const kIXFalse = @"false";
static NSString* const kIXFloatFormat = @"%f";

@implementation NSString (IXAdditions)

+(NSString*)ix_stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? kIXTrue : kIXFalse;
}

+(NSString*)ix_stringFromFloat:(float)floatValue
{
    return [NSString stringWithFormat:kIXFloatFormat,floatValue];
}

+(NSString*)ix_truncateString:(NSString*)string toIndex:(NSInteger)index
{
    if (index > 0)
        return [NSString stringWithFormat:@"%@...", [string substringToIndex:MIN(index, string.length)]];
    else
        return string;
}

@end
