//
//  IXSize.h
//  Ignite Engine
//
//  Created by Brandon on 3/25/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXSize : NSObject

@property (nonatomic, strong) NSString* height;
@property (nonatomic, strong) NSString* width;

- (instancetype)initWithDefaultSize;

@end
