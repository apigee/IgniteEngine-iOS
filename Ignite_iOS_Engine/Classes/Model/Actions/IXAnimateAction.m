//
//  IXAnimateAction.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXAnimateAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXLayout.h"
#import "IXBaseControl.h"

// Animation Properties
static NSString* const kIXDuration = @"duration";
static NSString* const kIXAnimation = @"animation";
static NSString* const kIXRepeatCount = @"repeat_count";

// Animation Functions
static NSString* const kIXStart = @"start";
static NSString* const kIXStop = @"stop";

// Animations are declared in IXBaseControl.m

@implementation IXAnimateAction

-(void)performAnimation
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    NSString* animation = [[self actionProperties] getStringPropertyValue:kIXAnimation defaultValue:nil];
    NSInteger repeatCount = [[self actionProperties] getIntPropertyValue:kIXRepeatCount defaultValue:0];
    
    if( objectIDs != nil && animation != nil)
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        for( NSString* objectID in objectIDs )
        {
            NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithID:objectID
                                                                    withSelfObject:ownerObject];
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [baseObject beginAnimation:animation duration:duration repeatCount:repeatCount];
            }
        }
        
        [self actionDidFinishWithEvents:nil];
    }
}

-(void)execute
{
    [self performAnimation];
}


@end

