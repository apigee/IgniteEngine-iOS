//
//  IXBaseEvaluation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseEvaluation.h"
#import "IXAttribute.h"
#import "IXJavascriptEvaluation.h"
#import "IXGetEvaluation.h"
#import "IXStringEvaluation.h"
#import "IXEvaluationUtility.h"
#import "NSString+IXAdditions.h"
#import "IXSandbox.h"
#import "IXLogger.h"
#import "IXAppEvaluation.h"

// NSCoding Key Constants
static NSString* const kIXRawValueNSCodingKey = @"rawValue";
static NSString* const kIXObjectIDNSCodingKey = @"objectID";
// TODO: Suggest "method" and "function"
static NSString* const kIXMethodNameNSCodingKey = @"methodName";
static NSString* const kIXFunctionNameNSCodingKey = @"functionName";
static NSString* const kIXRawStringNSCodingKey = @"rawString";
static NSString* const kIXParametersNSCodingKey = @"parameters";
static NSString* const kIXRangeInPropertiesTextNSCodingKey = @"rangeInPropertiesText";

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

@implementation IXBaseEvaluation

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                     rawString:(NSString*)rawString
                   utilityName:(NSString*)utilityName
                     parameters:(NSArray*)parameters
          rangeInPropertiesText:(NSRange)rangeInPropertiesText
{
    self = [super init];
    if( self )
    {
        _rawValue = [rawValue copy];
        _objectID = [objectID copy];
        _methodName = [methodName copy];
        _rawString = [rawString copy];
        _parameters = parameters;
        _rangeInPropertiesText = rangeInPropertiesText;
        [self setEvaluationUtilityName:utilityName];
    }
    return self;
}



-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRawValue:[self rawValue]
                                                      objectID:[self objectID]
                                                    methodName:[self methodName]
                                                    rawString:[self rawString]
                                                  utilityName:[self evaluationUtilityName]
                                                    parameters:[[NSArray alloc] initWithArray:[self parameters] copyItems:YES]
                                         rangeInPropertiesText:[self rangeInPropertiesText]];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self rawValue] forKey:kIXRawValueNSCodingKey];
    [aCoder encodeObject:[self objectID] forKey:kIXObjectIDNSCodingKey];
    [aCoder encodeObject:[self methodName] forKey:kIXMethodNameNSCodingKey];
    [aCoder encodeObject:[self evaluationUtilityName] forKey:kIXFunctionNameNSCodingKey];
    [aCoder encodeObject:[self parameters] forKey:kIXParametersNSCodingKey];
    [aCoder encodeObject:[NSValue valueWithRange:[self rangeInPropertiesText]] forKey:kIXRangeInPropertiesTextNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithRawValue:[aDecoder decodeObjectForKey:kIXRawValueNSCodingKey]
                         objectID:[aDecoder decodeObjectForKey:kIXObjectIDNSCodingKey]
                       methodName:[aDecoder decodeObjectForKey:kIXMethodNameNSCodingKey]
                       rawString:[aDecoder decodeObjectForKey:kIXRawStringNSCodingKey]
                     utilityName:[aDecoder decodeObjectForKey:kIXFunctionNameNSCodingKey]
                       parameters:[aDecoder decodeObjectForKey:kIXParametersNSCodingKey]
            rangeInPropertiesText:[[aDecoder decodeObjectForKey:kIXRangeInPropertiesTextNSCodingKey] rangeValue]];
}

+(instancetype)evaluationFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult
{
    IXBaseEvaluation* returnEvaluation = nil;
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
                IXAttribute* evalPropertyValue = [[IXAttribute alloc] initWithAttributeName:nil rawValue:objectIDWithMethodString];
                returnEvaluation = [[IXJavascriptEvaluation alloc] initWithRawValue:nil
                                                                   objectID:nil
                                                                 methodName:nil
                                                                 rawString:nil
                                                               utilityName:nil
                                                                 parameters:@[evalPropertyValue]
                                                      rangeInPropertiesText:[textCheckingResult rangeAtIndex:0]];
            }
            else
            {
                NSString* objectID = nil;
                NSString* methodName = nil;
                NSString* functionName = nil;
                NSMutableArray* parameters = nil;
                NSString* methodNameTest = nil;
                NSString* stringObject = nil;
                
                NSMutableArray* objectIDWithMethodStringComponents = [NSMutableArray arrayWithArray:[objectIDWithMethodString componentsSeparatedByString:kIX_PERIOD_SEPERATOR]];
                objectID = [objectIDWithMethodStringComponents firstObject];
                
                [objectIDWithMethodStringComponents removeObject:objectID];
                if( [objectIDWithMethodStringComponents count] )
                {
                    methodName = [objectIDWithMethodStringComponents componentsJoinedByString:kIX_PERIOD_SEPERATOR];
                }

                if( !methodName )
                {
                    
                    NSMutableArray* objectIDWithMethodStringComponentsTest = [NSMutableArray arrayWithArray:[objectIDWithMethodString componentsSeparatedByString:kIX_QUOTE_SEPERATOR]];
                    
                    methodNameTest = [objectIDWithMethodStringComponentsTest componentsJoinedByString:kIX_QUOTE_SEPERATOR];
                    stringObject = [objectIDWithMethodStringComponentsTest objectAtIndex:1];

                }
                
                if( validRangesCount >= 4 )
                {
                    functionName = [checkedString substringWithRange:[[validRanges objectAtIndex:3] rangeValue]];
                    if( validRangesCount >= 5 )
                    {
                        NSString* rawParameterString = [checkedString substringWithRange:[[validRanges objectAtIndex:4] rangeValue]];
                        NSArray* parameterStrings;
                        // Checks for pipe first, if no pipe, falls back to comma (need this for date formatting for example)
                        if ([rawParameterString containsSubstring:kIX_PIPE_SEPERATOR options:NO])
                        {
                            parameterStrings = [rawParameterString componentsSeparatedByString:kIX_PIPE_SEPERATOR];
                        }
                        else
                        {
                            parameterStrings = [rawParameterString componentsSeparatedByString:kIX_COMMA_SEPERATOR];
                        }
                        
                        for( NSString* parameter in parameterStrings )
                        {
                            IXAttribute* parameterProperty = [[IXAttribute alloc] initWithAttributeName:nil rawValue:parameter];
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
                
                Class variableClass;
                // Try to find the class by removing the $. Used for app evaluations but maybe even network and device if people mess up.
                if ([objectID hasPrefix:@"$"] && objectID.length > 1) {
                    variableClass = NSClassFromString([NSString stringWithFormat:kIX_VARIABLE_CLASS_NAME_FORMAT,[[objectID substringFromIndex:1] capitalizedString]]);
                } else {
                    variableClass = NSClassFromString([NSString stringWithFormat:kIX_VARIABLE_CLASS_NAME_FORMAT,[objectID capitalizedString]]);
                }
                
                if( stringObject )
                {
                    variableClass = [IXStringEvaluation class];
                }
                
                if( !variableClass )
                {
                    variableClass = [IXGetEvaluation class];
                }
                else
                {
                    // If the class did exist then the objectID was really just the class of the variable in which case the objectID is not needed anymore.
                    objectID = nil;
                }
                
                if( [variableClass isSubclassOfClass:[IXBaseEvaluation class]] )
                {
                    returnEvaluation = [[variableClass alloc] initWithRawValue:rawValue
                                                objectID:objectID
                                                methodName:methodName
                                                rawString:stringObject
                                                utilityName:functionName
                                                parameters:parameters
                                                rangeInPropertiesText:[textCheckingResult rangeAtIndex:0]];
                }
                
            }
        }
    }
    return returnEvaluation;
}

-(NSString*)evaluateAndApplyFunction
{
    NSString* returnValue = [self evaluate];
    IXBaseEvaluationUtility variableFunction = [self evaluationUtility];
    if( variableFunction )
    {
        returnValue = variableFunction(returnValue,[self parameters]);
    }
    return returnValue;
}

-(NSString*)evaluate
{
    return [self rawValue];
}

-(void)setEvaluationUtilityName:(NSString *)functionName
{
    _evaluationUtilityName = [functionName copy];
    _evaluationUtility = nil;
    if( [_evaluationUtilityName length] > 0 ) {
        
        _evaluationUtility = [IXEvaluationUtility evaluationUtilityWithName:_evaluationUtilityName];
        if( _evaluationUtility == nil ) {
            IX_LOG_DEBUG(@"ERROR: Unknown short-code function with name: %@", _evaluationUtilityName);
        }
    }
}

@end
