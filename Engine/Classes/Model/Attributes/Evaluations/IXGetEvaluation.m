//
//  IXGetVariable.m
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
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXAttribute* parameterProperty = (IXAttribute*)[[self parameters] firstObject];
        propertyName = [parameterProperty attributeStringValue];
    }
    
    if( [[self objectID] isEqualToString:kIXSessionRef
         ] )
    {
        returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringValueForAttribute:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:kIXViewControlRef] )
    {
        IXSandbox* sandbox = [[[[self property] attributeContainer] ownerObject] sandbox];
        IXViewController* viewController = [sandbox viewController];
        returnValue = [viewController getViewPropertyNamed:propertyName];
    }
    else
    {
        IXBaseObject* baseObject = [[[self property] attributeContainer] ownerObject];
        NSArray* objectWithIDArray = [[baseObject sandbox] getAllControlsAndDataProvidersWithID:[self objectID] withSelfObject:baseObject];
        baseObject = [objectWithIDArray firstObject];
        
        if( baseObject )
        {
            returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
            if( returnValue == nil )
            {
                returnValue = [[baseObject attributeContainer] getStringValueForAttribute:propertyName defaultValue:nil];
            }
        }
    }
    
    return returnValue;
}

@end
