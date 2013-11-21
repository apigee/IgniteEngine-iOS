//
//  ixeBaseShortCode.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseShortCode.h"

@implementation ixeBaseShortCode

-(id)init
{
    return [self initWithRawValue:nil];
}

+(instancetype)shortCodeWithRawValue:(NSString*)rawValue;
{
    return [[self alloc] initWithRawValue:rawValue];
}

-(id)initWithRawValue:(NSString*)rawValue
{
    self = [super init];
    if( self )
    {
        _rawValue = [rawValue copy];
    }
    return self;
}

-(void)parseRawValue
{
    if( [self rawValue] == nil )
        return;
    
    
    
    // Do parse here and set the methodName and parameters
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
