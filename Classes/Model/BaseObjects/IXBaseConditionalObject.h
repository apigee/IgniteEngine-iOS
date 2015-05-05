//
//  IXBaseConditionalObject.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXAttribute;
@class IXBaseObject;

@interface IXBaseConditionalObject : NSObject <NSCopying,NSCoding>

@property (nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic,strong) IXAttribute* valueIfTrue;
@property (nonatomic,strong) IXAttribute* valueIfFalse;

-(instancetype)initWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                            conditionalProperty:(IXAttribute*)conditionalProperty;

+(instancetype)baseConditionalObjectWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                                             conditionalProperty:(IXAttribute*)conditionalProperty;

-(BOOL)isConditionalTrue;
-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation;

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;

@end
