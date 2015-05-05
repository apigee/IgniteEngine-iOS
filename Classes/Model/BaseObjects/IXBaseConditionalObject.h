//
//  IXBaseConditionalObject.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
