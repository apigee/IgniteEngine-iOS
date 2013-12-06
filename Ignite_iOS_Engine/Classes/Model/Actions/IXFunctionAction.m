//
//  IXFunctionAction.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXFunctionAction.h"

#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXBaseDataProvider.h"

@implementation IXFunctionAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:@"function_name" defaultValue:nil];
    
    if( objectID != nil && functionName != nil )
    {
        NSArray* objectsWithID = [[[self actionContainer] sandbox] getAllControlAndDataProvidersWithID:objectID];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
        }
    }
}

@end
