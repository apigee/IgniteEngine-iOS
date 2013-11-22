//
//  IXBaseShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
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

+(IXBaseShortCode*)shortCodeWithRawValue:(NSString*)rawValue
                                 objectID:(NSString*)objectID
                               methodName:(NSString*)methodName
                               parameters:(NSArray*)parameters
{
    IXBaseShortCode* shortCode = nil;
    NSString* shortCodeClassName = [NSString stringWithFormat:@"IX%@ShortCode",[methodName capitalizedString]];
    Class shortCodeClass = NSClassFromString(shortCodeClassName);
    if( shortCodeClass != nil )
    {
        shortCode = [[shortCodeClass alloc] init];
        [shortCode setRawValue:rawValue];
        [shortCode setObjectID:objectID];
        [shortCode setMethodName:methodName];
        [shortCode setParameters:parameters];
    }
    return shortCode;
}

-(id)copyWithZone:(NSZone *)zone
{
    return [IXBaseShortCode shortCodeWithRawValue:[self rawValue]
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
