//
//  IxAppShortCode.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxAppShortCode.h"

#define RF_NSStringFromBOOL(aBOOL) aBOOL? @"YES" : @"NO"

@implementation IxAppShortCode

-(NSString*)evaluate
{
    return RF_NSStringFromBOOL(NO);
}

-(BOOL)valueIsNeverGoingToChange
{
    return NO;
}

@end
