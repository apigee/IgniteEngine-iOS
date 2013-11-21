//
//  ixeBaseConditionalObject.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeProperty;

@interface ixeBaseConditionalObject : NSObject

@property (nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic,strong) ixeProperty* conditionalProperty;

-(BOOL)isConditionalValid;
-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation;

@end
