//
//  IXBaseConditionalObject.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;

@interface IXBaseConditionalObject : NSObject

@property (nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic,strong) IXProperty* conditionalProperty;

-(BOOL)isConditionalValid;
-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation;

@end
