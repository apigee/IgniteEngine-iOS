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
static NSString* const kIXDuration = @"duration";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:kIXFunctionName defaultValue:nil];
    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    
    if( [objectIDs count] && [functionName length] > 0 )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        if (duration > 0)
        {
            [UIView animateWithDuration:duration
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             for( IXBaseObject* baseObject in objectsWithID )
                             {
                                 [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
                             }
                         }
                         completion:nil];
        }
        else
        {
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
            }
        }

        
        [self actionDidFinishWithEvents:nil];
    }
}

@end
