//
//  IXSize.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/25/15.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

#import "IXSize.h"

@implementation IXSize

- (instancetype)initWithDefaultSize {
    self = [super init];
    if (self) {
        self.width = @"0";
        self.height = @"0";
    }
    return self;
}

@end
