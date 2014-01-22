//
//  IXUICollectionViewCell.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXUICollectionViewCell.h"

@implementation IXUICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _layoutControl = nil;
        _cellSandbox = nil;
    }
    return self;
}

@end
