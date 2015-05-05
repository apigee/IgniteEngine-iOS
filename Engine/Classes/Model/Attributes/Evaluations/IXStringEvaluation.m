//
//  IXStringVariable.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 5/1/15.
//  Copyright (c) 2015 Apigee Inc. All rights reserved.
//

#import "IXStringEvaluation.h"

#import "IXBaseObject.h"
#import "IXAttribute.h"
#import "IXAttributeContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLayout.h"

@implementation IXStringEvaluation

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    returnValue = [self rawString];
    
    return returnValue;
}

@end
