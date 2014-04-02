//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

#import "IXConstants.h"
#import "YLMoment.h"
#import "YLMoment+IXAdditions.h"


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

+(NSString*)ix_monogramString:(NSString *)string ifLengthIsGreaterThan:(NSInteger)length
{
    if (string.length > 0)
    {
        if (length > 0 && string.length > length)
            return [NSString stringWithFormat:@"%@.", [string substringToIndex:1]];
        else if (length == 0)
            return [NSString stringWithFormat:@"%@.", [string substringToIndex:1]];
        else
            return string;
    }
    else
        return string;
}

+(NSString*)ix_toBase64String:(NSString *)string
{
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        NSData *utf8data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [utf8data base64EncodedStringWithOptions:0];
        return base64String;
    }
    else
    {
        //todo: need a fall back for < iOS7
        return string;
    }
}

+(NSString*)ix_fromBase64String:(NSString *)string
{
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        return decodedString;
    }
    else
    {
        //todo: need a fall back for < iOS7
        return string;
    }
}

+(NSString*)ix_formatDateString:(NSString *)string fromDateFormat:(NSString*)fromDateFormat toDateFormat:(NSString*)toDateFormat
{
    if (string.length > 0 && toDateFormat.length > 0)
    {
        YLMoment* moment;
        if (fromDateFormat != nil && fromDateFormat.length > 0)
        {
            if ([fromDateFormat isEqualToString:@"unix"])
                moment = [YLMoment momentFromUnix:string];
            else if ([fromDateFormat isEqualToString:@"js"])
                moment = [YLMoment momentFromJS:string];
            else
                moment = [YLMoment momentWithDateAsString:string format:fromDateFormat];
        }
        else
        {
            moment = [YLMoment momentWithDateAsString:string format:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        }
        
        if ([toDateFormat isEqualToString:@"unix"])
        {
            return [NSString stringWithFormat:@"%0.f", [YLMoment momentToUnix:moment]];
        }
        else if ([toDateFormat isEqualToString:@"js"])
        {
            return [NSString stringWithFormat:@"%0.f", [YLMoment momentToJS:moment]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@", [moment format:toDateFormat]];
        }
    }
    else
        return string;
}

-(BOOL)containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options
{
    return [self rangeOfString:substring options:options].location != NSNotFound;
}

@end
