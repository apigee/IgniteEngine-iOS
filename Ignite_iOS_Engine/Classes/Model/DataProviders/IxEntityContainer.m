//
//  IxEntityContainer.m
//  Ixgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxEntityContainer.h"

#import "IxPropertyContainer.h"

@implementation IxEntityContainer

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _entityProperties = [[IxPropertyContainer alloc] init];
        _subEntities = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
