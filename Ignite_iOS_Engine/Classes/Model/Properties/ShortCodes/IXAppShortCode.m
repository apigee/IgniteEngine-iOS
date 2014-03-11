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
#import "IXAppManager.h"

//usage: [[app:random_number(40)]]

static NSString* const kIXRandomNumber = @"random_number";

@implementation IXAppShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    if( [[self functionName] isEqualToString:kIXRandomNumber] )
    {
        NSUInteger upperBound = [[[[self parameters] firstObject] getPropertyValue] integerValue];
        returnValue = [NSString stringWithFormat:@"%i",arc4random_uniform((u_int32_t)upperBound)];
    }
    else
    {
        returnValue = [[[IXAppManager sharedAppManager] appProperties] getStringPropertyValue:[self methodName] defaultValue:nil];
        returnValue = [self applyFunctionToString:returnValue];
    }
    
    return returnValue;
}

@end
