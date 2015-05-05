//
//  IXControlLayoutInfo.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/23/13.
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

#import "IXStructs.h"

@class IXAttributeContainer;

@interface IXControlLayoutInfo : NSObject <NSCopying>

@property (nonatomic,weak) IXAttributeContainer* attributeContainer;
@property (nonatomic,assign) CGRect layoutRect;

@property (nonatomic,assign,readonly) BOOL isHidden;
@property (nonatomic,assign,readonly) BOOL fillRemainingWidth;
@property (nonatomic,assign,readonly) BOOL fillRemainingHeight;
@property (nonatomic,assign,readonly) BOOL canPushParentsBounds;
@property (nonatomic,assign,readonly) BOOL isFloatPositioned;
@property (nonatomic,assign,readonly) BOOL isAbsolutePositioned;

@property (nonatomic,assign,readonly) IXLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign,readonly) IXLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign,readonly) BOOL widthWasDefined;
@property (nonatomic,assign,readonly) IXSizeValuePercentage width;
@property (nonatomic,assign,readonly) BOOL heightWasDefined;
@property (nonatomic,assign,readonly) IXSizeValuePercentage height;
@property (nonatomic,assign,readonly) BOOL topPositionWasDefined;
@property (nonatomic,assign,readonly) IXSizeValuePercentage topPosition;
@property (nonatomic,assign,readonly) BOOL leftPositionWasDefined;
@property (nonatomic,assign,readonly) IXSizeValuePercentage leftPosition;
@property (nonatomic,assign,readonly) BOOL bottomPositionWasDefined;
@property (nonatomic,assign,readonly) IXSizeValuePercentage bottomPosition;

@property (nonatomic,assign,readonly) IXEdgeInsets marginInsets;
@property (nonatomic,assign,readonly) IXEdgeInsets paddingInsets;

-(instancetype)initWithAttributeContainer:(IXAttributeContainer*)attributeContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(IXAttributeContainer*)attributeContainer;

-(void)refreshLayoutInfo;
+(BOOL)doesAttributeTriggerLayout:(NSString*)propertyName;

IXEdgeInsets IXEdgeInsetsZero();
UIEdgeInsets ixEvaluateEdgeInsets(IXEdgeInsets edgeInsets, CGSize maxSize);

IXSizeValuePercentage IXSizeValuePercentageZero();
IXSizeValuePercentage ixSizePercentageValueWithStringOrDefaultValue(NSString* stringValue, CGFloat defaultValue);
CGFloat ixEvaluateSizeValuePercentageForMaxValue(IXSizeValuePercentage sizeValuePercentage, CGFloat maxValue);

@end
