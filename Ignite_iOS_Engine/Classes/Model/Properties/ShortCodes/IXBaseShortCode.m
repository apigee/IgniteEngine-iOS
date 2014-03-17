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
#import "NSString+IXAdditions.h"

static NSString* const kIXIsEmpty = @"is_empty";
static IXBaseShortCodeFunction const kIXIsEmptyFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:[stringToModify isEqualToString:@""]];
};
static NSString* const kIXIsNil = @"is_nil";
static IXBaseShortCodeFunction const kIXIsNilFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    return [NSString ix_stringFromBOOL:(stringToModify == nil)];
};
static NSString* const kIXTruncate = @"truncate";
static IXBaseShortCodeFunction const kIXTruncateFunction = ^NSString*(NSString* stringToModify,NSArray* parameters){
    if (parameters.firstObject != nil)
        return [NSString ix_truncateString:stringToModify toIndex:[parameters.firstObject intValue]];
    else
        return stringToModify;
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

@implementation IXBaseShortCode

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                   functionName:(NSString*)functionName
                     parameters:(NSArray*)parameters
{
    self = [self init];
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

+(instancetype)shortCodeWithRawValue:(NSString*)rawValue
                            objectID:(NSString*)objectID
                          methodName:(NSString*)methodName
                        functionName:(NSString*)functionName
                          parameters:(NSArray*)parameters
{
    return [[[self class] alloc] initWithRawValue:rawValue objectID:objectID methodName:methodName functionName:functionName parameters:parameters];
}

-(id)copyWithZone:(NSZone *)zone
{
    IXBaseShortCode* copy = [[[self class] allocWithZone:zone] initWithRawValue:[self rawValue]
                                                                       objectID:[self objectID]
                                                                     methodName:[self methodName]
                                                                   functionName:[self functionName]
                                                                     parameters:[[NSArray alloc] initWithArray:[self parameters] copyItems:YES]];
    [copy setRangeInPropertiesText:[self rangeInPropertiesText]];
    return copy;
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
