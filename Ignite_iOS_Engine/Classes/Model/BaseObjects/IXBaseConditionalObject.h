//
//  IXBaseConditionalObject.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;
@class IXBaseObject;

@interface IXBaseConditionalObject : NSObject <NSCopying,NSCoding>

@property (nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic,strong) IXProperty* conditionalProperty;

-(instancetype)initWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                            conditionalProperty:(IXProperty*)conditionalProperty;

+(instancetype)baseConditionalObjectWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                                             conditionalProperty:(IXProperty*)conditionalProperty;

-(BOOL)isConditionalTrue;
-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation;

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;

@end
