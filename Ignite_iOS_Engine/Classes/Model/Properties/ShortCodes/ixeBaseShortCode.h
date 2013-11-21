//
//  ixeBaseShortCode.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ixeBaseShortCode : NSObject

@property (nonatomic,strong) NSString* rawValue;
@property (nonatomic,strong) NSString* methodName;
@property (nonatomic,strong) NSMutableArray* parametersProperties;

-(instancetype)initWithRawValue:(NSString*)rawValue;
+(instancetype)shortCodeWithRawValue:(NSString*)rawValue;

-(NSValue*)evaluate;

@end
