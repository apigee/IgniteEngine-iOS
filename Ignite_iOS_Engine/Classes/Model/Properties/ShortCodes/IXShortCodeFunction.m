//
//  IXShortCodeFunction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

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

// NOTE: To enable use of the function, ensure you add the function block and set the function inside shortCodeFunctionWithName.

//                      FUNCTION NAME                                   USAGE                                   RETURN VALUE/NOTES
//                                                               (? means any attribute)

IX_STATIC_CONST_STRING kIXCapitalize = @"capitalize";               // [[?:capitalize]]                         -> String value Capitalized
IX_STATIC_CONST_STRING kIXCurrency = @"currency";                   // [[?:currency(GBP)]]                      -> String value in currency form (*USD*, or specify ISO 4217)
IX_STATIC_CONST_STRING kIXDistance = @"distance";                   // [[app:distance(lat1:long1,lat2:long2)]]  -> Distance from lat1,long1 to lat2,long2.
IX_STATIC_CONST_STRING kIXToBase64 = @"base64.encode";              // [[?:to_base64]]                          -> String to Base64 value
IX_STATIC_CONST_STRING kIXFromBase64 = @"base64.decode";            // [[?:from_base64]]                        -> Base64 value to string
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
IX_STATIC_CONST_STRING kIXTimeFromSeconds = @"timeFromSeconds";     // [[?:timeFromSeconds]]                    -> Trucates the string to specified index
IX_STATIC_CONST_STRING kIXTruncate = @"truncate";                   // [[?:truncate(toIndex)]]                  -> Trucates the string to specified index
IX_STATIC_CONST_STRING kIXStripHtml = @"stripHtml";
IX_STATIC_CONST_STRING kIXRadiansToDegrees = @"degreesToRadians";
IX_STATIC_CONST_STRING kIXDegreesToRadians = @"radiansToDegrees";

// "is" operation constants
IX_STATIC_CONST_STRING kIXIs = @"is";
IX_STATIC_CONST_STRING kIXEmpty = @"empty";
IX_STATIC_CONST_STRING kIXNil = @"nil";
IX_STATIC_CONST_STRING kIXNotNil = @"notNil";
IX_STATIC_CONST_STRING kIXNotEmpty = @"notEmpty";
IX_STATIC_CONST_STRING kIXNegationOperator = @"!";
IX_STATIC_CONST_STRING kIXAndOperator = @"&&";
IX_STATIC_CONST_STRING kIXOrOperator = @"||";

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)

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

static IXBaseShortCodeFunction const kIXFromBase64Function = ^NSString*(NSString* stringToDecode,NSArray* parameters){
    return [NSString ix_fromBase64String:stringToDecode];
};

static IXBaseShortCodeFunction const kIXIsFunction = ^NSString*(NSString* inputString,NSArray* parameters){
    NSString* firstCondition = nil;
    NSString* operator = nil;
    NSString* secondCondition = nil;
    BOOL returnFirstCondition;
    BOOL returnSecondCondition;
    
    if (parameters.count == 1) {
        NSString* conditionalString = [[parameters firstObject] originalString];
        if ([conditionalString containsString:kIXAndOperator]) {
            firstCondition = [[conditionalString componentsSeparatedByString:kIXAndOperator][0] trimLeadingAndTrailingWhitespace];
            secondCondition = [[conditionalString componentsSeparatedByString:kIXAndOperator][1] trimLeadingAndTrailingWhitespace];
            operator = kIXAndOperator;
        } else if ([conditionalString containsString:kIXOrOperator]) {
            firstCondition = [[conditionalString componentsSeparatedByString:kIXOrOperator][0] trimLeadingAndTrailingWhitespace];
            secondCondition = [[conditionalString componentsSeparatedByString:kIXOrOperator][1] trimLeadingAndTrailingWhitespace];
            operator = kIXOrOperator;
        } else {
            firstCondition = conditionalString;
        }
        
        if ([firstCondition hasSuffix:kIXNil]) {
            // first condition is nil or !nil
            returnFirstCondition = ([firstCondition hasPrefix:kIXNegationOperator]) ? (inputString != nil) : (inputString == nil);
        } else if ([firstCondition hasSuffix:kIXEmpty]) {
            // first condition is empty or !empty
            returnFirstCondition = ([firstCondition hasPrefix:kIXNegationOperator]) ? ![inputString isEqualToString:kIX_EMPTY_STRING] : [inputString isEqualToString:kIX_EMPTY_STRING];
        }
        
        if (operator != nil && secondCondition != nil) {
            if ([secondCondition hasSuffix:kIXNil]) {
                // second condition is nil or !nil
                returnSecondCondition = ([secondCondition hasPrefix:kIXNegationOperator]) ? (inputString != nil) : (inputString == nil);
            } else if ([secondCondition hasSuffix:kIXEmpty]) {
                // second condition is empty or !empty
                returnSecondCondition = ([secondCondition hasPrefix:kIXNegationOperator]) ? ![inputString isEqualToString:kIX_EMPTY_STRING] : [inputString isEqualToString:kIX_EMPTY_STRING];
            }
            
        }
        
        if ([operator isEqualToString:kIXAndOperator]) {
            return [NSString ix_stringFromBOOL:(returnFirstCondition && returnSecondCondition)];
        } else if ([operator isEqualToString:kIXOrOperator]) {
            return [NSString ix_stringFromBOOL:(returnFirstCondition || returnSecondCondition)];
        } else {
            return [NSString ix_stringFromBOOL:returnFirstCondition];
        }
    } else {
        return @"error";
    }
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

static IXBaseShortCodeFunction const kIXTimeFromSecondsFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    int totalSeconds = [stringToModify intValue];;
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    NSString* returnString;
    if( hours > 0 )
    {
        returnString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        returnString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
    return returnString;
    
};

static IXBaseShortCodeFunction const kIXTruncateFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return ([parameters firstObject] != nil) ? [NSString ix_truncateString:stringToModify toIndex:[[[parameters firstObject] getPropertyValue] intValue]] : stringToModify;
};

static IXBaseShortCodeFunction const kIXStripHtmlFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return (stringToModify) ? [NSString ix_stripHtml:stringToModify] : stringToModify;
};

static IXBaseShortCodeFunction const kIXRadiansToDegreesFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    CGFloat radians = [stringToModify floatValue];
    if (radians > 0 || radians < 0) {
        return [NSString stringWithFormat:@"%f", RADIANS_TO_DEGREES(radians)];
    } else {
        return stringToModify;
    }
};

static IXBaseShortCodeFunction const kIXDegreesToRadiansFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    CGFloat degrees = [stringToModify floatValue];
    if (degrees > 0 || degrees < 0) {
        return [NSString stringWithFormat:@"%f", DEGREES_TO_RADIANS(degrees)];
    } else {
        return stringToModify;
    }
};

@implementation IXShortCodeFunction

+(IXBaseShortCodeFunction)shortCodeFunctionWithName:(NSString*)functionName
{
    static NSDictionary* sIXFunctionDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIXFunctionDictionary = @{  kIXCapitalize:        [kIXCapitalizeFunction copy],
                                    kIXCurrency:          [kIXCurrencyFunction copy],
                                    kIXDistance:          [kIXDistanceFunction copy],
                                    kIXFromBase64:        [kIXFromBase64Function copy],
                                    kIXIs:                [kIXIsFunction copy],
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
                                    kIXTimeFromSeconds:   [kIXTimeFromSecondsFunction copy],
                                    kIXTruncate:          [kIXTruncateFunction copy],
                                    kIXStripHtml:         [kIXStripHtmlFunction copy],
                                    kIXDegreesToRadians:  [kIXDegreesToRadiansFunction copy],
                                    kIXRadiansToDegrees:  [kIXRadiansToDegreesFunction copy]};
    });
    
    return [sIXFunctionDictionary[functionName] copy];
}

@end