//
//  IXBaseConditionalObject.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;

@interface IXBaseConditionalObject : NSObject

@property (nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic,copy) IXProperty* conditionalProperty;

-(BOOL)isConditionalValid;
-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation;

@end
