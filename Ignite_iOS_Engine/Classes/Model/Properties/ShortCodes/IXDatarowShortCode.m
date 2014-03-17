//
//  IXDatarowShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXDatarowShortCode.h"

#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXBaseDataProvider.h"

@implementation IXDatarowShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    IXSandbox* sandbox = [[[[self property] propertyContainer] ownerObject] sandbox];
    
    IXBaseDataProvider* baseDP = [sandbox dataProviderForRowData];
    NSIndexPath* rowIndexPath = [sandbox indexPathForRowData];
    
    if( baseDP && rowIndexPath )
    {
        NSString* keyPath = [self methodName];
        if( !keyPath )
        {
            IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
            keyPath = [parameterProperty getPropertyValue];
        }
        
        returnValue = [baseDP rowDataForIndexPath:rowIndexPath keyPath:keyPath];
    }
    
    return returnValue;
}

@end
