//
//  IXNetworkVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 3/11/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXNetworkEvaluation.h"

#import "IXAppManager.h"
#import "IXConstants.h"
#import "IXAttribute.h"
#import "Reachability.h"
#import "NSString+IXAdditions.h"

// Reachability
IX_STATIC_CONST_STRING kIXReachable = @"isReachable";
IX_STATIC_CONST_STRING kIXReachableWifi = @"isReachable.wifi";
IX_STATIC_CONST_STRING kIXReachableWwan = @"isReachable.wwan";

@implementation IXNetworkEvaluation

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXAttribute* parameterProperty = (IXAttribute*)[[self parameters] firstObject];
        propertyName = [parameterProperty attributeStringValue];
    }
    
    Reachability* reachability = [[IXAppManager sharedAppManager] reachabilty];
    if( [propertyName isEqualToString:kIXReachable] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachable]];
    }
    else if( [propertyName isEqualToString:kIXReachableWifi] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachableViaWiFi]];
    }
    else if( [propertyName isEqualToString:kIXReachableWwan] )
    {
        returnValue = [NSString ix_stringFromBOOL:[reachability isReachableViaWWAN]];
    }
    
    return returnValue;
}

@end
