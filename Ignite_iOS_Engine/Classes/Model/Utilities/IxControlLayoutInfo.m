//
//  IxControlLayoutInfo.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/23.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxControlLayoutInfo.h"
#import "IxPropertyContainer.h"

@implementation IxSizePercentageContainer

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

@implementation IxEdgeInsets

-(instancetype)init
{
    return [self initWithDefaultValue:nil top:nil left:nil bottom:nil right:nil];
}

+(instancetype)edgeInsetsWithDefaultValue:(IxSizePercentageContainer*)defaultValue
                                      top:(IxSizePercentageContainer*)top
                                     left:(IxSizePercentageContainer*)left
                                   bottom:(IxSizePercentageContainer*)bottom
                                    right:(IxSizePercentageContainer*)right
{
    return [[[self class] alloc] initWithDefaultValue:defaultValue top:top left:left bottom:bottom right:right];
}

-(instancetype)initWithDefaultValue:(IxSizePercentageContainer*)defaultValue
                                top:(IxSizePercentageContainer*)top
                               left:(IxSizePercentageContainer*)left
                             bottom:(IxSizePercentageContainer*)bottom
                              right:(IxSizePercentageContainer*)right
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

@implementation IxControlLayoutInfo

@synthesize propertyContainer = _propertyContainer;

-(instancetype)init
{
    return [self initWithPropertyContainer:nil];
}

+(instancetype)controlLayoutInfoWithPropertyContainer:(IxPropertyContainer*)propertyContainer
{
    return [[[self class] alloc] initWithPropertyContainer:propertyContainer];
}

-(instancetype)initWithPropertyContainer:(IxPropertyContainer *)propertyContainer
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
        _verticalAlignment = IxLayoutVerticalAlignmentTop;
    else if( [verticalAlignment isEqualToString:@"middle"] )
        _verticalAlignment = IxLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignment isEqualToString:@"bottom"] )
        _verticalAlignment = IxLayoutVerticalAlignmentBottom;
    
    NSString* horizontalAlignment = [[self propertyContainer] getStringPropertyValue:@"horizontal_alignment" defaultValue:@"left"];
    if( [horizontalAlignment isEqualToString:@"left"] )
        _horizontalAlignment = IxLayoutHorizontalAlignmentLeft;
    else if( [horizontalAlignment isEqualToString:@"center"] )
        _horizontalAlignment = IxLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignment isEqualToString:@"right"] )
        _horizontalAlignment = IxLayoutHorizontalAlignmentRight;
    
    _width = [[self propertyContainer] getSizePercentageContainer:@"width" defaultValue:0.0f];
    _widthWasDefined = [_width propertyWasDefined];
    _height = [[self propertyContainer] getSizePercentageContainer:@"height" defaultValue:0.0f];
    _heightWasDefined = [_height propertyWasDefined];
    
    _topPosition = [[self propertyContainer] getSizePercentageContainer:@"top_position" defaultValue:0.0f];
    _topPositionWasDefined = [_topPosition propertyWasDefined];
    _leftPosition = [[self propertyContainer] getSizePercentageContainer:@"left_position" defaultValue:0.0f];
    _leftPositionWasDefined = [_leftPosition propertyWasDefined];
    
    IxSizePercentageContainer* defaultPadding = [[self propertyContainer] getSizePercentageContainer:@"padding" defaultValue:0.0f];
    IxSizePercentageContainer* defaultMargin = [[self propertyContainer] getSizePercentageContainer:@"margin" defaultValue:0.0f];
    
    _paddingInsets = [[IxEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                             top:[[self propertyContainer] getSizePercentageContainer:@"top_padding"
                                                                                                   defaultValue:defaultPadding.value]
                                                            left:[[self propertyContainer] getSizePercentageContainer:@"left_padding"
                                                                                                   defaultValue:defaultPadding.value]
                                                          bottom:[[self propertyContainer] getSizePercentageContainer:@"bottom_padding"
                                                                                                   defaultValue:defaultPadding.value]
                                                           right:[[self propertyContainer] getSizePercentageContainer:@"right_padding"
                                                                                                   defaultValue:defaultPadding.value]];
    
    _marginInsets = [[IxEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                            top:[[self propertyContainer] getSizePercentageContainer:@"top_margin"
                                                                                                 defaultValue:defaultMargin.value]
                                                           left:[[self propertyContainer] getSizePercentageContainer:@"left_margin"
                                                                                                 defaultValue:defaultMargin.value]
                                                         bottom:[[self propertyContainer] getSizePercentageContainer:@"bottom_margin"
                                                                                                 defaultValue:defaultMargin.value]
                                                          right:[[self propertyContainer] getSizePercentageContainer:@"right_padding"
                                                                                                 defaultValue:defaultMargin.value]];
    
}

@end
