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

#import "IXAppManager.h"
#import "SDWebImageManager.h"
#import "IXJSONGrabber.h"
#import "IXControlCacheContainer.h"

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"function_name";
static NSString* const kIXDuration = @"duration";

// $app level functions
static NSString* const kIXReset = @"reset";

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
        
        // todo: We need to separate app/session/etc. level functionality out into a separate class or sub-class.
        if ([[objectIDs objectAtIndex:0] isEqualToString:kIX_APP])
        {
            if ([functionName isEqualToString:kIXReset])
            {
                // Clear caches.
                [[[SDWebImageManager sharedManager] imageCache] clearMemory];
                [[[SDWebImageManager sharedManager] imageCache] clearDisk];
                [IXJSONGrabber clearCache];
                [IXControlCacheContainer clearCache];
                
                [[IXAppManager sharedAppManager] startApplication];
            }
        }
        else
        {
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
        }
        
        [self actionDidFinishWithEvents:nil];
    }
}

@end
