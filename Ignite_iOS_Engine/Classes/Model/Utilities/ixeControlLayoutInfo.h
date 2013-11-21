//
//  ixeWidgetLayoutInfo.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/23.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ixeStructs.h"

@class ixePropertyContainer;

@interface ixeSizePercentageContainer : NSObject

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) BOOL isPercentage;
@property (nonatomic,assign) BOOL propertyWasDefined;

-(instancetype)initWithStringValue:(NSString*)stringValue
                    orDefaultValue:(CGFloat)defaultValue;

+(instancetype)sizeAndPercentageContainerWithStringValue:(NSString*)stringValue
                                          orDefaultValue:(CGFloat)defaultValue;

-(CGFloat)evaluteForMaxValue:(CGFloat)maxValue;

@end

@interface ixeEdgeInsets : NSObject

@property (nonatomic,strong) ixeSizePercentageContainer* defaultValue;
@property (nonatomic,strong) ixeSizePercentageContainer* top;
@property (nonatomic,strong) ixeSizePercentageContainer* left;
@property (nonatomic,strong) ixeSizePercentageContainer* bottom;
@property (nonatomic,strong) ixeSizePercentageContainer* right;

-(instancetype)initWithDefaultValue:(ixeSizePercentageContainer*)defaultValue
                                top:(ixeSizePercentageContainer*)top
                               left:(ixeSizePercentageContainer*)left
                             bottom:(ixeSizePercentageContainer*)bottom
                              right:(ixeSizePercentageContainer*)right;

+(instancetype)edgeInsetsWithDefaultValue:(ixeSizePercentageContainer*)defaultValue
                                      top:(ixeSizePercentageContainer*)top
                                     left:(ixeSizePercentageContainer*)left
                                   bottom:(ixeSizePercentageContainer*)bottom
                                    right:(ixeSizePercentageContainer*)right;

-(UIEdgeInsets)evaluateEdgeInsetsUsingMaxSize:(CGSize)maxSize;

@end

@interface ixeControlLayoutInfo : NSObject

@property (nonatomic,weak,readonly) ixePropertyContainer* propertyContainer;

@property (nonatomic,assign) CGRect layoutRect;
@property (nonatomic,assign) BOOL hasSeenLayout;

@property (nonatomic,assign,readonly) BOOL isHidden;
@property (nonatomic,assign,readonly) BOOL fillRemainingWidth;
@property (nonatomic,assign,readonly) BOOL fillRemainingHeight;
@property (nonatomic,assign,readonly) BOOL canPushParentsBounds;
@property (nonatomic,assign,readonly) BOOL isFloatPositioned;
@property (nonatomic,assign,readonly) BOOL isAbsolutePositioned;

@property (nonatomic,assign,readonly) ixeLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign,readonly) ixeLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign,readonly) BOOL widthWasDefined;
@property (nonatomic,strong,readonly) ixeSizePercentageContainer* width;
@property (nonatomic,assign,readonly) BOOL heightWasDefined;
@property (nonatomic,strong,readonly) ixeSizePercentageContainer* height;
@property (nonatomic,assign,readonly) BOOL topPositionWasDefined;
@property (nonatomic,strong,readonly) ixeSizePercentageContainer* topPosition;
@property (nonatomic,assign,readonly) BOOL leftPositionWasDefined;
@property (nonatomic,strong,readonly) ixeSizePercentageContainer* leftPosition;

@property (nonatomic,strong,readonly) ixeEdgeInsets* marginInsets;
@property (nonatomic,strong,readonly) ixeEdgeInsets* paddingInsets;

-(instancetype)initWithPropertyContainer:(ixePropertyContainer*)propertyContainer;
+(instancetype)controlLayoutInfoWithPropertyContainer:(ixePropertyContainer*)propertyContainer;

-(void)refreshLayoutInfo;

@end
