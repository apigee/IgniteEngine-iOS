//
//  IxPropertyParser.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/24.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxPropertyParser.h"

#import "IxProperty.h"
#import "IxBaseShortCode.h"

static NSString* const kIxShortcodeMainComponents = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\((.+?)\\)\\]$";
static NSString* const kIxShortcodeMainComponentsNoParams = @"^\\[([\\w-]+?)\\.([\\w-]+?)\\(\\)\\]$";
static NSString* const kIxLegacyShortcodeMainComponents = @"^\\[([\\w-]+?):(.+?)\\]$";
static NSString* const kIxLegacyShortcodeDataComponents = @"^([^\\(]+?)?\\(['\"]?(.*?)['\"]?\\)(?:\\-\\>([^\\]]+?))?$";
static NSString* const kIxParamComponent = @"^\"(.+?)\"$";

static NSRegularExpression* sIxShortCodeMainComponentsRegex = nil;
static NSRegularExpression* sIxShortCodeMainComponentsNoParamsRegex = nil;
static NSRegularExpression* sIxShortCodeLegacyMainComponentsRegex = nil;
static NSRegularExpression* sIxShortCodeLegacyDataComponentsRegex = nil;
static NSRegularExpression* sIxShortCodeParamRegex = nil;

@interface IxPropertyParser ()

+(NSArray*)topLevelShortcodeRangesFromString:(NSString*)string;

@end

@implementation IxPropertyParser

+(void)initialize
{
    sIxShortCodeParamRegex = [[NSRegularExpression alloc] initWithPattern:kIxParamComponent
                                                                   options:NSRegularExpressionDotMatchesLineSeparators
                                                                     error:nil];
    sIxShortCodeMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIxShortcodeMainComponents
                                                                            options:NSRegularExpressionDotMatchesLineSeparators
                                                                              error:nil];
    sIxShortCodeMainComponentsNoParamsRegex = [[NSRegularExpression alloc] initWithPattern:kIxShortcodeMainComponentsNoParams
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
    sIxShortCodeLegacyMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIxLegacyShortcodeMainComponents
                                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                                    error:nil];
    sIxShortCodeLegacyDataComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIxLegacyShortcodeDataComponents
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

+(IxBaseShortCode*)getShortCodeFromShortCodeString:(NSString*)shortCodeString
{
    IxBaseShortCode* returnShortCode = nil;
    
    // First try to match with the legacy way
    NSTextCheckingResult* shortCodeComponents = [IxPropertyParser getShortCodeComponentsUsingRegex:sIxShortCodeLegacyMainComponentsRegex
                                                                                fromShortCodeString:shortCodeString];
    
    BOOL isLegacyShortcode = [shortCodeComponents numberOfRanges] > 0;
    if( !isLegacyShortcode )
    {
        shortCodeComponents = [IxPropertyParser getShortCodeComponentsUsingRegex:sIxShortCodeMainComponentsRegex
                                                              fromShortCodeString:shortCodeString];
        
        if( [shortCodeComponents numberOfRanges] <= 0 )
        {
            shortCodeComponents = [IxPropertyParser getShortCodeComponentsUsingRegex:sIxShortCodeMainComponentsNoParamsRegex
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
                NSString* shortCodesRawValue = [IxPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:0]];
                NSString* shortCodesType = [IxPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:1]];
                NSString* shortCodesMethodName = nil;
                NSMutableArray* shortCodesParameters = nil;
                
                NSString* shortCodesData = [IxPropertyParser getSubstringFromString:shortCodeString withRange:[shortCodeComponents rangeAtIndex:2]];
                
                NSTextCheckingResult* shortCodeDataComponents = [IxPropertyParser getShortCodeComponentsUsingRegex:sIxShortCodeLegacyDataComponentsRegex
                                                                                                fromShortCodeString:shortCodesData];
                
                NSUInteger numberOfRangesInDataComponents = [shortCodeDataComponents numberOfRanges];
                if( numberOfRangesInDataComponents <= 0 )
                {
                    shortCodesMethodName = shortCodesData;
                }
                else
                {
                    shortCodesMethodName = [IxPropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                    
                    if( numberOfRangesInDataComponents > 3 )
                    {
                        NSString* parameterString = [IxPropertyParser getSubstringFromString:shortCodesData withRange:[shortCodeDataComponents rangeAtIndex:1]];
                        if( parameterString != nil )
                        {
                            // TODO: CHECK THIS
                            IxProperty* property = [[IxProperty alloc] initWithPropertyName:nil rawValue:parameterString];
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

+(void)parseIxPropertyIntoComponents:(IxProperty*)property
{
    NSArray* shortCodeRanges = [IxPropertyParser topLevelShortcodeRangesFromString:[property originalString]];
    
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
                    IxBaseShortCode* shortCode = [IxPropertyParser getShortCodeFromShortCodeString:shortCodeAsString];
                }
            }
        }
    }
    
}

@end
