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
        [self applyStringValue:stringValue orDefaultValue:defaultValue];        
    }
    return self;
}

-(BOOL)applyStringValue:(NSString*)stringValue orDefaultValue:(CGFloat)defaultValue
{
    BOOL isPercentage = NO;
    CGFloat value = 0.0f;
    
    _propertyDefined = ( stringValue != nil );
    if( _propertyDefined )
    {
        isPercentage = [stringValue hasSuffix:@"\%"];
        if( isPercentage )
        {
            value = [[stringValue stringByReplacingOccurrencesOfString:@"\%" withString:@""] floatValue] / 100.0f;
        }
        else
        {
            value = [stringValue floatValue];
        }
    }
    else
    {
        isPercentage = NO;
        value = defaultValue;
    }
    
    BOOL returnValue = ( ( _percentage == isPercentage ) && ( _value == value ) );
    
    _percentage = isPercentage;
    _value = value;
    
    return returnValue;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXSizePercentageContainer* containerCopy = [[[self class] allocWithZone:zone] init];
    [containerCopy setValue:[self value]];
    [containerCopy setPercentage:[self isPercentage]];
    [containerCopy setPropertyDefined:[self propertyWasDefined]];
    return containerCopy;
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

-(BOOL)isEqual:(IXSizePercentageContainer*)object
{
    return ( ( self == object ) || ( ([object propertyWasDefined] == _propertyDefined) && ([object isPercentage] == _percentage) && ([object value] == _value) ) );
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

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithDefaultValue:[[self defaultValue] copy]
                                                               top:[[self top] copy]
                                                              left:[[self left] copy]
                                                            bottom:[[self bottom] copy]
                                                             right:[[self right] copy]];
}

-(UIEdgeInsets)evaluateEdgeInsetsUsingMaxSize:(CGSize)maxSize
{
    return UIEdgeInsetsMake([[self top] evaluteForMaxValue:maxSize.height],
                            [[self left] evaluteForMaxValue:maxSize.width],
                            [[self bottom] evaluteForMaxValue:maxSize.height],
                            [[self right] evaluteForMaxValue:maxSize.width]);
}

@end

@interface IXControlLayoutInfo ()

@property (nonatomic,weak) IXPropertyContainer* propertyContainer;

@property (nonatomic,assign) BOOL isHidden;
@property (nonatomic,assign) BOOL fillRemainingWidth;
@property (nonatomic,assign) BOOL fillRemainingHeight;
@property (nonatomic,assign) BOOL canPushParentsBounds;
@property (nonatomic,assign) BOOL isFloatPositioned;
@property (nonatomic,assign) BOOL isAbsolutePositioned;

@property (nonatomic,assign) IXLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign) IXLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign) BOOL widthWasDefined;
@property (nonatomic,copy) IXSizePercentageContainer* width;
@property (nonatomic,assign) BOOL heightWasDefined;
@property (nonatomic,copy) IXSizePercentageContainer* height;
@property (nonatomic,assign) BOOL topPositionWasDefined;
@property (nonatomic,copy) IXSizePercentageContainer* topPosition;
@property (nonatomic,assign) BOOL leftPositionWasDefined;
@property (nonatomic,copy) IXSizePercentageContainer* leftPosition;

@property (nonatomic,copy) IXEdgeInsets* marginInsets;
@property (nonatomic,copy) IXEdgeInsets* paddingInsets;

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

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXControlLayoutInfo* layoutInfoCopy = [[[self class] allocWithZone:zone] initWithPropertyContainer:_propertyContainer];
    return layoutInfoCopy;
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
    _isAbsolutePositioned = (_isFloatPositioned || [layoutType isEqualToString:@"absolute"] );
    
    _verticalAlignment = IXLayoutVerticalAlignmentTop;
    
    NSString* verticalAlignmentString = [[self propertyContainer] getStringPropertyValue:@"vertical_alignment" defaultValue:@"top"];
    if( [verticalAlignmentString isEqualToString:@"top"] )
        _verticalAlignment = IXLayoutVerticalAlignmentTop;
    else if( [verticalAlignmentString isEqualToString:@"middle"] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:@"bottom"] )
        _verticalAlignment = IXLayoutVerticalAlignmentBottom;
    
    _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    NSString* horizontalAlignmentString = [[self propertyContainer] getStringPropertyValue:@"horizontal_alignment" defaultValue:@"left"];
    if( [horizontalAlignmentString isEqualToString:@"left"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentRight;
    else if( [horizontalAlignmentString isEqualToString:@"center"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignmentString isEqualToString:@"right"] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    if( _width == nil )
        _width = [[self propertyContainer] getSizePercentageContainer:@"width" defaultValue:0.0f];
    else
        [_width applyStringValue:[[self propertyContainer] getStringPropertyValue:@"width" defaultValue:nil] orDefaultValue:0.0f];
    
    if( _height == nil )
        _height = [[self propertyContainer] getSizePercentageContainer:@"height" defaultValue:0.0f];
    else
        [_height applyStringValue:[[self propertyContainer] getStringPropertyValue:@"height" defaultValue:nil] orDefaultValue:0.0f];
    
    if( _topPosition == nil )
        _topPosition = [[self propertyContainer] getSizePercentageContainer:@"top_position" defaultValue:0.0f];
    else
        [_topPosition applyStringValue:[[self propertyContainer] getStringPropertyValue:@"top_position" defaultValue:nil] orDefaultValue:0.0f];
    
    if( _leftPosition == nil )
        _leftPosition = [[self propertyContainer] getSizePercentageContainer:@"left_position" defaultValue:0.0f];
    else
        [_leftPosition applyStringValue:[[self propertyContainer] getStringPropertyValue:@"left_position" defaultValue:nil] orDefaultValue:0.0f];
    
    if( _paddingInsets == nil )
    {
        IXSizePercentageContainer *defaultPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.default" defaultValue:0.0f];
        CGFloat defaultPaddingValue = [defaultPadding value];
        
        _paddingInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                                top:[[self propertyContainer] getSizePercentageContainer:@"padding.top"
                                                                                                            defaultValue:defaultPaddingValue]
                                                               left:[[self propertyContainer] getSizePercentageContainer:@"padding.left"
                                                                                                            defaultValue:defaultPaddingValue]
                                                             bottom:[[self propertyContainer] getSizePercentageContainer:@"padding.bottom"
                                                                                                            defaultValue:defaultPaddingValue]
                                                              right:[[self propertyContainer] getSizePercentageContainer:@"padding.right"
                                                                                                            defaultValue:defaultPaddingValue]];
    }
    else
    {
        [[_paddingInsets defaultValue] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"padding.default" defaultValue:nil] orDefaultValue:0.0f];
        
        CGFloat defaultPaddingsValue = [[_paddingInsets defaultValue] value];
        
        [[_paddingInsets top] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"padding.top" defaultValue:nil]
                              orDefaultValue:defaultPaddingsValue];
        [[_paddingInsets bottom] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"padding.bottom" defaultValue:nil]
                                 orDefaultValue:defaultPaddingsValue];
        [[_paddingInsets left] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"padding.left" defaultValue:nil]
                               orDefaultValue:defaultPaddingsValue];
        [[_paddingInsets right] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"padding.right" defaultValue:nil]
                                orDefaultValue:defaultPaddingsValue];

    }
    
    if( _marginInsets == nil )
    {
        IXSizePercentageContainer *defaultMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.default" defaultValue:0.0f];
        CGFloat defaultMarginValue = [defaultMargin value];
        
        _marginInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultMargin
                                                               top:[[self propertyContainer] getSizePercentageContainer:@"margin.top"
                                                                                                           defaultValue:defaultMarginValue]
                                                              left:[[self propertyContainer] getSizePercentageContainer:@"margin.left"
                                                                                                           defaultValue:defaultMarginValue]
                                                            bottom:[[self propertyContainer] getSizePercentageContainer:@"margin.bottom"
                                                                                                           defaultValue:defaultMarginValue]
                                                             right:[[self propertyContainer] getSizePercentageContainer:@"margin.right"
                                                                                                           defaultValue:defaultMarginValue]];
    }
    else
    {
        [[_marginInsets defaultValue] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"margin.default" defaultValue:nil] orDefaultValue:0.0f];

        CGFloat defaultMarginsValue = [[_marginInsets defaultValue] value];
        
        [[_marginInsets top] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"margin.top" defaultValue:nil]
                             orDefaultValue:defaultMarginsValue];
        [[_marginInsets bottom] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"margin.bottom" defaultValue:nil]
                                orDefaultValue:defaultMarginsValue];
        [[_marginInsets left] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"margin.left" defaultValue:nil]
                              orDefaultValue:defaultMarginsValue];
        [[_marginInsets right] applyStringValue:[[self propertyContainer] getStringPropertyValue:@"margin.right" defaultValue:nil]
                               orDefaultValue:defaultMarginsValue];
    }
    
    _widthWasDefined = [_width propertyWasDefined];
    _heightWasDefined = [_height propertyWasDefined];
    _topPositionWasDefined = [_topPosition propertyWasDefined];
    _leftPositionWasDefined = [_leftPosition propertyWasDefined];
}

@end
