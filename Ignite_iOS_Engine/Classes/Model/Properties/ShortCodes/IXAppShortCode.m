//
//  IXAppShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXAppShortCode.h"

#define RF_NSStringFromBOOL(aBOOL) aBOOL? @"YES" : @"NO"

@implementation IXAppShortCode

-(NSString*)evaluate
{
    return RF_NSStringFromBOOL(NO);
}

-(BOOL)valueIsNeverGoingToChange
{
    return NO;
}

@end
