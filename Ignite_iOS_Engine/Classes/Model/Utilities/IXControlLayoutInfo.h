//
//  IXControlLayoutInfo.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/23/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXStructs.h"

@class IXPropertyContainer;

@interface IXControlLayoutInfo : NSObject <NSCopying>

@property (nonatomic,weak) IXPropertyContainer* propertyContainer;
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

-(instancetype)initWithPropertyContainer:(IXPropertyContainer*)propertyContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(IXPropertyContainer*)propertyContainer;

-(void)refreshLayoutInfo;
+(BOOL)doesPropertyNameTriggerLayout:(NSString*)propertyName;

IXEdgeInsets IXEdgeInsetsZero();
UIEdgeInsets ixEvaluateEdgeInsets(IXEdgeInsets edgeInsets, CGSize maxSize);

IXSizeValuePercentage IXSizeValuePercentageZero();
IXSizeValuePercentage ixSizePercentageValueWithStringOrDefaultValue(NSString* stringValue, CGFloat defaultValue);
CGFloat ixEvaluateSizeValuePercentageForMaxValue(IXSizeValuePercentage sizeValuePercentage, CGFloat maxValue);

@end
