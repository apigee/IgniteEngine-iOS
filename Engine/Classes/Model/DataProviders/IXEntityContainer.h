//
//  IXEntityContainer.h
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/19/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXPropertyContainer;

@interface IXEntityContainer : NSObject <NSCopying>

@property (nonatomic,strong) IXPropertyContainer* entityProperties;
@property (nonatomic,strong) NSMutableArray* subEntities;

+(instancetype)entityContainerWithJSONEntityDict:(NSDictionary*)entityDict;

@end
