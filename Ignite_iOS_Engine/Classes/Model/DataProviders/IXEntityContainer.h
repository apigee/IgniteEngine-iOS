//
//  IXEntityContainer.h
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXPropertyContainer;

@interface IXEntityContainer : NSObject

@property (nonatomic,strong) IXPropertyContainer* entityProperties;
@property (nonatomic,strong) NSMutableArray* subEntities;

@end
