//
//  ixeAppShortCode.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeAppShortCode.h"

#define RF_NSStringFromBOOL(aBOOL) aBOOL? @"YES" : @"NO"

@implementation ixeAppShortCode

-(NSString*)evaluate
{
    return RF_NSStringFromBOOL(NO);
}

-(BOOL)valueIsNeverGoingToChange
{
    return NO;
}

@end
