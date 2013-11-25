//
//  IXControlLayoutInfo.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/23/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXControlLayoutInfo.h"
#import "IXPropertyContainer.h"

@implementation IXSizePercentageContainer

-(instancetype)init
{
    return [self initWithStringValue:nil orDefaultValue:0.0f];
}

+(instancetype)sizeAndPercentageContainerWithStringValue:(NSString*)stringValue orDefaultValue:(CGFloat)defaultValue
{
    return [[[self class] alloc] initWithStringValue:stringValue orDefaultValue:defaultValue];
}

-(instancetype)initWithStringValue:(NSString*)stringValue orDefaultValue:(CGFloat)defaultValue
{
    self = [super init];
    if( self != nil )
    {
        if( stringValue != nil )
        {
            _propertyWasDefined = YES;
            _isPercentage = [stringValue hasSuffix:@"\%"];
            if( _isPercentage )
            {
                _value = [[stringValue stringByReplacingOccurrencesOfString:@"\%" withString:@""] floatValue] / 100.0f;
            }
            else
            {
                _value = [stringValue floatValue];
            }
        }
        else
        {
            _propertyWasDefined = NO;
            _isPercentage = NO;
            _value = defaultValue;
        }
    }
    return self;
}

-(CGFloat)evaluteForMaxValue:(CGFloat)maxValue
{
    float returnFloat = [self value];
    if( [self isPercentage] )
    {
        returnFloat = returnFloat * maxValue;
    }
    return returnFloat;
}

@end

@implementation IXEdgeInsets

-(instancetype)init
{
    return [self initWithDefaultValue:nil top:nil left:nil bottom:nil right:nil];
}

+(instancetype)edgeInsetsWithDefaultValue:(IXSizePercentageContainer*)defaultValue
                                      top:(IXSizePercentageContainer*)top
                                     left:(IXSizePercentageContainer*)left
                                   bottom:(IXSizePercentageContainer*)bottom
                                    right:(IXSizePercentageContainer*)right
{
    return [[[self class] alloc] initWithDefaultValue:defaultValue top:top left:left bottom:bottom right:right];
}

-(instancetype)initWithDefaultValue:(IXSizePercentageContainer*)defaultValue
                                top:(IXSizePercentageContainer*)top
                               left:(IXSizePercentageContainer*)left
                             bottom:(IXSizePercentageContainer*)bottom
                              right:(IXSizePercentageContainer*)right
{
    self = [super init];
    if( self != nil )
    {
        _defaultValue = defaultValue;
        _top = top;
        _left = left;
        _bottom = bottom;
        _right = right;
    }
    return self;
}

-(UIEdgeInsets)evaluateEdgeInsetsUsingMaxSize:(CGSize)maxSize
{
    return UIEdgeInsetsMake([[self top] evaluteForMaxValue:maxSize.height],
                            [[self left] evaluteForMaxValue:maxSize.width],
                            [[self bottom] evaluteForMaxValue:maxSize.height],
                            [[self right] evaluteForMaxValue:maxSize.width]);
}

@end

@implementation IXControlLayoutInfo

@synthesize propertyContainer = _propertyContainer;

-(instancetype)init
{
    return [self initWithPropertyContainer:nil];
}

+(instancetype)controlLayoutInfoWithPropertyContainer:(IXPropertyContainer*)propertyContainer
{
    return [[[self class] alloc] initWithPropertyContainer:propertyContainer];
}

-(instancetype)initWithPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    self = [super init];
    if( self != nil )
    {
        _propertyContainer = propertyContainer;
        [self refreshLayoutInfo];
    }
    return self;
}

-(void)refreshLayoutInfo
{
    _hasSeenLayout = NO;
    _layoutRect = CGRectZero;
    
    _isHidden = ![[self propertyContainer] getBoolPropertyValue:@"visible" defaultValue:YES];
    _fillRemainingWidth = [[self propertyContainer] getBoolPropertyValue:@"fill_remaining_width" defaultValue:NO];
    _fillRemainingHeight = [[self propertyContainer] getBoolPropertyValue:@"fill_remaining_height" defaultValue:NO];
    _canPushParentsBounds = [[self propertyContainer] getBoolPropertyValue:@"include_in_parent_autosize" defaultValue:YES];
    
    NSString* layoutType = [[self propertyContainer] getStringPropertyValue:@"layout_type" defaultValue:@"relative"];
    _isFloatPositioned = [layoutType isEqualToString:@"float"];
    _isAbsolutePositioned = [layoutType isEqualToString:@"absolute"] || _isFloatPositioned;
    
    NSString* verticalAlignment = [[self propertyContainer] getStringPropertyValue:@"vertical_alignment" defaultValue:@"top"];
    if( [verticalAlignment isEqualToString:@"top"] )
        _verticalAlignment = IXLayoutVerticalAlignmentTop;
    else if( [verticalAlignment isEqualToString:@"middle"] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignment isEqualToString:@"bottom"] )
        _verticalAlignment = IXLayoutVerticalAlignmentBottom;
    
    NSString* horizontalAlignment = [[self propertyContainer] getStringPropertyValue:@"horizontal_alignment" defaultValue:@"left"];
    if( [horizontalAlignment isEqualToString:@"left"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    else if( [horizontalAlignment isEqualToString:@"center"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignment isEqualToString:@"right"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentRight;
    
    _width = [[self propertyContainer] getSizePercentageContainer:@"width" defaultValue:0.0f];
    _widthWasDefined = [_width propertyWasDefined];
    _height = [[self propertyContainer] getSizePercentageContainer:@"height" defaultValue:0.0f];
    _heightWasDefined = [_height propertyWasDefined];
    
    _topPosition = [[self propertyContainer] getSizePercentageContainer:@"top_position" defaultValue:0.0f];
    _topPositionWasDefined = [_topPosition propertyWasDefined];
    _leftPosition = [[self propertyContainer] getSizePercentageContainer:@"left_position" defaultValue:0.0f];
    _leftPositionWasDefined = [_leftPosition propertyWasDefined];
    
    IXSizePercentageContainer* defaultPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.default" defaultValue:0.0f];
    IXSizePercentageContainer* defaultMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.default" defaultValue:0.0f];
    
    _paddingInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                             top:[[self propertyContainer] getSizePercentageContainer:@"padding.top"
                                                                                                   defaultValue:defaultPadding.value]
                                                            left:[[self propertyContainer] getSizePercentageContainer:@"padding.left"
                                                                                                   defaultValue:defaultPadding.value]
                                                          bottom:[[self propertyContainer] getSizePercentageContainer:@"padding.bottom"
                                                                                                   defaultValue:defaultPadding.value]
                                                           right:[[self propertyContainer] getSizePercentageContainer:@"padding.right"
                                                                                                   defaultValue:defaultPadding.value]];
    
    _marginInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                            top:[[self propertyContainer] getSizePercentageContainer:@"margin.top"
                                                                                                 defaultValue:defaultMargin.value]
                                                           left:[[self propertyContainer] getSizePercentageContainer:@"margin.left"
                                                                                                 defaultValue:defaultMargin.value]
                                                         bottom:[[self propertyContainer] getSizePercentageContainer:@"margin.bottom"
                                                                                                 defaultValue:defaultMargin.value]
                                                          right:[[self propertyContainer] getSizePercentageContainer:@"margin.right"
                                                                                                 defaultValue:defaultMargin.value]];
    
}

@end
