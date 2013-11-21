//
//  IxWidgetLayoutInfo.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/23.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IxStructs.h"

@class IxPropertyContainer;

@interface IxSizePercentageContainer : NSObject

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) BOOL isPercentage;
@property (nonatomic,assign) BOOL propertyWasDefined;

-(instancetype)initWithStringValue:(NSString*)stringValue
                    orDefaultValue:(CGFloat)defaultValue;

+(instancetype)sizeAndPercentageContainerWithStringValue:(NSString*)stringValue
                                          orDefaultValue:(CGFloat)defaultValue;

-(CGFloat)evaluteForMaxValue:(CGFloat)maxValue;

@end

@interface IxEdgeInsets : NSObject

@property (nonatomic,strong) IxSizePercentageContainer* defaultValue;
@property (nonatomic,strong) IxSizePercentageContainer* top;
@property (nonatomic,strong) IxSizePercentageContainer* left;
@property (nonatomic,strong) IxSizePercentageContainer* bottom;
@property (nonatomic,strong) IxSizePercentageContainer* right;

-(instancetype)initWithDefaultValue:(IxSizePercentageContainer*)defaultValue
                                top:(IxSizePercentageContainer*)top
                               left:(IxSizePercentageContainer*)left
                             bottom:(IxSizePercentageContainer*)bottom
                              right:(IxSizePercentageContainer*)right;

+(instancetype)edgeInsetsWithDefaultValue:(IxSizePercentageContainer*)defaultValue
                                      top:(IxSizePercentageContainer*)top
                                     left:(IxSizePercentageContainer*)left
                                   bottom:(IxSizePercentageContainer*)bottom
                                    right:(IxSizePercentageContainer*)right;

-(UIEdgeInsets)evaluateEdgeInsetsUsingMaxSize:(CGSize)maxSize;

@end

@interface IxControlLayoutInfo : NSObject

@property (nonatomic,weak,readonly) IxPropertyContainer* propertyContainer;

@property (nonatomic,assign) CGRect layoutRect;
@property (nonatomic,assign) BOOL hasSeenLayout;

@property (nonatomic,assign,readonly) BOOL isHidden;
@property (nonatomic,assign,readonly) BOOL fillRemainingWidth;
@property (nonatomic,assign,readonly) BOOL fillRemainingHeight;
@property (nonatomic,assign,readonly) BOOL canPushParentsBounds;
@property (nonatomic,assign,readonly) BOOL isFloatPositioned;
@property (nonatomic,assign,readonly) BOOL isAbsolutePositioned;

@property (nonatomic,assign,readonly) IxLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign,readonly) IxLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign,readonly) BOOL widthWasDefined;
@property (nonatomic,strong,readonly) IxSizePercentageContainer* width;
@property (nonatomic,assign,readonly) BOOL heightWasDefined;
@property (nonatomic,strong,readonly) IxSizePercentageContainer* height;
@property (nonatomic,assign,readonly) BOOL topPositionWasDefined;
@property (nonatomic,strong,readonly) IxSizePercentageContainer* topPosition;
@property (nonatomic,assign,readonly) BOOL leftPositionWasDefined;
@property (nonatomic,strong,readonly) IxSizePercentageContainer* leftPosition;

@property (nonatomic,strong,readonly) IxEdgeInsets* marginInsets;
@property (nonatomic,strong,readonly) IxEdgeInsets* paddingInsets;

-(instancetype)initWithPropertyContainer:(IxPropertyContainer*)propertyContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(IxPropertyContainer*)propertyContainer;

-(void)refreshLayoutInfo;

@end
