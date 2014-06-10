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
#import "IXDataGrabber.h"
#import "IXControlCacheContainer.h"

#import "MMDrawerController.h"

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"function_name";
static NSString* const kIXDuration = @"duration";

// $app level functions
static NSString* const kIXReset = @"reset";
static NSString* const kIXDestorySession = @"session.destroy";
static NSString* const kIXToggleDrawerLeft = @"toggleDrawer.left";
static NSString* const kIXToggleDrawerRight = @"toggleDrawer.right";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:kIXFunctionName defaultValue:nil];
    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    
    if( [objectIDs count] && [functionName length] > 0 )
    {
        // todo: We need to separate app/session/etc. level functionality out into a separate class or sub-class. Also should migrate the shake-to-reset function to run this method directly, and assign a property to make it optional.
        if ([[objectIDs firstObject] isEqualToString:kIX_APP])
        {
            if ([functionName isEqualToString:kIXReset])
            {
                // Clear caches.
                [[[SDWebImageManager sharedManager] imageCache] clearMemory];
                [[[SDWebImageManager sharedManager] imageCache] clearDisk];
                [IXDataGrabber clearCache];
                [IXControlCacheContainer clearCache];
                
                [[IXAppManager sharedAppManager] startApplication];
            }
            else if ([functionName isEqualToString:kIXDestorySession])
            {
                [[[IXAppManager sharedAppManager] sessionProperties] removeAllProperties];
                [[IXAppManager sharedAppManager] storeSessionProperties];
            }
            else if([functionName isEqualToString:kIXToggleDrawerLeft] )
            {
                if( [[IXAppManager sharedAppManager] leftDrawerViewController] )
                {
                    [[[IXAppManager sharedAppManager] drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                }
            }
            else if([functionName isEqualToString:kIXToggleDrawerRight] )
            {
                if( [[IXAppManager sharedAppManager] rightDrawerViewController] )
                {
                    [[[IXAppManager sharedAppManager] drawerController] toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
                }
            }
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
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
