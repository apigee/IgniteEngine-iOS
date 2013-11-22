//
//  IXModifyAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXModifyAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"

@implementation IXModifyAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    
    if( objectID != nil && [self parameterProperties] != nil )
    {
        NSArray* objectsWithID = [[[self actionContainer] sandbox] getAllControlAndDataProvidersWithID:objectID];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject propertyContainer] addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES];
        }
    }
}

@end
