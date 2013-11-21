//
//  ixeEntityContainer.m
//  ixegee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeEntityContainer.h"

#import "ixePropertyContainer.h"

@implementation ixeEntityContainer

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _entityProperties = [[ixePropertyContainer alloc] init];
        _subEntities = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
