//
//  IXFunctionAction.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXFunctionAction.h"
#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXBaseDataProvider.h"

#import "IXAppManager.h"
#import "SDWebImageManager.h"
#import "IXDataLoader.h"
#import "IXControlCacheContainer.h"

#import "MMDrawerController.h"

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"name";
//TODO: deprecate in future release
static NSString* const kIXFunctionNameOld = @"functionName";

static NSString* const kIXDuration = @"duration";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* functionName = ([[self actionProperties] getStringPropertyValue:kIXFunctionName defaultValue:nil]) ?: [[self actionProperties] getStringPropertyValue:kIXFunctionNameOld defaultValue:nil];

    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    if( [objectIDs count] && [functionName length] > 0 )
    {
        if ([[objectIDs firstObject] isEqualToString:kIXAppRef])
        {
            [[IXAppManager sharedAppManager] applyFunction:functionName parameters:[self setProperties]];
        }
        else
        {
            IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
            IXSandbox* sandbox = [ownerObject sandbox];
            NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                     withSelfObject:ownerObject];
            if( [objectsWithID count] )
            {
                if (duration > 0)
                {
                    [UIView animateWithDuration:duration
                                          delay:0.0f
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                         for( IXBaseObject* baseObject in objectsWithID )
                                         {
                                             [baseObject applyFunction:functionName withParameters:[self setProperties]];
                                         }
                                     }
                                     completion:nil];
                }
                else
                {
                    for( IXBaseObject* baseObject in objectsWithID )
                    {
                        [baseObject applyFunction:functionName withParameters:[self setProperties]];
                    }
                }
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
