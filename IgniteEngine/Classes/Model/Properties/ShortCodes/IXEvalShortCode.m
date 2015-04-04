//
//  IXEvalShortCode.m
//  Ignite Engine
//
//  Created by Robert Walsh on 1/24/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXEvalShortCode.h"

#import "IXAppManager.h"
#import "IXProperty.h"

@implementation IXEvalShortCode

-(NSString*)evaluate
{
    NSString* stringToEval = nil;
    if( [[self parameters] count] )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        stringToEval = [parameterProperty getPropertyValue];
    }
    return [[IXAppManager sharedAppManager] evaluateJavascript:stringToEval];
}

@end
