//
//  IxEntityContainer.h
//  Ixgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxPropertyContainer;

@interface IxEntityContainer : NSObject

@property (nonatomic,strong) IxPropertyContainer* entityProperties;
@property (nonatomic,strong) NSMutableArray* subEntities;

@end
