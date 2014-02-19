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

@implementation IXEventAction

-(void)execute
{
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* objectID = [actionProperties getStringPropertyValue:kIX_ID defaultValue:nil];
    NSString* eventName = [actionProperties getStringPropertyValue:@"event_name" defaultValue:nil];
    
    if( objectID && eventName )
    {
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        NSArray* objectsWithID = [sandbox getAllControlAndDataProvidersWithID:objectID withSelfObject:[[self actionContainer] ownerObject]];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject actionContainer] executeActionsForEventNamed:eventName];
        }
    }
}

@end
