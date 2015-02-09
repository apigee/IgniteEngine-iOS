//
//  IXEventAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/25/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXEventAction.h"

#import "IXSandbox.h"

#import "IXPropertyContainer.h"
#import "IXActionContainer.h"

#import "IXBaseObject.h"

// IXEventAction Properties
static NSString* const kIXEventName = @"event_name";

@implementation IXEventAction

-(void)execute
{
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSArray* objectIDs = [actionProperties getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* eventName = [actionProperties getStringPropertyValue:kIXEventName defaultValue:nil];
    
    if( objectIDs && eventName )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject actionContainer] executeActionsForEventNamed:eventName];
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
