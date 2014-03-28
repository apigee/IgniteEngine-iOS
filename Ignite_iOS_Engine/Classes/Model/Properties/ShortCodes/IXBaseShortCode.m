//
//  IXBaseShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseShortCode.h"
#import "IXProperty.h"
#import "IXBaseObject.h"
#import "IXEvalShortCode.h"
#import "IXGetShortCode.h"
#import "NSString+IXAdditions.h"

static NSString* const kIXIsEmpty = @"is_empty";
static IXBaseShortCodeFunction const kIXIsEmptyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:[stringToModify isEqualToString:kIX_EMPTY_STRING]];
};
static NSString* const kIXIsNil = @"is_nil";
static IXBaseShortCodeFunction const kIXIsNilFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:(stringToModify == nil)];
};
static NSString* const kIXToUppercase = @"to_uppercase";
static IXBaseShortCodeFunction const kIXToUppercaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify uppercaseString];
};
static NSString* const kIXToLowercase = @"to_lowercase";
static IXBaseShortCodeFunction const kIXToLowerCaseFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify lowercaseString];
};
static NSString* const kIXCapitalize = @"capitalize";
static IXBaseShortCodeFunction const kIXCapitalizeFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [stringToModify capitalizedString];
};
static NSString* const kIXLength = @"length";
static IXBaseShortCodeFunction const kIXLengthFunction = ^NSString*(NSString* stringToEvaluate,NSArray* parameters){
    return [NSString stringWithFormat:@"%lu", (unsigned long)[stringToEvaluate length]];
};
static NSString* const kIXTruncate = @"truncate";
static IXBaseShortCodeFunction const kIXTruncateFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    if ([parameters firstObject] != nil) {
        return [NSString ix_truncateString:stringToModify toIndex:[[parameters.firstObject getPropertyValue] intValue]];
    } else {
        return stringToModify;
    }
};
static NSString* const kIXMonogram = @"monogram";
static IXBaseShortCodeFunction const kIXMonogramFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    if ([parameters firstObject] != nil) {
        return [NSString ix_monogramString:stringToModify ifLengthIsGreaterThan:[[parameters.firstObject getPropertyValue] intValue]];
    } else {
        return [NSString ix_monogramString:stringToModify ifLengthIsGreaterThan:0];
    }
};

NSArray* ix_ValidRangesFromTextCheckingResult(NSTextCheckingResult* textCheckingResult)
{
    NSMutableArray* validRanges = [NSMutableArray array];
    NSUInteger numberOfRanges = [textCheckingResult numberOfRanges];
    for( int i = 0; i < numberOfRanges; i++)
    {
        NSRange range = [textCheckingResult rangeAtIndex:i];
        if( range.location != NSNotFound )
        {
            [validRanges addObject:[NSValue valueWithRange:range]];
        }
    }
    return validRanges;
}

@implementation IXBaseShortCode

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                   functionName:(NSString*)functionName
                     parameters:(NSArray*)parameters
{
    self = [super init];
    if( self )
    {
        _rawValue = [rawValue copy];
        _objectID = [objectID copy];
        _methodName = [methodName copy];
        _parameters = parameters;
        
        [self setFunctionName:functionName];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseShortCode* copy = [[[self class] allocWithZone:zone] initWithRawValue:[self rawValue]
                                                                       objectID:[self objectID]
                                                                     methodName:[self methodName]
                                                                   functionName:[self functionName]
                                                                     parameters:[[NSArray alloc] initWithArray:[self parameters] copyItems:YES]];
    [copy setRangeInPropertiesText:[self rangeInPropertiesText]];
    return copy;
}

+(instancetype)shortCodeFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult
{
    IXBaseShortCode* returnShortCode = nil;
    if( textCheckingResult )
    {
        NSArray* validRanges = ix_ValidRangesFromTextCheckingResult(textCheckingResult);
        
        NSUInteger validRangesCount = [validRanges count];
        if( validRangesCount >= 3 )
        {
            NSString* rawValue = [checkedString substringWithRange:[[validRanges firstObject] rangeValue]];
            NSString* objectIDWithMethodString = [checkedString substringWithRange:[[validRanges objectAtIndex:2] rangeValue]];
            
            if( [rawValue hasPrefix:kIX_EVAL_BRACKETS] )
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
                
                NSMutableArray* objectIDWithMethodStringComponents = [NSMutableArray arrayWithArray:[objectIDWithMethodString componentsSeparatedByString:kIX_PERIOD_SEPERATOR]];
                objectID = [objectIDWithMethodStringComponents firstObject];
                
                [objectIDWithMethodStringComponents removeObject:objectID];
                if( [objectIDWithMethodStringComponents count] )
                {
                    methodName = [objectIDWithMethodStringComponents componentsJoinedByString:kIX_PERIOD_SEPERATOR];
                }
                
                if( validRangesCount >= 4 )
                {
                    functionName = [checkedString substringWithRange:[[validRanges objectAtIndex:3] rangeValue]];
                    if( validRangesCount >= 5 )
                    {
                        NSString* rawParameterString = [checkedString substringWithRange:[[validRanges objectAtIndex:4] rangeValue]];
                        NSArray* parameterStrings = [rawParameterString componentsSeparatedByString:kIX_COMMA_SEPERATOR];
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
                
                Class shortCodeClass = NSClassFromString([NSString stringWithFormat:kIX_SHORTCODE_CLASS_NAME_FORMAT,[objectID capitalizedString]]);
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
                
                if( [shortCodeClass isSubclassOfClass:[IXBaseShortCode class]] )
                {
                    returnShortCode = [[shortCodeClass alloc] initWithRawValue:rawValue
                                                                      objectID:objectID
                                                                    methodName:methodName
                                                                  functionName:functionName
                                                                    parameters:parameters];
                    
                    [returnShortCode setRangeInPropertiesText:[textCheckingResult rangeAtIndex:0]];
                }
            }
        }
    }
    return returnShortCode;
}

-(NSString*)evaluateAndApplyFunction
{
    NSString* returnValue = [self evaluate];
    IXBaseShortCodeFunction shortCodeFunction = [self shortCodeFunction];
    if( shortCodeFunction )
    {
        returnValue = shortCodeFunction(returnValue,[self parameters]);
    }
    return returnValue;
}

-(NSString*)evaluate
{
    return [self rawValue];
}

-(void)setFunctionName:(NSString *)functionName
{
    _functionName = [functionName copy];
    
    IXBaseShortCodeFunction shortCodeFunction = nil;
    if( [_functionName length] > 0 )
    {
        if( [functionName isEqualToString:kIXIsEmpty] ){
            shortCodeFunction = kIXIsEmptyFunction;
        } else if( [functionName isEqualToString:kIXIsNil] ) {
            shortCodeFunction = kIXIsNilFunction;
        } else if( [functionName isEqualToString:kIXLength] ) {
            shortCodeFunction = kIXLengthFunction;
        } else if( [functionName isEqualToString:kIXTruncate] ) {
            shortCodeFunction = kIXTruncateFunction;
        } else if( [functionName isEqualToString:kIXMonogram] ) {
            shortCodeFunction = kIXMonogramFunction;
        } else if( [functionName isEqualToString:kIXToLowercase] ){
            shortCodeFunction = kIXToLowerCaseFunction;
        } else if( [functionName isEqualToString:kIXToUppercase] ) {
            shortCodeFunction = kIXToUppercaseFunction;
        } else if( [functionName isEqualToString:kIXCapitalize] ) {
            shortCodeFunction = kIXCapitalizeFunction;
        }
    }
    [self setShortCodeFunction:shortCodeFunction];
}

@end
