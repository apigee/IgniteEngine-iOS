//
//  IXEntityContainer.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXEntityContainer.h"

#import "IXAttribute.h"
#import "IXAttributeContainer.h"

@implementation IXEntityContainer

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _entityAttributes = [[IXAttributeContainer alloc] init];
        _subEntities = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXEntityContainer* copiedEntityContainer = [[[self class] allocWithZone:zone] init];
    [copiedEntityContainer setEntityAttributes:[[self entityAttributes] copy]];
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
                [[entity entityAttributes] addAttribute:[IXAttribute attributeWithAttributeName:key jsonObject:obj]];
            }
        }];
    }
    return entity;
}

@end
