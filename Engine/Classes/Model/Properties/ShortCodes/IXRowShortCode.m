//
//  IXRowShortCode.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXRowShortCode.h"

#import "IXProperty.h"
#import "IXPropertyContainer.h"
#import "IXDataRowDataProvider.h"

static NSString* const kIXIndex = @"index";

@implementation IXRowShortCode

-(NSString*)evaluate
{
    NSString* returnValue = nil;
    
    IXSandbox* sandbox = [[[[self property] propertyContainer] ownerObject] sandbox];
    
    IXDataRowDataProvider* baseDP = [sandbox dataProviderForRowData];
    NSString* dataRowBasePath = [sandbox dataRowBasePathForRowData];
    NSIndexPath* rowIndexPath = [sandbox indexPathForRowData];

    if( baseDP && rowIndexPath )
    {
        NSString* keyPath = [self methodName];
        if( !keyPath )
        {
            IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
            keyPath = [parameterProperty getPropertyValue];
        }
        
        if( [keyPath isEqualToString:kIXIndex] )
        {
            returnValue = [NSString stringWithFormat:@"%li",(long)rowIndexPath.row];
        }
        else
        {
            returnValue = [baseDP rowDataForIndexPath:rowIndexPath keyPath:keyPath dataRowBasePath:dataRowBasePath];
        }
    }
    
    return returnValue;
}

@end
