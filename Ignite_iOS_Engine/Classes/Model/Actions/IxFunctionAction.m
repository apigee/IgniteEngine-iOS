//
//  IxFunctionAction.m
//  Ixgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxFunctionAction.h"

#import "IxPropertyContainer.h"
#import "IxSandbox.h"
#import "IxBaseControl.h"
#import "IxActionContainer.h"
#import "IxBaseDataprovider.h"

@implementation IxFunctionAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:@"function_name" defaultValue:nil];
    
    if( objectID != nil && functionName != nil )
    {
        NSArray* controlsToFireFunctionOn = [[[[self actionContainer] sandbox] containerControl] childrenWithID:objectID];        
        for( IxBaseControl* control in controlsToFireFunctionOn )
        {
            [control applyFunction:functionName withParameters:[self parameterProperties]];
        }
        
        NSArray* dataSourcesToFireFunctionOn = nil;
        for( IxBaseDataprovider* dataProvider in dataSourcesToFireFunctionOn )
        {
            [dataProvider applyFunction:functionName withParameters:[self parameterProperties]];
        }
    }
}

@end
