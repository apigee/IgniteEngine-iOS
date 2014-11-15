//
//  IXShortCodeFunction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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

// NOTE: Please add function name here in alphabetical order as well as adding the function block below in the same order.
// Also to enable use of the function, ensure you have also set the function in the shortCodeFunctionWithName in the load method.

//                      FUNCTION NAME                                   USAGE                                   RETURN VALUE/NOTES
//                                                               (? means any attribute)

IX_STATIC_CONST_STRING kIXCapitalize = @"capitalize";           // [[?:capitalize]]                         -> String value Capitalized
IX_STATIC_CONST_STRING kIXCurrency = @"currency";               // [[?:currency]]                           -> String value in currency form
IX_STATIC_CONST_STRING kIXDistance = @"distance";               // [[app:distance(lat1:long1,lat2:long2)]]  -> Distance from lat1,long1 to lat2,long2.
IX_STATIC_CONST_STRING kIXDestroySession = @"session.destroy";  // [[app:session.destroy]]                  -> Removes all session attributes from memory. Returns nil.
IX_STATIC_CONST_STRING kIXFromBase64 = @"from_base64";          // [[?:from_base64]]                        -> Base64 value to string
IX_STATIC_CONST_STRING kIXIsEmpty = @"is_empty";                // [[?:is_empty]]                           -> True if the string is empty (aka "")
IX_STATIC_CONST_STRING kIXIsNil = @"is_nil";                    // [[?:is_nil]]                             -> True if the string is nil
IX_STATIC_CONST_STRING kIXIsNilOrEmpty = @"is_nil_or_empty";    // [[?:is_nil_or_empty]]                    -> True if the string is empty or nil
IX_STATIC_CONST_STRING kIXIsNotEmpty = @"is_not_empty";         // [[?:is_not_empty]]                       -> True if the string is not empty
IX_STATIC_CONST_STRING kIXIsNotNil = @"is_not_nil";             // [[?:is_not_nil]]                         -> True if the string is not nil
IX_STATIC_CONST_STRING kIXLength = @"length";                   // [[?:length]]                             -> Length of the attributes string
IX_STATIC_CONST_STRING kIXMoment = @"moment";                   // [[?:moment(toDateFormat)]]               -> String as date with the given format (can have 2 params)
IX_STATIC_CONST_STRING kIXMonogram = @"monogram";               // [[?:monogram]]                           -> String monogram value
IX_STATIC_CONST_STRING kIXNow = @"now";                         // [[app:now]]                              -> Current date as string (can specify dateFormat)
IX_STATIC_CONST_STRING kIXRandomNumber = @"random_number";      // [[app:random_number(upBounds)]]          -> Random number generator (can specify lower bounds)
IX_STATIC_CONST_STRING kIXToBase64 = @"to_base64";              // [[?:to_base64]]                          -> String to Base64 value
IX_STATIC_CONST_STRING kIXToMD5 = @"to_md5";                    // [[?:to_md5]]                             -> String to MD5 hashed value
IX_STATIC_CONST_STRING kIXToUppercase = @"to_uppercase";        // [[?:to_uppercase]]                       -> String value in UPPERCASE
IX_STATIC_CONST_STRING kIXToLowercase = @"to_lowercase";        // [[?:to_lowercase]]                       -> String value in lowercase
IX_STATIC_CONST_STRING kIXURLEncode = @"url_encode";            // [[?:url_encode]]                         -> URL encode string
IX_STATIC_CONST_STRING kIXTruncate = @"truncate";               // [[?:truncate(toIndex)]]                  -> Trucates the string to specified index

static IXBaseShortCodeFunction const kIXCapitalizeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify capitalizedString];
};

static IXBaseShortCodeFunction const kIXCurrencyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters)
{
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    NSDecimalNumber* amount = [NSDecimalNumber zero];
    if( [stringToModify length] > 0 )
    {
        amount = [[NSDecimalNumber alloc] initWithString:stringToModify];
    }
    
    return [formatter stringFromNumber:amount];
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
    return [NSString ix_toBase64String:stringToEncode];
};

static IXBaseShortCodeFunction const kIXToMD5Function = ^NSString*(NSString* stringToEncode,NSArray* parameters){
    return [NSString ix_toMD5String:stringToEncode];
};

static IXBaseShortCodeFunction const kIXToLowerCaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify lowercaseString];
};

static IXBaseShortCodeFunction const kIXToUppercaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify uppercaseString];
};

static IXBaseShortCodeFunction const kIXURLEncodeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    //return [stringToModify uppercaseString];
    return [stringToModify stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
                                    kIXToLowercase:       [kIXToLowerCaseFunction copy],
                                    kIXToUppercase:       [kIXToUppercaseFunction copy],
                                    kIXURLEncode:         [kIXURLEncodeFunction copy],
                                    kIXTruncate:          [kIXTruncateFunction copy]};
    });

    return [sIXFunctionDictionary[functionName] copy];
}

@end
