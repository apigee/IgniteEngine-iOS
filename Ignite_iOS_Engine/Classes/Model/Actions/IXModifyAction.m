//
//  IXModifyAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXModifyAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"

@implementation IXModifyAction

-(void)execute
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    
    if( objectID != nil && [self parameterProperties] != nil )
    {
        if( [objectID isEqualToString:@"session"] )
        {
            IXPropertyContainer* sessionProperties = [[IXAppManager sharedInstance] sessionProperties];
            [sessionProperties addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES];
        }
        else
        {
            NSArray* objectsWithID = [[[self actionContainer] sandbox] getAllControlAndDataProvidersWithID:objectID];
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [[baseObject propertyContainer] addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES];
            }
        }
    }
}

@end
