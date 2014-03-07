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

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"function_name";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:kIXFunctionName defaultValue:nil];
    
    if( objectIDs != nil && functionName != nil )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
        }
        
        [self actionDidFinishWithEvents:nil];
    }
}

@end
