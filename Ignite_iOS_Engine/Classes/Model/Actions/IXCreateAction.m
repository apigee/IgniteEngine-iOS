//
//  IXCreateAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCreateAction.h"

#import "IXAppManager.h"
#import "IXLogger.h"

#import "IXJSONGrabber.h"

#import "IXPropertyContainer.h"
#import "IXBaseControlConfig.h"
#import "IXControlCacheContainer.h"

#import "IXBaseControl.h"

// IXCreateAction Properties
static NSString* const kIXControlLocation = @"control_location";
static NSString* const kIXParentID = @"parent_id";

// IXCreateAction Events: kIX_SUCCESS and kIX_FAILED

@implementation IXCreateAction

-(void)execute
{
    [super execute];
    
    BOOL needsToSendFailed = YES;
    
    NSString* controlJSONLocation = [[self actionProperties] getPathPropertyValue:kIXControlLocation
                                                                         basePath:nil
                                                                     defaultValue:nil];
    
    if( controlJSONLocation )
    {
        NSString* parentControlID = [[self actionProperties] getStringPropertyValue:kIXParentID
                                                                       defaultValue:nil];

        IXBaseControl* parentControl = nil;
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        if( parentControlID != nil )
        {
            if( [parentControlID length] > 0 )
            {
                parentControl = [[sandbox getAllControlsWithID:parentControlID] firstObject];
            }
        }
        else
        {
            parentControl = [sandbox containerControl];
        }
        
        if( parentControl != nil )
        {
            needsToSendFailed = NO;
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(parentControl) weakParentControl = parentControl;
            
            [IXControlCacheContainer createControlWithPathToJSON:controlJSONLocation loadAsync:NO completionBlock:^(BOOL didSucceed, IXBaseControl *createdControl, NSError *error) {
                                                     
                 if( createdControl && weakParentControl )
                 {
                     [weakParentControl addChildObject:createdControl];
                    
                     [createdControl applySettings];
                     [weakParentControl layoutControl];
                     
                     [weakSelf actionDidFinishWithEvents:@[kIX_SUCCESS]];
                }
                else
                {
                    [weakSelf actionDidFinishWithEvents:@[kIX_FAILED]];
                }
             }];
        }
    }
    
    if( needsToSendFailed )
    {
        [self actionDidFinishWithEvents:@[kIX_FAILED]];
    }
}

@end
