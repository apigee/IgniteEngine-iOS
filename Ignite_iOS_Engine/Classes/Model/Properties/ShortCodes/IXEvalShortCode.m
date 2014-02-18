//
//  IXEvalShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXEvalShortCode.h"

#import "IXAppManager.h"
#import "IXProperty.h"

@implementation IXEvalShortCode

-(NSString*)evaluate
{
    NSString* stringToEval = [self methodName];
    if( !stringToEval )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        stringToEval = [parameterProperty getPropertyValue];
    }
    return [[IXAppManager sharedAppManager] evaluateJavascript:stringToEval];
}

@end
