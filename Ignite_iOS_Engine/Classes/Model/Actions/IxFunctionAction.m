//
//  IXFunctionAction.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXFunctionAction.h"

#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXBaseDataprovider.h"

@implementation IXFunctionAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:@"function_name" defaultValue:nil];
    
    if( objectID != nil && functionName != nil )
    {
        NSArray* controlsToFireFunctionOn = [[[[self actionContainer] sandbox] containerControl] childrenWithID:objectID];        
        for( IXBaseControl* control in controlsToFireFunctionOn )
        {
            [control applyFunction:functionName withParameters:[self parameterProperties]];
        }
        
        NSArray* dataSourcesToFireFunctionOn = nil;
        for( IXBaseDataprovider* dataProvider in dataSourcesToFireFunctionOn )
        {
            [dataProvider applyFunction:functionName withParameters:[self parameterProperties]];
        }
    }
}

@end
