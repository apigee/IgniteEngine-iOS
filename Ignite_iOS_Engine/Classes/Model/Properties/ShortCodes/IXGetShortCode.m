//
//  IXGetShortCode.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 11/21/13.
//  Copyright (c) 2013 Apigee Inc. All rights reserved.
//

#import "IXGetShortCode.h"

#import "IXBaseObject.h"
#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXViewController.h"
#import "IXAppManager.h"
#import "IXLayout.h"

@implementation IXGetShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    NSString* propertyName = [self methodName];
    if( !propertyName )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        propertyName = [parameterProperty getPropertyValue];
    }
    
    if( [[self objectID] isEqualToString:@"session"] )
    {
        returnValue = [[[IXAppManager sharedAppManager] sessionProperties] getStringPropertyValue:propertyName defaultValue:nil];
    }
    else if( [[self objectID] isEqualToString:@"view"] )
    {
        IXSandbox* sandbox = [[[[self property] propertyContainer] ownerObject] sandbox];
        IXViewController* viewController = [sandbox viewController];
        returnValue = [viewController getViewPropertyNamed:propertyName];
    }
    else
    {
        IXBaseObject* baseObject = [[[self property] propertyContainer] ownerObject];
        NSArray* objectWithIDArray = [[baseObject sandbox] getAllControlsAndDataProvidersWithID:[self objectID] withSelfObject:baseObject];
        baseObject = [objectWithIDArray firstObject];
        
        if( baseObject )
        {
            returnValue = [baseObject getReadOnlyPropertyValue:propertyName];
            if( returnValue == nil )
            {
                returnValue = [[baseObject propertyContainer] getStringPropertyValue:propertyName defaultValue:nil];
            }
        }
    }
    
    return returnValue;
}

@end
