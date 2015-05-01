//
//  IXBaseVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseVariable.h"
#import "IXProperty.h"
#import "IXEvalVariable.h"
#import "IXGetVariable.h"
#import "IXStringVariable.h"
#import "IXVariableFunction.h"
#import "NSString+IXAdditions.h"
#import "IXSandbox.h"
#import "IXLogger.h"
#import "IXAppVariable.h"

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

@implementation IXBaseVariable

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                     rawString:(NSString*)rawString
                   functionName:(NSString*)functionName
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
        
        [self setFunctionName:functionName];
    }
    return self;
}



-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRawValue:[self rawValue]
                                                      objectID:[self objectID]
                                                    methodName:[self methodName]
                                                    rawString:[self rawString]
                                                  functionName:[self functionName]
                                                    parameters:[[NSArray alloc] initWithArray:[self parameters] copyItems:YES]
                                         rangeInPropertiesText:[self rangeInPropertiesText]];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self rawValue] forKey:kIXRawValueNSCodingKey];
    [aCoder encodeObject:[self objectID] forKey:kIXObjectIDNSCodingKey];
    [aCoder encodeObject:[self methodName] forKey:kIXMethodNameNSCodingKey];
    [aCoder encodeObject:[self functionName] forKey:kIXFunctionNameNSCodingKey];
    [aCoder encodeObject:[self parameters] forKey:kIXParametersNSCodingKey];
    [aCoder encodeObject:[NSValue valueWithRange:[self rangeInPropertiesText]] forKey:kIXRangeInPropertiesTextNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithRawValue:[aDecoder decodeObjectForKey:kIXRawValueNSCodingKey]
                         objectID:[aDecoder decodeObjectForKey:kIXObjectIDNSCodingKey]
                       methodName:[aDecoder decodeObjectForKey:kIXMethodNameNSCodingKey]
                       rawString:[aDecoder decodeObjectForKey:kIXRawStringNSCodingKey]
                     functionName:[aDecoder decodeObjectForKey:kIXFunctionNameNSCodingKey]
                       parameters:[aDecoder decodeObjectForKey:kIXParametersNSCodingKey]
            rangeInPropertiesText:[[aDecoder decodeObjectForKey:kIXRangeInPropertiesTextNSCodingKey] rangeValue]];
}

+(instancetype)variableFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult
{
    IXBaseVariable* returnVariable = nil;
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
                returnVariable = [[IXEvalVariable alloc] initWithRawValue:nil
                                                                   objectID:nil
                                                                 methodName:nil
                                                                 rawString:nil
                                                               functionName:nil
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
                
                Class variableClass;
                // Try to find the class by removing the $. Basically used for app variables but maybe even network and device if people mess up.
                if ([objectID hasPrefix:@"$"] && objectID.length > 1) {
                    variableClass = NSClassFromString([NSString stringWithFormat:kIX_VARIABLE_CLASS_NAME_FORMAT,[[objectID substringFromIndex:1] capitalizedString]]);
                } else {
                    variableClass = NSClassFromString([NSString stringWithFormat:kIX_VARIABLE_CLASS_NAME_FORMAT,[objectID capitalizedString]]);
                }
                
                if( stringObject )
                {
                    variableClass = [IXStringVariable class];
                }
                
                if( !variableClass )
                {
                    variableClass = [IXGetVariable class];
                }
                else
                {
                    // If the class did exist then the objectID was really just the class of the variable in which case the objectID is not needed anymore.
                    objectID = nil;
                }
                
                if( [variableClass isSubclassOfClass:[IXBaseVariable class]] )
                {
                    returnVariable = [[variableClass alloc] initWithRawValue:rawValue
                                                objectID:objectID
                                                methodName:methodName
                                                rawString:stringObject
                                                functionName:functionName
                                                parameters:parameters
                                                rangeInPropertiesText:[textCheckingResult rangeAtIndex:0]];
                }
                
            }
        }
    }
    return returnVariable;
}

-(NSString*)evaluateAndApplyFunction
{
    NSString* returnValue = [self evaluate];
    IXBaseVariableFunction variableFunction = [self variableFunction];
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

-(void)setFunctionName:(NSString *)functionName
{
    _functionName = [functionName copy];
    _variableFunction = nil;
    if( [_functionName length] > 0 ) {
        
        _variableFunction = [IXVariableFunction variableFunctionWithName:_functionName];
        if( _variableFunction == nil ) {
            IX_LOG_DEBUG(@"ERROR: Unknown short-code function with name: %@", _functionName);
        }
    }
}

@end
