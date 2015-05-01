//
//  IXStringShortCode.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/21/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

#import "IXStringShortCode.h"

#import "IXBaseObject.h"
#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLayout.h"

@implementation IXStringShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    returnValue = [self rawString];
    
    return returnValue;
}

@end
