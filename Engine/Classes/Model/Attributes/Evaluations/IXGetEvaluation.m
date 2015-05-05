//
//  IXGetEvaluation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/21/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

#import "IXGetEvaluation.h"

#import "IXBaseObject.h"
#import "IXAttribute.h"
#import "IXAttributeContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLayout.h"

@implementation IXGetEvaluation

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* attributeName = [self methodName];
    if( !attributeName )
    {
        IXAttribute* parameterAttribute = (IXAttribute*)[[self parameters] firstObject];
        attributeName = [parameterAttribute getAttributeValue];
    }
    
    if( [[self objectID] isEqualToString:kIXSessionRef
         ] )
    {
        returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringAttributeValue:attributeName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:kIXViewControlRef] )
    {
        IXSandbox* sandbox = [[[[self attribute] attributeContainer] ownerObject] sandbox];
        IXViewController* viewController = [sandbox viewController];
        returnValue = [viewController getViewAttributeNamed:attributeName];
    }
    else
    {
        IXBaseObject* baseObject = [[[self attribute] attributeContainer] ownerObject];
        NSArray* objectWithIDArray = [[baseObject sandbox] getAllControlsAndDataProvidersWithID:[self objectID] withSelfObject:baseObject];
        baseObject = [objectWithIDArray firstObject];
        
        if( baseObject )
        {
            returnValue = [baseObject getReadOnlyPropertyValue:attributeName];
            if( returnValue == nil )
            {
                returnValue = [[baseObject attributeContainer] getStringAttributeValue:attributeName defaultValue:nil];
            }
        }
    }
    
    return returnValue;
}

@end
