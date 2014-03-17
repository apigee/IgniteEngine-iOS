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
        _functionName = [functionName copy];
        _methodName = [methodName copy];
        _parameters = parameters;
    }
    return self;
}

+(IXBaseShortCode*)shortCodeWithRawValue:(NSString*)rawValue
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

-(NSString*)evaluate
{
    return [self rawValue];
}

-(NSString*)applyFunctionToString:(NSString*)stringToModify
{
    NSString* returnValue = stringToModify;
    NSString* functionName = [self functionName];
    if( functionName )
    {
        if( [[self functionName] isEqualToString:@"is_empty"] )
        {
            returnValue = [NSString ix_stringFromBOOL:[stringToModify isEqualToString:@""]];
        }
        else if( [[self functionName] isEqualToString:@"is_nil"] )
        {
            returnValue = [NSString ix_stringFromBOOL:(stringToModify == nil)];
        }
        else if( [functionName isEqualToString:@"to_lowercase"] )
        {
            returnValue = [stringToModify lowercaseString];
        }
        else if( [functionName isEqualToString:@"to_uppercase"] )
        {
            returnValue = [stringToModify uppercaseString];
        }
        else if( [functionName isEqualToString:@"capitalize"] )
        {
            returnValue = [stringToModify capitalizedString];
        }
    }
    return returnValue;
}

@end
