//
//  IXNetworkShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXNetworkShortCode.h"

#import "IXAppManager.h"
#import "IXProperty.h"
#import "Reachability.h"
#import "NSString+IXAdditions.h"

@implementation IXNetworkShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        propertyName = [parameterProperty getPropertyValue];
    }
    
    Reachability* reachability = [[IXAppManager sharedAppManager] reachabilty];
    if( [propertyName isEqualToString:@"reachable"] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachable]];
    }
    else if( [propertyName isEqualToString:@"reachable.wifi"] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachableViaWiFi]];
    }
    else if( [propertyName isEqualToString:@"reachable.wwan"] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachableViaWWAN]];
    }
    
    return returnValue;
}

@end
