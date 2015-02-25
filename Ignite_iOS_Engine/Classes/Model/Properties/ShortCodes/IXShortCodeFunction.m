//
//  IXShortCodeFunction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/30/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Shortcodes are awesome.
 
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Shortcodes</a>
 
 | Name            | Format                                  | Description                                                                      |
 |-----------------|-----------------------------------------|----------------------------------------------------------------------------------|
 | capitalize      | [[?:capitalize]]                        | String value Capitalized                                                         |
 | currency        | [[?:currency(GBP)]]                     | String value in currency form (Defaults to USD, can specify ISO 4217 Alpha Code) |
 | distance        | [[app:distance(lat1:long1,lat2:long2)]] | Distance from lat1,long1 to lat2,long2.                                          |
 | session.destroy | [[app:session.destroy]]                 | Removes all session attributes from memory. Returns nil.                         |
 | from_base64     | [[?:from_base64]]                       | Base64 value to string                                                           |
 | is_empty        | [[?:is_empty]]                          | True if the string is empty (aka "")                                             |
 | is_nil          | [[?:is_nil]]                            | True if the string is nil                                                        |
 | is_nil_or_empty | [[?:is_nil_or_empty]]                   | True if the string is empty or nil                                               |
 | is_not_empty    | [[?:is_not_empty]]                      | True if the string is not empty                                                  |
 | is_not_nil      | [[?:is_not_nil]]                        | True if the string is not nil                                                    |
 | length          | [[?:length]]                            | Length of the attributes string                                                  |
 | moment          | [[?:moment(toDateFormat)]]              | String as date with the given format (can have 2 params)                         |
 | monogram        | [[?:monogram]]                          | String monogram value                                                            |
 | now             | [[app:now]]                             | Current date as string (can specify dateFormat)                                  |
 | random_number   | [[app:random_number(upBounds)]]         | Random number generator (can specify lower bounds)                               |
 | to_base64       | [[?:to_base64]]                         | String to Base64 value                                                           |
 | to_md5          | [[?:to_md5]]                            | String to MD5 hashed value                                                       |
 | to_uppercase    | [[?:to_uppercase]]                      | String value in UPPERCASE                                                        |
 | to_lowercase    | [[?:to_lowercase]]                      | String value in lowercase                                                        |
 | url_encode      | [[?:url_encode]]                        | URL encode string                                                                |
 | truncate        | [[?:truncate(toIndex)]]                 | Trucates the string to specified index                                           |
 
 
 
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXShortCodeFunction.h"

@import CoreLocation;
@import MapKit;

#import "IXAppManager.h"
#import "IXConstants.h"
#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "YLMoment.h"

#import "NSString+IXAdditions.h"
#import "ColorUtils.h"

// NOTE: Please add function name here in alphabetical order as well as adding the function block below in the same order.
// Also to enable use of the function, ensure you have also set the function in the shortCodeFunctionWithName in the load method.

//                      FUNCTION NAME                                   USAGE                                   RETURN VALUE/NOTES
//                                                               (? means any attribute)

IX_STATIC_CONST_STRING kIXCapitalize = @"capitalize";               // [[?:capitalize]]                         -> String value Capitalized
IX_STATIC_CONST_STRING kIXCurrency = @"currency";                   // [[?:currency(GBP)]]                      -> String value in currency form (*USD*, or specify ISO 4217)
IX_STATIC_CONST_STRING kIXDistance = @"distance";                   // [[app:distance(lat1:long1,lat2:long2)]]  -> Distance from lat1,long1 to lat2,long2.
IX_STATIC_CONST_STRING kIXDestroySession = @"session.destroy";      // [[app:session.destroy]]                  -> Removes all session attributes from memory. Returns nil.
IX_STATIC_CONST_STRING kIXToBase64 = @"base64.encode";              // [[?:to_base64]]                          -> String to Base64 value
IX_STATIC_CONST_STRING kIXFromBase64 = @"base64.decode";            // [[?:from_base64]]                        -> Base64 value to string
IX_STATIC_CONST_STRING kIXIsEmpty = @"isEmpty";                     // [[?:is_empty]]                           -> True if the string is empty (aka "")
IX_STATIC_CONST_STRING kIXIsNil = @"isNil";                         // [[?:is_nil]]                             -> True if the string is nil
IX_STATIC_CONST_STRING kIXIsNilOrEmpty = @"isNilOrEmpty";           // [[?:is_nil_or_empty]]                    -> True if the string is empty or nil
IX_STATIC_CONST_STRING kIXIsNotEmpty = @"isNotEmpty";               // [[?:is_not_empty]]                       -> True if the string is not empty
IX_STATIC_CONST_STRING kIXIsNotNil = @"isNotNil";                   // [[?:is_not_nil]]                         -> True if the string is not nil
IX_STATIC_CONST_STRING kIXLength = @"length";                       // [[?:length]]                             -> Length of the attributes string
IX_STATIC_CONST_STRING kIXMoment = @"moment";                       // [[?:moment(toDateFormat)]]               -> String as date with the given format (can have 2 params)
IX_STATIC_CONST_STRING kIXMonogram = @"monogram";                   // [[?:monogram]]                           -> String monogram value
IX_STATIC_CONST_STRING kIXNow = @"now";                             // [[app:now]]                              -> Current date as string (can specify dateFormat)
IX_STATIC_CONST_STRING kIXRandomNumber = @"randomNumber";           // [[app:random_number(upBounds)]]          -> Random number generator (can specify lower bounds)
IX_STATIC_CONST_STRING kIXToHex = @"hex";                           // [[?:hex]]                                -> String value of RGB ?,?,?,? in hex value.  Last value can be used for alpha otherwise it is 1.0f.
IX_STATIC_CONST_STRING kIXToRGB = @"rgb";                           // [[?:rgb]]                                -> String value of hex string to RGB.
IX_STATIC_CONST_STRING kIXToMD5 = @"md5.encode";                    // [[?:to_md5]]                             -> String to MD5 hashed value
IX_STATIC_CONST_STRING kIXToUppercase = @"uppercase";               // [[?:to_uppercase]]                       -> String value in UPPERCASE
IX_STATIC_CONST_STRING kIXToLowercase = @"lowercase";               // [[?:to_lowercase]]                       -> String value in lowercase
IX_STATIC_CONST_STRING kIXURLEncode = @"url.encode";                // [[?:url_encode]]                         -> URL encode string
IX_STATIC_CONST_STRING kIXURLDecode = @"url.decode";                // [[?:url_decode]]                         -> URL decode string
IX_STATIC_CONST_STRING kIXTruncate = @"truncate";                   // [[?:truncate(toIndex)]]                  -> Trucates the string to specified index

static IXBaseShortCodeFunction const kIXCapitalizeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify capitalizedString];
};

static IXBaseShortCodeFunction const kIXCurrencyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters)
{
    static NSNumberFormatter *currencyFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    
    NSDecimalNumber* amount = [NSDecimalNumber zero];
    
    if( [stringToModify length] > 0 )
    {
        amount = [[NSDecimalNumber alloc] initWithString:stringToModify];
        // default to USD formatting
        [currencyFormatter setCurrencyCode:@"USD"];
        
        if( [parameters firstObject] != nil )
        {
            NSString* currencyCode = [[parameters firstObject] getPropertyValue];
            [currencyFormatter setCurrencyCode:currencyCode];
            
            // check to see if we should use alternate currency formatting
            if (
                [currencyCode  isEqual: @"ARS"] ||
                [currencyCode  isEqual: @"BRL"] ||
                [currencyCode  isEqual: @"COP"] ||
                [currencyCode  isEqual: @"CLP"] ||
                [currencyCode  isEqual: @"CRC"] ||
                [currencyCode  isEqual: @"HRK"] ||
                [currencyCode  isEqual: @"CYP"] ||
                [currencyCode  isEqual: @"CZK"] ||
                [currencyCode  isEqual: @"DKK"] ||
                [currencyCode  isEqual: @"HUF"] ||
                [currencyCode  isEqual: @"ISK"] ||
                [currencyCode  isEqual: @"IDR"] ||
                [currencyCode  isEqual: @"ANG"] ||
                [currencyCode  isEqual: @"NOK"] ||
                [currencyCode  isEqual: @"UYU"] ||
                [currencyCode  isEqual: @"RON"] ||
                [currencyCode  isEqual: @"ROL"] ||
                [currencyCode  isEqual: @"RUB"] ||
                [currencyCode  isEqual: @"SIT"] ||
                [currencyCode  isEqual: @"SEK"] ||
                [currencyCode  isEqual: @"VEF"] ||
                [currencyCode  isEqual: @"VND"]
                )
            {
                [currencyFormatter setCurrencyDecimalSeparator:@","];
                [currencyFormatter setCurrencyGroupingSeparator:@"."];
            }
        }
    }
    
    return [currencyFormatter stringFromNumber:amount];
    
};

static IXBaseShortCodeFunction const kIXDistanceFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    NSString* returnString = nil;
    if( [parameters count] > 1 )
    {
        NSString* latLong1 = [[parameters firstObject] getPropertyValue];
        NSString* latLong2 = [[parameters lastObject] getPropertyValue];
        
        NSArray* latLong1Seperated = [latLong1 componentsSeparatedByString:@":"];
        NSArray* latLong2Seperated = [latLong2 componentsSeparatedByString:@":"];
        
        CLLocation *point1 = [[CLLocation alloc] initWithLatitude:[[latLong1Seperated firstObject] floatValue]
                                                        longitude:[[latLong1Seperated lastObject] floatValue]];
        
        CLLocation *point2 = [[CLLocation alloc] initWithLatitude:[[latLong2Seperated firstObject] floatValue]
                                                        longitude:[[latLong2Seperated lastObject] floatValue]];
        
        MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
        formatter.units = MKDistanceFormatterUnitsDefault;
        returnString = [formatter stringFromDistance:[point1 distanceFromLocation:point2]];
    }
    return returnString;
};

static IXBaseShortCodeFunction const kIXDestroySessionFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    [[[IXAppManager sharedAppManager] sessionProperties] removeAllProperties];
    [[IXAppManager sharedAppManager] storeSessionProperties];
    return nil;
};

static IXBaseShortCodeFunction const kIXFromBase64Function = ^NSString*(NSString* stringToDecode,NSArray* parameters){
    return [NSString ix_fromBase64String:stringToDecode];
};

static IXBaseShortCodeFunction const kIXIsEmptyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:[stringToModify isEqualToString:kIX_EMPTY_STRING]];
};

static IXBaseShortCodeFunction const kIXIsNilFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:(stringToModify == nil)];
};

static IXBaseShortCodeFunction const kIXIsNilOrEmptyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:([stringToModify length] <= 0)];
};

static IXBaseShortCodeFunction const kIXIsNotEmptyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:([stringToModify length] > 0)];
};

static IXBaseShortCodeFunction const kIXIsNotNilFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:(stringToModify != nil)];
};

static IXBaseShortCodeFunction const kIXLengthFunction = ^NSString*(NSString* stringToEvaluate,NSArray* parameters){
    return [NSString stringWithFormat:@"%lu", (unsigned long)[stringToEvaluate length]];
};

static IXBaseShortCodeFunction const kIXMomentFunction = ^NSString*(NSString* dateToFormat,NSArray* parameters)
{
    if ([parameters count] > 1) {
        return [NSString ix_formatDateString:dateToFormat fromDateFormat:[[parameters firstObject] originalString] toDateFormat:[[parameters lastObject] originalString]];
    } else if ([parameters count] == 1) {
        return [NSString ix_formatDateString:dateToFormat fromDateFormat:nil toDateFormat:[[parameters firstObject] originalString]];
    } else {
        return dateToFormat;
    }
};

static IXBaseShortCodeFunction const kIXMonogramFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return ([parameters firstObject] != nil) ? [NSString ix_monogramString:stringToModify ifLengthIsGreaterThan:[[parameters.firstObject getPropertyValue] intValue]] : [NSString ix_monogramString:stringToModify ifLengthIsGreaterThan:0];
};

static IXBaseShortCodeFunction const kIXNowFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    YLMoment* moment = [YLMoment now];
    if ([parameters count] == 1) {
        return [NSString ix_formatDateString:[moment format] fromDateFormat:nil toDateFormat:[[parameters firstObject] originalString]];
    } else {
        return [moment format];
    }
};

static IXBaseShortCodeFunction const kIXRandomNumberFunction = ^NSString*(NSString* unusedStringProperty,NSArray* parameters){
    if ([parameters count] > 1) {
        NSUInteger lowerBound = [[[parameters firstObject] getPropertyValue] integerValue];
        NSUInteger upperBound = [[[parameters lastObject] getPropertyValue] integerValue];
        return [NSString stringWithFormat:@"%lu",arc4random_uniform((u_int32_t)upperBound) + lowerBound];
    } else if ([parameters count] == 1) {
        return [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)[[[parameters firstObject] getPropertyValue] integerValue])];
    }
    else {
        return @"0";
    }
};

static IXBaseShortCodeFunction const kIXToBase64Function = ^NSString*(NSString* stringToEncode,NSArray* parameters){
    if (stringToEncode)
        return [NSString ix_toBase64String:stringToEncode];
    else
        return stringToEncode;
};

static IXBaseShortCodeFunction const kIXToHexFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    NSString* hexString = nil;
    NSArray* rgbArray = [stringToModify componentsSeparatedByString:kIX_COMMA_SEPERATOR];
    if( [rgbArray count] > 2 )
    {
        float red = [[rgbArray firstObject] floatValue] / 255;
        float green = [[rgbArray objectAtIndex:1] floatValue] / 255;
        float blue = [[rgbArray objectAtIndex:2] floatValue] / 255;
        float alpha = 1.0f;
        if( [rgbArray count] > 3 )
        {
            alpha = [[rgbArray lastObject] floatValue];
        }

        UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        if (color.alpha < 1.0f)
        {
            hexString = [NSString stringWithFormat:@"#%.8x", color.RGBAValue];
        }
        else
        {
            hexString = [NSString stringWithFormat:@"#%.6x", color.RGBValue];
        }
    }
    return hexString;
};

static IXBaseShortCodeFunction const kIXToMD5Function = ^NSString*(NSString* stringToHash,NSArray* parameters){
    if (stringToHash)
        return [NSString ix_toMD5String:stringToHash];
    else
        return stringToHash;
};

static IXBaseShortCodeFunction const kIXToLowerCaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify lowercaseString];
};

static IXBaseShortCodeFunction const kIXToUppercaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify uppercaseString];
};

static IXBaseShortCodeFunction const kIXToRGBFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    NSString* rgbString = nil;
    if( [stringToModify length] > 0 )
    {
        UIColor* color = [UIColor colorWithString:stringToModify];
        rgbString = [NSString stringWithFormat:@"%0.0f,%0.0f,%0.0f",color.red*255,color.green*255,color.blue*255];
        if (color.alpha < 1.0f)
        {
            rgbString = [NSString stringWithFormat:@"%@,%0.0f",rgbString,color.alpha];
        }
    }
    return rgbString;
};

static IXBaseShortCodeFunction const kIXURLEncodeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    //return [stringToModify uppercaseString];
    return [stringToModify stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
};

static IXBaseShortCodeFunction const kIXURLDecodeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    //TODO: URL Decoded;
    return [stringToModify stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
};


static IXBaseShortCodeFunction const kIXTruncateFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return ([parameters firstObject] != nil) ? [NSString ix_truncateString:stringToModify toIndex:[[[parameters firstObject] getPropertyValue] intValue]] : stringToModify;
};

@implementation IXShortCodeFunction

+(IXBaseShortCodeFunction)shortCodeFunctionWithName:(NSString*)functionName
{
    static NSDictionary* sIXFunctionDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIXFunctionDictionary = @{  kIXCapitalize:        [kIXCapitalizeFunction copy],
                                    kIXCurrency:          [kIXCurrencyFunction copy],
                                    kIXDestroySession:    [kIXDestroySessionFunction copy],
                                    kIXDistance:          [kIXDistanceFunction copy],
                                    kIXFromBase64:        [kIXFromBase64Function copy],
                                    kIXIsEmpty:           [kIXIsEmptyFunction copy],
                                    kIXIsNil:             [kIXIsNilFunction copy],
                                    kIXIsNilOrEmpty:      [kIXIsNilOrEmptyFunction copy],
                                    kIXIsNotEmpty:        [kIXIsNotEmptyFunction copy],
                                    kIXIsNotNil:          [kIXIsNotNilFunction copy],
                                    kIXLength:            [kIXLengthFunction copy],
                                    kIXMoment:            [kIXMomentFunction copy],
                                    kIXMonogram:          [kIXMonogramFunction copy],
                                    kIXNow:               [kIXNowFunction copy],
                                    kIXRandomNumber:      [kIXRandomNumberFunction copy],
                                    kIXToBase64:          [kIXToBase64Function copy],
                                    kIXToHex:             [kIXToHexFunction copy],
                                    kIXToMD5:             [kIXToMD5Function copy],
                                    kIXToLowercase:       [kIXToLowerCaseFunction copy],
                                    kIXToRGB:             [kIXToRGBFunction copy],
                                    kIXToUppercase:       [kIXToUppercaseFunction copy],
                                    kIXURLEncode:         [kIXURLEncodeFunction copy],
                                    kIXURLDecode:         [kIXURLDecodeFunction copy],
                                    kIXTruncate:          [kIXTruncateFunction copy]};
    });
    
    return [sIXFunctionDictionary[functionName] copy];
}

@end