//
//  IXBaseShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseShortCode.h"
#import "IXProperty.h"

@implementation IXBaseShortCode

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        
    }
    return self;
}

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                     parameters:(NSArray*)parameters
{
    self = [self init];
    if( self )
    {
        _rawValue = [rawValue copy];
        _objectID = [objectID copy];
        _methodName = [methodName copy];
        _parameters = parameters;
    }
    return self;
}

+(IXBaseShortCode*)shortCodeWithRawValue:(NSString*)rawValue
                                objectID:(NSString*)objectID
                              methodName:(NSString*)methodName
                              parameters:(NSArray*)parameters
{
    return [[[self class] alloc] initWithRawValue:rawValue objectID:objectID methodName:methodName parameters:parameters];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRawValue:[self rawValue]
                                                      objectID:[self objectID]
                                                    methodName:[self methodName]
                                                    parameters:[self parameters]];
}

-(NSString*)evaluate
{
    return [self rawValue];
}

-(BOOL)valueIsNeverGoingToChange
{
    return NO;
}

@end
