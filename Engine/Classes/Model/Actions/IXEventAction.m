//
//  IXEventAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 1/25/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXEventAction.h"

#import "IXSandbox.h"

#import "IXAttributeContainer.h"
#import "IXActionContainer.h"

#import "IXBaseObject.h"

// IXEventAction Properties
static NSString* const kIXEventName = @"eventName";

@implementation IXEventAction

-(void)execute
{
    IXAttributeContainer* actionProperties = [self actionProperties];
    
    NSArray* objectIDs = [actionProperties getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    NSString* eventName = [actionProperties getStringValueForAttribute:kIXEventName defaultValue:nil];
    
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
