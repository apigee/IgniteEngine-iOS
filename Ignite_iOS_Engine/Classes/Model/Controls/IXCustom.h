//
//  IXCustom.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXLayout.h"

@interface IXCustom : IXLayout

@property (nonatomic,assign) BOOL needsToPopulate;
@property (nonatomic,strong) NSArray* dataProviders;

@end
