//
//  IXPropertyParser.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/24.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXPropertyParser.h"

#import "IXProperty.h"
#import "IXBaseShortCode.h"

static NSString* const kIXShortcodeMainComponents = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\((.+?)\\)\\]$";
static NSString* const kIXShortcodeMainComponentsNoParams = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\(\\)\\]$";
static NSString* const kIXLegacyShortcodeMainComponents = @"^\\[([\\w-]+?):(.+?)\\]$";
static NSString* const kIXLegacyShortcodeDataComponents = @"^([^\\(]+?)?\\(['\"]?(.*?)['\"]?\\)(?:\\-\\>([^\\]]+?))?$";
static NSString* const kIXParamComponent = @"^'(.+?)'$";

static NSRegularExpression* sIXShortCodeMainComponentsRegex = nil;
static NSRegularExpression* sIXShortCodeMainComponentsNoParamsRegex = nil;
static NSRegularExpression* sIXShortCodeLegacyMainComponentsRegex = nil;
static NSRegularExpression* sIXShortCodeLegacyDataComponentsRegex = nil;
static NSRegularExpression* sIXShortCodeParamRegex = nil;

static NSString* const kIXOpenBracketString = @"[";
static NSString* const kIXCloseBracketString = @"]";
static NSString* const kIXEscapeBracketString = @"\\";
static NSString* const kIXSingleQuoteString = @"'";
static NSString* const kIXCommaString = @",";

@interface IXPropertyParser ()

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string;

@end

@implementation IXPropertyParser

+(void)initialize
{
    sIXShortCodeParamRegex = [[NSRegularExpression alloc] initWithPattern:kIXParamComponent
                                                                   options:NSRegularExpressionDotMatchesLineSeparators
                                                                     error:nil];
    sIXShortCodeMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXShortcodeMainComponents
                                                                            options:NSRegularExpressionDotMatchesLineSeparators
                                                                              error:nil];
    sIXShortCodeMainComponentsNoParamsRegex = [[NSRegularExpression alloc] initWithPattern:kIXShortcodeMainComponentsNoParams
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
    sIXShortCodeLegacyMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXLegacyShortcodeMainComponents
                                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                                    error:nil];
    sIXShortCodeLegacyDataComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXLegacyShortcodeDataComponents
                                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                                    error:nil];
}

+(NSArray*)parseMethodParametersFromString:(NSString*)string
{
    NSMutableArray* parametersArray = nil;

    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray* rangesOfParameters = [IXPropertyParser topLevelParameterRangesFromString:string];

    if( [rangesOfParameters count] == 0 )
    {
        NSTextCheckingResult* parameterComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeParamRegex
                                                                                    fromShortCodeString:string];
        if( [parameterComponents numberOfRanges] > 1 )
        {
            NSString* parameterString = [string substringWithRange:[parameterComponents rangeAtIndex:1]];
            IXProperty* parameterProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:parameterString];
            if( parameterProperty != nil )
            {
                parametersArray = [NSMutableArray arrayWithObject:parameterProperty];
            }
        }
    }
    else
    {
        parametersArray = [[NSMutableArray alloc] init];
        
        for( NSValue* rangeValue in rangesOfParameters )
        {
            NSRange parameterRange = [rangeValue rangeValue];
            NSString* parameterString = [string substringWithRange:parameterRange];
            
            NSTextCheckingResult* parameterComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeParamRegex
                                                                                        fromShortCodeString:parameterString];
            if( [parameterComponents numberOfRanges] > 1 )
            {
                parameterString = [parameterString substringWithRange:[parameterComponents rangeAtIndex:1]];
                IXProperty* parameterProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:parameterString];
                if( parameterProperty != nil )
                {
                    [parametersArray addObject:parameterProperty];
                }
            }
        }
    }
    
    return parametersArray;
}

+(NSArray*)topLevelParameterRangesFromString:(NSString*)string
{
    NSMutableArray* parameterRanges = nil;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger stringLength = [string length];
    if( string != nil && stringLength > 0 )
    {
        parameterRanges = [[NSMutableArray alloc] init];
        
        __block NSUInteger numberOfSingleQuotesFound = 0;
        __block NSUInteger numberOfBracketsFound = 0;
        __block NSUInteger startOfParameter = -1;
        __block NSUInteger endOfParameter = -1;
        
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                    
                                    if( [substring isEqualToString:kIXSingleQuoteString] )
                                    {
                                        if( startOfParameter == -1 )
                                        {
                                            startOfParameter = substringRange.location;
                                        }
                                        
                                        endOfParameter = substringRange.location;
                                        numberOfSingleQuotesFound++;
                                    }
                                    else if( [substring isEqualToString:kIXOpenBracketString] || [substring isEqualToString:kIXCloseBracketString] )
                                    {
                                        if( [substring isEqualToString:kIXOpenBracketString] )
                                            numberOfBracketsFound++;
                                        else
                                            numberOfBracketsFound--;
                                    }
                                    else if( [substring isEqualToString:kIXCommaString] )
                                    {
                                        if( (numberOfSingleQuotesFound % 2) == 0 && numberOfBracketsFound == 0 )
                                        {
                                            NSUInteger lengthOfParam = endOfParameter - startOfParameter + 1;
                                            NSRange rangeOfParam = NSMakeRange(startOfParameter, lengthOfParam);
                                            [parameterRanges addObject:[NSValue valueWithRange:rangeOfParam]];
                                                
                                            startOfParameter = -1;
                                            endOfParameter = -1;
                                            numberOfSingleQuotesFound = 0;
                                            numberOfBracketsFound = 0;
                                        }
                                    }
        }];
        
        
        if( [parameterRanges count] == 0 || (startOfParameter != -1 && endOfParameter != -1 && numberOfBracketsFound == 0) )
        {
            NSRange rangeOfParameter;
            if( startOfParameter == -1 || endOfParameter == -1 )
            {
                rangeOfParameter = NSMakeRange(0, 0);
            }
            else
            {
                NSUInteger lengthOfParam = endOfParameter - startOfParameter + 1;
                rangeOfParameter = NSMakeRange(startOfParameter, lengthOfParam);
            }
            [parameterRanges addObject:[NSValue valueWithRange:rangeOfParameter]];
        }
    }
    
    return parameterRanges;
}

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string
{
    NSMutableArray* shortcodeRanges = nil;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger stringLength = [string length];
    if( string != nil || stringLength > 0 )
    {
        shortcodeRanges = [[NSMutableArray alloc] init];
        
        __block NSString* previousString = nil;
        __block NSUInteger openBrackets = 0;
        __block NSUInteger openBracketStartPosition = 0;
        
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                            
                                    if( [substring isEqualToString:kIXOpenBracketString] || [substring isEqualToString:kIXCloseBracketString] )
                                    {
                                        // Is this an escaped bracket?
                                        if( substringRange.location > 0 && [previousString isEqualToString:kIXEscapeBracketString] )
                                        {
                                            if( openBrackets == 0 )
                                            {
                                                NSRange shortCodeRange = NSMakeRange(substringRange.location - 1, 2);
                                                [shortcodeRanges addObject:[NSValue valueWithRange:shortCodeRange]];
                                            }
                                        }
                                        // Is this a starting bracket?
                                        else if( [substring isEqualToString:kIXOpenBracketString] )
                                        {
                                            if( openBrackets == 0 )
                                            {
                                                openBracketStartPosition = substringRange.location;
                                            }
                                            openBrackets++;
                                        }
                                        // Is this an ending bracket and do we have an opening one already?
                                        else if( openBrackets > 0 && [substring isEqualToString:kIXCloseBracketString] )
                                        {
                                            openBrackets--;
                                            
                                            // Are we all caught up on brackets now?
                                            if( openBrackets == 0 )
                                            {
                                                NSRange shortCodeRange = NSMakeRange(openBracketStartPosition, (substringRange.location - openBracketStartPosition) + 1);
                                                [shortcodeRanges addObject:[NSValue valueWithRange:shortCodeRange]];
                                            }
                                        }
                                    }
                                    
                                    previousString = substring;
                                    
        }];
    }
    
    return shortcodeRanges;
}

+(NSTextCheckingResult*)getShortCodeComponentsUsingRegex:(NSRegularExpression*)regex fromShortCodeString:(NSString*)shortCodeString
{
    NSTextCheckingResult* returnComponents = [regex firstMatchInString:shortCodeString
                                                               options:0
                                                                 range:NSMakeRange(0, [shortCodeString length])];
    
    return returnComponents;
}

+(NSString*)getSubstringFromString:(NSString*)rawString withRange:(NSRange)range
{
    NSString* returnString = nil;
    if( range.location != NSNotFound && range.length != 0 )
    {
        returnString = [rawString substringWithRange:range];
    }
    return returnString;
}

+(IXBaseShortCode*)getShortCodeFromShortCodeString:(NSString*)shortCodeString
{
    IXBaseShortCode* returnShortCode = nil;
    
    // First try to match with the legacy way
    NSTextCheckingResult* shortCodeComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeLegacyMainComponentsRegex
                                                                                fromShortCodeString:shortCodeString];
    
    BOOL isLegacyShortcode = [shortCodeComponents numberOfRanges] > 0;
    if( !isLegacyShortcode )
    {
        shortCodeComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeMainComponentsRegex
                                                              fromShortCodeString:shortCodeString];
        
        if( [shortCodeComponents numberOfRanges] <= 0 )
        {
            shortCodeComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeMainComponentsNoParamsRegex
                                                                  fromShortCodeString:shortCodeString];
        }
    }
    
    NSUInteger numberOfRangesInMainComponents = [shortCodeComponents numberOfRanges];
    if( numberOfRangesInMainComponents > 0 )
    {
        if( isLegacyShortcode )
        {
            if( numberOfRangesInMainComponents >= 3 )
            {
                NSString* shortCodesRawValue = [IXPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:0]];
                NSString* shortCodesType = [IXPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:1]];
                NSString* shortCodesMethodName = nil;
                NSMutableArray* shortCodesParameters = nil;
                
                NSString* shortCodesData = [IXPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:2]];
                
                NSTextCheckingResult* shortCodeDataComponents = [IXPropertyParser getShortCodeComponentsUsingRegex:sIXShortCodeLegacyDataComponentsRegex
                                                                                                fromShortCodeString:shortCodesData];
                
                NSUInteger numberOfRangesInDataComponents = [shortCodeDataComponents numberOfRanges];
                if( numberOfRangesInDataComponents <= 0 )
                {
                    shortCodesMethodName = shortCodesData;
                }
                else
                {
                    shortCodesMethodName = [IXPropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                    
                    if( numberOfRangesInDataComponents > 3 )
                    {
                        NSString* parameterString = [IXPropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                        if( parameterString != nil )
                        {
                            // TODO: CHECK THIS
                            IXProperty* property = [[IXProperty alloc] initWithPropertyName:nil rawValue:parameterString];
                            shortCodesParameters = [[NSMutableArray alloc] initWithObjects:property, nil];
                        }
                        
                        if( numberOfRangesInDataComponents > 4 )
                        {
                            
                        }
                    }
                    
                }
                
                
            }
        }
        else
        {
            NSUInteger rangeCount = [shortCodeComponents numberOfRanges];
            
            if( rangeCount >= 3 )
            {
                NSString* shortCodesRawValue = [IXPropertyParser getSubstringFromString:shortCodeString
                                                                               withRange:[shortCodeComponents rangeAtIndex:0]];
                NSString* shortCodesType = [IXPropertyParser getSubstringFromString:shortCodeString
                                                                           withRange:[shortCodeComponents rangeAtIndex:1]];
                NSString* shortCodesMethod = [IXPropertyParser getSubstringFromString:shortCodeString
                                                                             withRange:[shortCodeComponents rangeAtIndex:2]];
                NSArray* shortCodeParameters = nil;
                
                if( rangeCount >= 4 )
                {
                    NSString* shortCodesParametersString = [IXPropertyParser getSubstringFromString:shortCodeString
                                                                                           withRange:[shortCodeComponents rangeAtIndex:3]];
                    shortCodeParameters = [IXPropertyParser parseMethodParametersFromString:shortCodesParametersString];
                }
                
                returnShortCode = [IXBaseShortCode shortCodeWithRawValue:shortCodesRawValue objectID:shortCodesType methodName:shortCodesMethod parameters:shortCodeParameters];
            }
        }
    }
    
    return returnShortCode;
}

+(void)parseIXPropertyIntoComponents:(IXProperty*)property
{
    NSArray* shortCodeRanges = [IXPropertyParser topLevelShortcodeRangesFromString:[property originalString]];
   
    NSMutableArray* propertiesShortCodes = nil;
    NSMutableArray* propertiesShortCodeRanges = nil;
    NSMutableString* propertiesStaticText = [[NSMutableString alloc] initWithString:[property originalString]];

    if( [shortCodeRanges count] > 0 )
    {
        propertiesShortCodes = [[NSMutableArray alloc] init];
        propertiesShortCodeRanges = [[NSMutableArray alloc] init];
        
        NSUInteger numberOfCharactersRemoved = 0;
        
        for( NSValue* shortCodeRangeAsValue in shortCodeRanges )
        {
            NSRange shortCodeRange = [shortCodeRangeAsValue rangeValue];
            NSString* shortCodeAsString = [[property originalString] substringWithRange:shortCodeRange];
            
            if( shortCodeAsString != nil )
            {
                if( [shortCodeAsString isEqualToString:@"\\["] || [shortCodeAsString isEqualToString:@"\\]"] )
                {
                    NSString* stringToUseForReplace = ([shortCodeAsString isEqualToString:@"\\["]) ? @"[" : @"]";
                    shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                    [propertiesStaticText replaceCharactersInRange:shortCodeRange withString:stringToUseForReplace];
                    numberOfCharactersRemoved++;
                }
                else
                {
                    IXBaseShortCode* shortCode = [IXPropertyParser getShortCodeFromShortCodeString:shortCodeAsString];
                    [shortCode setProperty:property];
                    
                    shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                    [propertiesStaticText replaceCharactersInRange:shortCodeRange withString:@""];
                    numberOfCharactersRemoved += shortCodeRange.length;
                    
                    [propertiesShortCodes addObject:shortCode];
                    [propertiesShortCodeRanges addObject:shortCodeRangeAsValue];
                }
            }
        }
    }
    
    [property setStaticText:propertiesStaticText];
    [property setShortCodes:propertiesShortCodes];
    [property setShortCodeRanges:propertiesShortCodeRanges];
}

@end
