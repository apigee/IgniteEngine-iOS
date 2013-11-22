//
//  IXWidgetLayoutInfo.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/23.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXStructs.h"

@class IXPropertyContainer;

@interface IXSizePercentageContainer : NSObject

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) BOOL isPercentage;
@property (nonatomic,assign) BOOL propertyWasDefined;

-(instancetype)initWithStringValue:(NSString*)stringValue
                    orDefaultValue:(CGFloat)defaultValue;

+(instancetype)sizeAndPercentageContainerWithStringValue:(NSString*)stringValue
                                          orDefaultValue:(CGFloat)defaultValue;

-(CGFloat)evaluteForMaxValue:(CGFloat)maxValue;

@end

@interface IXEdgeInsets : NSObject

@property (nonatomic,strong) IXSizePercentageContainer* defaultValue;
@property (nonatomic,strong) IXSizePercentageContainer* top;
@property (nonatomic,strong) IXSizePercentageContainer* left;
@property (nonatomic,strong) IXSizePercentageContainer* bottom;
@property (nonatomic,strong) IXSizePercentageContainer* right;

-(instancetype)initWithDefaultValue:(IXSizePercentageContainer*)defaultValue
                                top:(IXSizePercentageContainer*)top
                               left:(IXSizePercentageContainer*)left
                             bottom:(IXSizePercentageContainer*)bottom
                              right:(IXSizePercentageContainer*)right;

+(instancetype)edgeInsetsWithDefaultValue:(IXSizePercentageContainer*)defaultValue
                                      top:(IXSizePercentageContainer*)top
                                     left:(IXSizePercentageContainer*)left
                                   bottom:(IXSizePercentageContainer*)bottom
                                    right:(IXSizePercentageContainer*)right;

-(UIEdgeInsets)evaluateEdgeInsetsUsingMaxSize:(CGSize)maxSize;

@end

@interface IXControlLayoutInfo : NSObject

@property (nonatomic,weak,readonly) IXPropertyContainer* propertyContainer;

@property (nonatomic,assign) CGRect layoutRect;
@property (nonatomic,assign) BOOL hasSeenLayout;

@property (nonatomic,assign,readonly) BOOL isHidden;
@property (nonatomic,assign,readonly) BOOL fillRemainingWidth;
@property (nonatomic,assign,readonly) BOOL fillRemainingHeight;
@property (nonatomic,assign,readonly) BOOL canPushParentsBounds;
@property (nonatomic,assign,readonly) BOOL isFloatPositioned;
@property (nonatomic,assign,readonly) BOOL isAbsolutePositioned;

@property (nonatomic,assign,readonly) IXLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign,readonly) IXLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign,readonly) BOOL widthWasDefined;
@property (nonatomic,strong,readonly) IXSizePercentageContainer* width;
@property (nonatomic,assign,readonly) BOOL heightWasDefined;
@property (nonatomic,strong,readonly) IXSizePercentageContainer* height;
@property (nonatomic,assign,readonly) BOOL topPositionWasDefined;
@property (nonatomic,strong,readonly) IXSizePercentageContainer* topPosition;
@property (nonatomic,assign,readonly) BOOL leftPositionWasDefined;
@property (nonatomic,strong,readonly) IXSizePercentageContainer* leftPosition;

@property (nonatomic,strong,readonly) IXEdgeInsets* marginInsets;
@property (nonatomic,strong,readonly) IXEdgeInsets* paddingInsets;

-(instancetype)initWithPropertyContainer:(IXPropertyContainer*)propertyContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(IXPropertyContainer*)propertyContainer;

-(void)refreshLayoutInfo;

@end
