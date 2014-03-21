//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

#import "IXConstants.h"

static NSString* const kIXFloatFormat = @"%f";

@implementation NSString (IXAdditions)

+(NSString*)ix_stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? kIX_TRUE : kIX_FALSE;
}

+(NSString*)ix_stringFromFloat:(float)floatValue
{
    return [NSString stringWithFormat:kIXFloatFormat,floatValue];
}

+(NSString*)ix_truncateString:(NSString*)string toIndex:(NSInteger)index
{
    if (index > 0 && string.length > index)
        return [NSString stringWithFormat:@"%@...", [string substringToIndex:MIN(index, string.length)]];
    else
        return string;
}

@end
