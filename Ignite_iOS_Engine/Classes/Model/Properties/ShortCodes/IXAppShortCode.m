//
//  IXAppShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppShortCode.h"

#import "IXProperty.h"
#import "IXBaseObject.h"

@implementation IXAppShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        propertyName = [parameterProperty getPropertyValue];
    }
    
    if( [propertyName hasPrefix:@"random_number"] )
    {
        NSUInteger upperBound = 100;
        NSArray* stringArray = [propertyName componentsSeparatedByString:@"."];
        if( [stringArray count] > 1 )
        {
            upperBound = [[stringArray lastObject] intValue];
        }
        returnValue = [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)upperBound)];
    }
    
    return returnValue;
}

-(BOOL)valueIsNeverGoingToChange
{
    return NO;
}

@end
