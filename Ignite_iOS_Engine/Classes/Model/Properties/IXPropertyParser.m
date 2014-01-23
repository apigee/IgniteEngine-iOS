//
//  IXPropertyParser.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/24/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXPropertyParser.h"

#import "IXProperty.h"
#import "IXBaseShortCode.h"
#import "IXFormatShortCode.h"

//static NSString* const kIXShortcodeMainComponents = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\((.+?)\\)\\]$";
//static NSString* const kIXShortcodeMainComponents = @"^\\[\\[([\\w\\.]+)(\\('?([^)]+)'\\)?)*?\\]\\]$";
//static NSString* const kIXShortcodeMainComponents = @"^\\[\\[([\\w\\.]+)\\(?\\'?(.+?)?\\'?\\)?\\]\\]$";
static NSString* const kIXShortcodeMainComponents = @"^\\[\\[([\\w\\.]+)\\(?(.+?)?\\)?\\]\\]$";

static NSString* const kIXJSComponents = @"^\\*\\|([^\\*\\|]+)\\|\\*$";

static NSString* const kIXShortcodeMainComponentsNoParams = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\(\\)\\]$";
static NSString* const kIXParamComponent = @"^'(.+?)'$";

static NSRegularExpression* sIXShortCodeMainComponentsRegex = nil;
static NSRegularExpression* sIXShortCodeMainComponentsNoParamsRegex = nil;
static NSRegularExpression* sIXShortCodeParamRegex = nil;

static NSString* const kIXOpenBracketString = @"[";
static NSString* const kIXDoubleOpenBracketString = @"[[";
static NSString* const kIXCloseBracketString = @"]";
static NSString* const kIXDoubleCloseBracketString = @"]]";
static NSString* const kIXEscapeBracketString = @"\\";
static NSString* const kIXSingleQuoteString = @"'";
static NSString* const kIXCommaString = @",";
static NSString* const kIXPeriodString = @".";
static NSString* const kIXEmptyString = @"";

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
}

+(NSMutableArray*)topLevelParameterRangesFromString:(NSString*)string
{
    __block NSMutableArray* parameterRanges = nil;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger stringLength = [string length];
    if( string != nil && stringLength > 0 )
    {
        __block NSUInteger numberOfSingleQuotesFound = 0;
        __block NSUInteger numberOfBracketsFound = 0;
        __block NSInteger startOfParameter = -1;
        __block NSInteger endOfParameter = -1;
        
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
                                            NSUInteger lengthOfParam = endOfParameter - startOfParameter - 1;
                                            NSRange rangeOfParam = NSMakeRange(startOfParameter + 1, lengthOfParam);
                                            if( !parameterRanges )
                                                parameterRanges = [[NSMutableArray alloc] init];

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
                NSUInteger lengthOfParam = endOfParameter - startOfParameter - 1;
                rangeOfParameter = NSMakeRange(startOfParameter + 1, lengthOfParam);
            }
            
            NSValue* rangeValue = [NSValue valueWithRange:rangeOfParameter];
            if( !parameterRanges )
                parameterRanges = [[NSMutableArray alloc] initWithObjects:rangeValue, nil];
            else
                [parameterRanges addObject:rangeValue];
        }
    }
    
    return parameterRanges;
}

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string
{
    __block NSMutableArray* shortcodeRanges = nil;
    
    NSUInteger stringLength = [string length];
    if( string != nil || stringLength > 0 )
    {
        if( [string rangeOfString:kIXDoubleOpenBracketString].location == NSNotFound || [string rangeOfString:kIXDoubleCloseBracketString].location == NSNotFound )
            return nil;
        
        __block NSString* previousString = nil;
        __block NSUInteger numberOfOpenBracketsFound = 0;
        __block NSUInteger openBracketStartPosition = 0;
        
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                            
                                    if( [substring isEqualToString:kIXOpenBracketString] || [substring isEqualToString:kIXCloseBracketString] )
                                    {
                                        if( substringRange.location > 0 && [previousString isEqualToString:kIXEscapeBracketString] )
                                        {
                                            if( numberOfOpenBracketsFound == 0 )
                                            {
                                                if( !shortcodeRanges )
                                                    shortcodeRanges = [[NSMutableArray alloc] init];
                                                
                                                NSRange shortCodeRange = NSMakeRange(substringRange.location - 1, 2);
                                                [shortcodeRanges addObject:[NSValue valueWithRange:shortCodeRange]];
                                            }
                                        }
                                        else if( [substring isEqualToString:kIXOpenBracketString] )
                                        {
                                            if( numberOfOpenBracketsFound == 0 )
                                            {
                                                openBracketStartPosition = substringRange.location;
                                            }
                                            numberOfOpenBracketsFound++;
                                        }
                                        else if( numberOfOpenBracketsFound > 0 && [substring isEqualToString:kIXCloseBracketString] )
                                        {
                                            numberOfOpenBracketsFound--;
                                            
                                            if( numberOfOpenBracketsFound == 0 )
                                            {
                                                if( !shortcodeRanges )
                                                    shortcodeRanges = [[NSMutableArray alloc] init];

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

+(NSString*)getSubstringFromString:(NSString*)rawString withRange:(NSRange)range
{
    NSString* returnString = nil;
    if( range.location != NSNotFound && range.length != 0 )
    {
        returnString = [rawString substringWithRange:range];
    }
    return returnString;
}

+(IXBaseShortCode*)parseShortCodeFromString:(NSString*)shortCodeString
{
    IXBaseShortCode* returnShortCode = nil;
    
    NSTextCheckingResult* matchInShortCodeString = [sIXShortCodeMainComponentsRegex firstMatchInString:shortCodeString options:0 range:NSMakeRange(0, [shortCodeString length])];
    
    if( matchInShortCodeString )
    {
        NSMutableArray* validRanges = [NSMutableArray array];
        for( int i = 0; i < [matchInShortCodeString numberOfRanges]; i++)
        {
            NSRange range = [matchInShortCodeString rangeAtIndex:i];
            if( range.location != NSNotFound )
            {
                [validRanges addObject:[NSValue valueWithRange:range]];
            }
        }
        
        NSUInteger validRangesCount = [validRanges count];
        if( validRangesCount >= 2 )
        {
            NSRange shortCodeRangeWithBrackets = [[validRanges firstObject] rangeValue];
            NSRange shortCodeObjectIDWithMethodRange = [[validRanges objectAtIndex:1] rangeValue];
            
            NSString* rawValue = [shortCodeString substringWithRange:shortCodeRangeWithBrackets];
            
            NSString* objectIDWithMethodString = [shortCodeString substringWithRange:shortCodeObjectIDWithMethodRange];
            NSMutableArray* objectIDWithMethodStringComponents = [NSMutableArray arrayWithArray:[objectIDWithMethodString componentsSeparatedByString:kIXPeriodString]];
            
            if( [objectIDWithMethodStringComponents count] >= 1 )
            {
                NSString* type = (validRangesCount == 3) ? [objectIDWithMethodStringComponents lastObject] : @"Get";
                Class shortCodeClass = NSClassFromString([NSString stringWithFormat:@"IX%@ShortCode",[type capitalizedString]]);
                if( shortCodeClass )
                {
                    NSString* objectID = [objectIDWithMethodStringComponents firstObject];
                    
                    [objectIDWithMethodStringComponents removeObjectsInArray:@[objectID,type]];
                    NSString* methodName = ([objectIDWithMethodStringComponents count] > 0) ? [objectIDWithMethodStringComponents componentsJoinedByString:kIXPeriodString] : nil;
                    __block NSMutableArray* parameters = nil;
                    __block NSMutableArray* formatters = nil;
                    
                    if( validRangesCount == 3 )
                    {
                        NSRange parameterRange = [[validRanges objectAtIndex:2] rangeValue];
                        NSString* parametersString = [shortCodeString substringWithRange:parameterRange];
                        
                        if( parametersString != nil && [parametersString length] > 0 )
                        {
                            NSMutableArray* parameterRanges = [IXPropertyParser topLevelParameterRangesFromString:parametersString];
                            
                            [parameterRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSString* parameterString = [parametersString substringWithRange:[obj rangeValue]];
                                if( parameterString != nil && [parameterString length] > 0 )
                                {
                                    if( idx == 0 && [[type lowercaseString] isEqualToString:@"format"] )
                                    {
                                        formatters = [[NSMutableArray alloc] init];
                                        NSArray* formatterStringArray = [parameterString componentsSeparatedByString:@":"];
                                        for( NSString* formatter in formatterStringArray )
                                        {
                                            IXProperty* formatterProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:formatter];
                                            if( formatterProperty )
                                            {
                                                [formatters addObject:formatterProperty];
                                            }
                                        }
                                    }
                                    else
                                    {
                                        IXProperty* parameterProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:parameterString];
                                        if( parameterProperty )
                                        {
                                            if( !parameters )
                                            {
                                                parameters = [[NSMutableArray alloc] init];
                                            }
                                            [parameters addObject:parameterProperty];
                                        }
                                    }
                                }
                            }];
                        }
                    }
                    returnShortCode = [[shortCodeClass alloc] initWithRawValue:rawValue objectID:objectID methodName:methodName parameters:parameters];
                    if( shortCodeClass == [IXFormatShortCode class] )
                    {
                        IXFormatShortCode* formatShortCode = (IXFormatShortCode*)returnShortCode;
                        [formatShortCode setFormatters:formatters];
                    }
                }
            }
        }
    }
    return returnShortCode;
}

+(void)parseIXPropertyIntoComponents:(IXProperty*)property
{
    NSString* propertyOriginalString = [property originalString];
    
    NSMutableArray* propertiesShortCodes = nil;
    NSMutableArray* propertiesShortCodeRanges = nil;
    
    NSArray* shortCodeRanges = [IXPropertyParser topLevelShortcodeRangesFromString:propertyOriginalString];
    NSMutableString* propertiesStaticText = [[NSMutableString alloc] initWithString:propertyOriginalString];

    if( [shortCodeRanges count] > 0 )
    {
        NSUInteger numberOfCharactersRemoved = 0;
        
        for( NSValue* shortCodeRangeAsValue in shortCodeRanges )
        {
            NSRange shortCodeRange = [shortCodeRangeAsValue rangeValue];
            NSString* shortCodeAsString = [[property originalString] substringWithRange:shortCodeRange];
            
            if( shortCodeAsString != nil )
            {
                if( [shortCodeAsString isEqualToString:@"\\["] || [shortCodeAsString isEqualToString:@"\\]"] )
                {
                    NSString* stringToUseForReplace = ([shortCodeAsString isEqualToString:@"\\[["]) ? kIXDoubleOpenBracketString : kIXDoubleCloseBracketString;
                    shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                    [propertiesStaticText replaceCharactersInRange:shortCodeRange withString:stringToUseForReplace];
                    numberOfCharactersRemoved++;
                }
                else
                {
                    IXBaseShortCode* shortCode = [IXPropertyParser parseShortCodeFromString:shortCodeAsString];
                    if( shortCode )
                    {
                        [shortCode setProperty:property];
                        
                        if( !propertiesShortCodes )
                        {
                            propertiesShortCodes = [[NSMutableArray alloc] init];
                            propertiesShortCodeRanges = [[NSMutableArray alloc] init];
                        }
                        [propertiesShortCodes addObject:shortCode];
                        [propertiesShortCodeRanges addObject:shortCodeRangeAsValue];
                        
                        shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                        [propertiesStaticText replaceCharactersInRange:shortCodeRange withString:kIXEmptyString];
                        numberOfCharactersRemoved += shortCodeRange.length;
                    }
                }
            }
        }
    }
    
    [property setStaticText:propertiesStaticText];
    [property setShortCodes:propertiesShortCodes];
    [property setShortCodeRanges:propertiesShortCodeRanges];
}

@end
