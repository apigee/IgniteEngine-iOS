//
//  IXEntityContainer.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXEntityContainer.h"

#import "IXPropertyContainer.h"

@implementation IXEntityContainer

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _entityProperties = [[IXPropertyContainer alloc] init];
        _subEntities = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXEntityContainer* copiedEntityContainer = [[[self class] allocWithZone:zone] init];
    [copiedEntityContainer setEntityProperties:[[self entityProperties] copy]];
    [copiedEntityContainer setSubEntities:[[NSMutableArray alloc] initWithArray:[self subEntities] copyItems:YES]];
    return copiedEntityContainer;
}

@end
