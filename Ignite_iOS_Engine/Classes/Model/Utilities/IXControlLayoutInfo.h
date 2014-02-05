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

@interface IXSizePercentageContainer : NSObject <NSCopying>

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign,getter = isPercentage) BOOL percentage;
@property (nonatomic,assign,getter = propertyWasDefined) BOOL propertyDefined;

-(instancetype)initWithStringValue:(NSString*)stringValue
                    orDefaultValue:(CGFloat)defaultValue;

+(instancetype)sizeAndPercentageContainerWithStringValue:(NSString*)stringValue
                                          orDefaultValue:(CGFloat)defaultValue;

-(BOOL)applyStringValue:(NSString*)stringValue orDefaultValue:(CGFloat)defaultValue;

-(CGFloat)evaluteForMaxValue:(CGFloat)maxValue;

@end

@interface IXEdgeInsets : NSObject <NSCopying>

@property (nonatomic,copy) IXSizePercentageContainer* defaultValue;
@property (nonatomic,copy) IXSizePercentageContainer* top;
@property (nonatomic,copy) IXSizePercentageContainer* left;
@property (nonatomic,copy) IXSizePercentageContainer* bottom;
@property (nonatomic,copy) IXSizePercentageContainer* right;

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

@interface IXControlLayoutInfo : NSObject <NSCopying>

@property (nonatomic,weak) IXPropertyContainer* propertyContainer;
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

@property (nonatomic,readonly) BOOL widthWasDefined;
@property (nonatomic,copy,readonly) IXSizePercentageContainer* width;
@property (nonatomic,readonly) BOOL heightWasDefined;
@property (nonatomic,copy,readonly) IXSizePercentageContainer* height;
@property (nonatomic,readonly) BOOL topPositionWasDefined;
@property (nonatomic,copy,readonly) IXSizePercentageContainer* topPosition;
@property (nonatomic,readonly) BOOL leftPositionWasDefined;
@property (nonatomic,copy,readonly) IXSizePercentageContainer* leftPosition;

@property (nonatomic,copy,readonly) IXEdgeInsets* marginInsets;
@property (nonatomic,copy,readonly) IXEdgeInsets* paddingInsets;

-(instancetype)initWithPropertyContainer:(IXPropertyContainer*)propertyContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(IXPropertyContainer*)propertyContainer;

-(void)refreshLayoutInfo;

@end
