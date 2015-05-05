//
//  IXEvalVariable.m
//  Ignite Engine
//
//  Created by Robert Walsh on 1/24/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXJavascriptEvaluation.h"

#import "IXAppManager.h"
#import "IXAttribute.h"

@implementation IXJavascriptEvaluation

-(NSString*)evaluate
{
    NSString* stringToEval = nil;
    if( [[self parameters] count] )
    {
        IXAttribute* parameterProperty = (IXAttribute*)[[self parameters] firstObject];
        stringToEval = [parameterProperty attributeStringValue];
    }
    return [[IXAppManager sharedAppManager] evaluateJavascript:stringToEval];
}

@end
