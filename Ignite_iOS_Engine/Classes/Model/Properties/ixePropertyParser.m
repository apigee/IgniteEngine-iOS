//
//  ixePropertyParser.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/24.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixePropertyParser.h"

#import "ixeProperty.h"
#import "ixeBaseShortCode.h"

static NSString* const kixeShortcodeMainComponents = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\((.+?)\\)\\]$";
static NSString* const kixeShortcodeMainComponentsNoParams = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\(\\)\\]$";
static NSString* const kixeLegacyShortcodeMainComponents = @"^\\[([\\w-]+?):(.+?)\\]$";
static NSString* const kixeLegacyShortcodeDataComponents = @"^([^\\(]+?)?\\(['\"]?(.*?)['\"]?\\)(?:\\-\\>([^\\]]+?))?$";
static NSString* const kixeParamComponent = @"^\"(.+?)\"$";

static NSRegularExpression* sixeShortCodeMainComponentsRegex = nil;
static NSRegularExpression* sixeShortCodeMainComponentsNoParamsRegex = nil;
static NSRegularExpression* sixeShortCodeLegacyMainComponentsRegex = nil;
static NSRegularExpression* sixeShortCodeLegacyDataComponentsRegex = nil;
static NSRegularExpression* sixeShortCodeParamRegex = nil;

@interface ixePropertyParser ()

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string;

@end

@implementation ixePropertyParser

+(void)initialize
{
    sixeShortCodeParamRegex = [[NSRegularExpression alloc] initWithPattern:kixeParamComponent
                                                                   options:NSRegularExpressionDotMatchesLineSeparators
                                                                     error:nil];
    sixeShortCodeMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kixeShortcodeMainComponents
                                                                            options:NSRegularExpressionDotMatchesLineSeparators
                                                                              error:nil];
    sixeShortCodeMainComponentsNoParamsRegex = [[NSRegularExpression alloc] initWithPattern:kixeShortcodeMainComponentsNoParams
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
    sixeShortCodeLegacyMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kixeLegacyShortcodeMainComponents
                                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                                    error:nil];
    sixeShortCodeLegacyDataComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kixeLegacyShortcodeDataComponents
                                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                                    error:nil];
}

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string
{
    NSMutableArray* shortcodeRanges = nil;
    
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
                            
                                    if( [substring isEqualToString:@"["] || [substring isEqualToString:@"]"] )
                                    {
                                        // Is this an escaped bracket?
                                        if( substringRange.location > 0 && [previousString isEqualToString:@"\\"] )
                                        {
                                            if( openBrackets == 0 )
                                            {
                                                NSRange shortCodeRange = NSMakeRange(substringRange.location - 1, 2);
                                                [shortcodeRanges addObject:[NSValue valueWithRange:shortCodeRange]];
                                            }
                                        }
                                        // Is this a starting bracket?
                                        else if( [substring isEqualToString:@"["] )
                                        {
                                            if( openBrackets == 0 )
                                            {
                                                openBracketStartPosition = substringRange.location;
                                            }
                                            openBrackets++;
                                        }
                                        // Is this an ending bracket and do we have an opening one already?
                                        else if( openBrackets > 0 && [substring isEqualToString:@"]"] )
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

+(ixeBaseShortCode*)getShortCodeFromShortCodeString:(NSString*)shortCodeString
{
    ixeBaseShortCode* returnShortCode = nil;
    
    // First try to match with the legacy way
    NSTextCheckingResult* shortCodeComponents = [ixePropertyParser getShortCodeComponentsUsingRegex:sixeShortCodeLegacyMainComponentsRegex
                                                                                fromShortCodeString:shortCodeString];
    
    BOOL isLegacyShortcode = [shortCodeComponents numberOfRanges] > 0;
    if( !isLegacyShortcode )
    {
        shortCodeComponents = [ixePropertyParser getShortCodeComponentsUsingRegex:sixeShortCodeMainComponentsRegex
                                                              fromShortCodeString:shortCodeString];
        
        if( [shortCodeComponents numberOfRanges] <= 0 )
        {
            shortCodeComponents = [ixePropertyParser getShortCodeComponentsUsingRegex:sixeShortCodeMainComponentsNoParamsRegex
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
                NSString* shortCodesRawValue = [ixePropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:0]];
                NSString* shortCodesType = [ixePropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:1]];
                NSString* shortCodesMethodName = nil;
                NSMutableArray* shortCodesParameters = nil;
                
                NSString* shortCodesData = [ixePropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:2]];
                
                NSTextCheckingResult* shortCodeDataComponents = [ixePropertyParser getShortCodeComponentsUsingRegex:sixeShortCodeLegacyDataComponentsRegex
                                                                                                fromShortCodeString:shortCodesData];
                
                NSUInteger numberOfRangesInDataComponents = [shortCodeDataComponents numberOfRanges];
                if( numberOfRangesInDataComponents <= 0 )
                {
                    shortCodesMethodName = shortCodesData;
                }
                else
                {
                    shortCodesMethodName = [ixePropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                    
                    if( numberOfRangesInDataComponents > 3 )
                    {
                        NSString* parameterString = [ixePropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                        if( parameterString != nil )
                        {
                            // TODO: CHECK THIS
                            ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:nil rawValue:parameterString];
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
            
        }
    }
    
    return returnShortCode;
}

+(void)parseixePropertyIntoComponents:(ixeProperty*)property
{
    NSArray* shortCodeRanges = [ixePropertyParser topLevelShortcodeRangesFromString:[property originalString]];
    
    if( [shortCodeRanges count] > 0 )
    {
        property.shortCodes = [[NSMutableArray alloc] init];
        property.shortCodeRanges = [[NSMutableArray alloc] init];
        
        NSUInteger numberOfCharactersRemoved = 0;
        NSMutableString* staticTextWithoutShortcodes = [[NSMutableString alloc] initWithString:[property originalString]];
        
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
                    [staticTextWithoutShortcodes replaceCharactersInRange:shortCodeRange withString:stringToUseForReplace];
                    numberOfCharactersRemoved++;
                }
                else
                {
                    ixeBaseShortCode* shortCode = [ixePropertyParser getShortCodeFromShortCodeString:shortCodeAsString];
                }
            }
        }
    }
    
}

@end
