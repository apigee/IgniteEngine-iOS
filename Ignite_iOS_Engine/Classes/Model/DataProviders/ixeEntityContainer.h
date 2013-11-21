//
//  ixeEntityContainer.h
//  ixegee_iOS_Engine
//
//  Created by Robert Walsh on 11/19.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixePropertyContainer;

@interface ixeEntityContainer : NSObject

@property (nonatomic,strong) ixePropertyContainer* entityProperties;
@property (nonatomic,strong) NSMutableArray* subEntities;

@end
