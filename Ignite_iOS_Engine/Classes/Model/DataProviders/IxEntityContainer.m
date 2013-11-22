//
//  IXEntityContainer.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
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

@end
