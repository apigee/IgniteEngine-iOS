//
//  IXNetworkVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 3/11/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
