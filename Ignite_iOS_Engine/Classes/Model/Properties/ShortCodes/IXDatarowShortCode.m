//
//  IXDatarowShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXDatarowShortCode.h"
#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXSandbox.h"
#import "IXCoreDataDataProvider.h"
#import <RestKit/CoreData.h>

@implementation IXDatarowShortCode

-(NSString*)evaluate:(IXSandbox*)sandbox
{
    NSString* returnValue = nil;
    IXBaseDataProvider* baseDP = [sandbox dataProviderForRowData];
    NSIndexPath* rowIndexPath = [sandbox indexPathForRowData];
    NSString* keyPath = [self methodName];
    if( !keyPath )
    {
        IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
        keyPath = [parameterProperty getPropertyValue:sandbox];
    }
    returnValue = [baseDP rowDataForIndexPath:rowIndexPath keyPath:keyPath];
    return returnValue;
}

@end
