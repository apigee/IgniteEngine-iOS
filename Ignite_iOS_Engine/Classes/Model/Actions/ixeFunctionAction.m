//
//  ixeFunctionAction.m
//  ixegee_iOS_Engine
//
//  Created by Robert Walsh on 11/17.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeFunctionAction.h"

#import "ixePropertyContainer.h"
#import "ixeSandbox.h"
#import "ixeBaseControl.h"
#import "ixeActionContainer.h"
#import "ixeBaseDataprovider.h"

@implementation ixeFunctionAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:@"function_name" defaultValue:nil];
    
    if( objectID != nil && functionName != nil )
    {
        NSArray* controlsToFireFunctionOn = [[[[self actionContainer] sandbox] containerControl] childrenWithID:objectID];        
        for( ixeBaseControl* control in controlsToFireFunctionOn )
        {
            [control applyFunction:functionName withParameters:[self parameterProperties]];
        }
        
        NSArray* dataSourcesToFireFunctionOn = nil;
        for( ixeBaseDataprovider* dataProvider in dataSourcesToFireFunctionOn )
        {
            [dataProvider applyFunction:functionName withParameters:[self parameterProperties]];
        }
    }
}

@end
