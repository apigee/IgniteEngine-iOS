//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

@implementation NSString (IXAdditions)

+(NSString*)stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? @"YES" : @"NO";
}

@end
