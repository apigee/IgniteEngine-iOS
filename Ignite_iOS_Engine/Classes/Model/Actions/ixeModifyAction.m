//
//  ixeModifyAction.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeModifyAction.h"

#import "ixeSandbox.h"
#import "ixeBaseObject.h"
#import "ixeActionContainer.h"

@implementation ixeModifyAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    
    if( objectID != nil && [self parameterProperties] != nil )
    {
        NSArray* objectsWithID = [[[self actionContainer] sandbox] getAllControlAndDataProvidersWithID:objectID];
        for( ixeBaseObject* baseObject in objectsWithID )
        {
            [[baseObject propertyContainer] addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES];
        }
    }
}

@end
