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
#import "IXEvalShortCode.h"
#import "IXGetShortCode.h"
#import "IXLogger.h"

static NSString* const kIXEmptyString = @"";
static NSString* const kIXCommaString = @",";
static NSString* const kIXPeriodString = @".";
static NSString* const kIXEvalBracketsString = @"{{";
static NSString* const kIXShortCodeClassFormat = @"IX%@ShortCode";
static NSString* const kIXShortcodeRegexString = @"(\\[{2}(.+?)(?::(.+?)(?:\\((.+?)\\))?)?\\]{2}|\\{{2}([^\\}]+)\\}{2})";

NSArray* validRangesFromTextCheckingResult(NSTextCheckingResult* textCheckingResult)
{
    NSMutableArray* validRanges = [NSMutableArray array];
    for( int i = 0; i < [textCheckingResult numberOfRanges]; i++)
    {
        NSRange range = [textCheckingResult rangeAtIndex:i];
        if( range.location != NSNotFound )
        {
            [validRanges addObject:[NSValue valueWithRange:range]];
        }
    }
    return validRanges;
}

@interface IXPropertyParser ()

@end

@implementation IXPropertyParser

+(IXBaseShortCode*)parseShortCodeFromTextCheckingResult:(NSTextCheckingResult*)textCheckingResult withOriginalString:(NSString*)originalString
{
    IXBaseShortCode* returnShortCode = nil;
    if( textCheckingResult )
    {
        NSArray* validRanges = validRangesFromTextCheckingResult(textCheckingResult);
        
        NSUInteger validRangesCount = [validRanges count];
        if( validRangesCount >= 3 )
        {
            NSString* rawValue = [originalString substringWithRange:[[validRanges firstObject] rangeValue]];
            NSString* objectIDWithMethodString = [originalString substringWithRange:[[validRanges objectAtIndex:2] rangeValue]];
            
            if( [rawValue hasPrefix:kIXEvalBracketsString] )
            {
                IXProperty* evalPropertyValue = [[IXProperty alloc] initWithPropertyName:nil rawValue:objectIDWithMethodString];
                IXEvalShortCode* evalShortCode = [[IXEvalShortCode alloc] initWithRawValue:nil objectID:nil methodName:nil functionName:nil parameters:@[evalPropertyValue]];
                returnShortCode = evalShortCode;
            }
            else
            {
                NSString* objectID = nil;
                NSString* methodName = nil;
                NSString* functionName = nil;
                NSMutableArray* parameters = nil;
                
                NSMutableArray* objectIDWithMethodStringComponents = [NSMutableArray arrayWithArray:[objectIDWithMethodString componentsSeparatedByString:kIXPeriodString]];
                objectID = [objectIDWithMethodStringComponents firstObject];
                
                [objectIDWithMethodStringComponents removeObject:objectID];
                if( [objectIDWithMethodStringComponents count] )
                {
                    methodName = [objectIDWithMethodStringComponents componentsJoinedByString:kIXPeriodString];
                }
                
                if( validRangesCount >= 4 )
                {
                    functionName = [originalString substringWithRange:[[validRanges objectAtIndex:3] rangeValue]];
                    if( validRangesCount >= 5 )
                    {
                        NSString* rawParameterString = [originalString substringWithRange:[[validRanges objectAtIndex:4] rangeValue]];
                        NSArray* parameterStrings = [rawParameterString componentsSeparatedByString:kIXCommaString];
                        for( NSString* parameter in parameterStrings )
                        {
                            IXProperty* parameterProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:parameter];
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
                }
                
                Class shortCodeClass = NSClassFromString([NSString stringWithFormat:kIXShortCodeClassFormat,[objectID capitalizedString]]);
                if( !shortCodeClass )
                {
                    // If the class doesn't exist this must be a Get shortcode.
                    shortCodeClass = [IXGetShortCode class];
                }
                else
                {
                    // If the class did exist then the objectID was really just the class of the shortcode in which case the objectID is not needed anymore.
                    objectID = nil;
                }
                
                if( shortCodeClass )
                {
                    returnShortCode = [[shortCodeClass alloc] initWithRawValue:rawValue objectID:objectID methodName:methodName functionName:functionName  parameters:parameters];
                }
            }
        }
    }
    return returnShortCode;
}

+(void)parseIXPropertyIntoComponents:(IXProperty*)property
{
    NSString* propertiesStaticText = [[property originalString] copy];
    if( propertiesStaticText )
    {
        static NSRegularExpression *shortCodeMainComponentsRegex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError* __autoreleasing error = nil;
            shortCodeMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXShortcodeRegexString
                                                                                options:NSRegularExpressionDotMatchesLineSeparators
                                                                                  error:&error];
            if( error )
                DDLogError(@"Critical Error!!! Shortcode regex invalid with error: %@.",[error description]);
        });
        
        NSArray* matchesInStaticText = [shortCodeMainComponentsRegex matchesInString:propertiesStaticText
                                                                             options:0
                                                                               range:NSMakeRange(0, [propertiesStaticText length])];
        if( [matchesInStaticText count] )
        {
            __block NSUInteger numberOfCharactersRemoved = 0;
            __block NSMutableArray* propertiesShortCodes = nil;
            __block NSMutableString* mutableStaticText = [[NSMutableString alloc] initWithString:propertiesStaticText];
            
            [matchesInStaticText enumerateObjectsUsingBlock:^(NSTextCheckingResult* matchInShortCodeString, NSUInteger idx, BOOL *stop) {
                
                IXBaseShortCode* shortCode = [IXPropertyParser parseShortCodeFromTextCheckingResult:matchInShortCodeString
                                                                                 withOriginalString:propertiesStaticText];
                if( shortCode )
                {
                    [shortCode setProperty:property];
                    
                    if( !propertiesShortCodes )
                    {
                        propertiesShortCodes = [[NSMutableArray alloc] init];
                    }
                    
                    NSRange shortCodeRange = [matchInShortCodeString rangeAtIndex:0];
                    [propertiesShortCodes addObject:shortCode];
                    [shortCode setRangeInPropertiesText:shortCodeRange];
                    
                    shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                    [mutableStaticText replaceCharactersInRange:shortCodeRange withString:kIXEmptyString];
                    numberOfCharactersRemoved += shortCodeRange.length;
                }
            }];
            
            [property setStaticText:mutableStaticText];
            [property setShortCodes:propertiesShortCodes];
        }
        else
        {
            [property setStaticText:propertiesStaticText];
            [property setShortCodes:nil];
        }
    }
}

@end
