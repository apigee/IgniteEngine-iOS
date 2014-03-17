//
//  IXEntityContainer.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXEntityContainer.h"

#import "IXProperty.h"
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

+(instancetype)entityContainerWithJSONEntityDict:(NSDictionary*)entityDict
{
    IXEntityContainer* entity = nil;
    if( [entityDict isKindOfClass:[NSDictionary class]] )
    {
        entity = [[IXEntityContainer alloc] init];
        
        [entityDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSArray class]] && [key isEqualToString:@"sub_entities"] )
            {
                for( NSDictionary* subEntityDict in obj )
                {
                    IXEntityContainer* subEntityContainer = [IXEntityContainer entityContainerWithJSONEntityDict:subEntityDict];
                    if( subEntityContainer != nil )
                        [[entity subEntities] addObject:subEntityContainer];
                }
            }
            else if( [obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] )
            {
                [[entity entityProperties] addProperty:[IXProperty propertyWithPropertyName:key jsonObject:obj]];
            }
        }];
    }
    return entity;
}

@end
