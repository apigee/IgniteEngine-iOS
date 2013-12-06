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
            _propertyDefined = YES;
            _percentage = [stringValue hasSuffix:@"\%"];
            if( _percentage )
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
            _propertyDefined = NO;
            _percentage = NO;
            _value = defaultValue;
        }
    }
    return self;
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
    IXControlLayoutInfo* layoutInfoCopy = [[[self class] allocWithZone:zone] init];
    [layoutInfoCopy setPropertyContainer:_propertyContainer];
    [layoutInfoCopy setNeedsToRelayout:YES];
    [layoutInfoCopy setHasSeenLayout:NO];
    [layoutInfoCopy setLayoutRect:CGRectZero];
    [layoutInfoCopy setFillRemainingHeight:_fillRemainingHeight];
    [layoutInfoCopy setFillRemainingWidth:_fillRemainingWidth];
    [layoutInfoCopy setCanPushParentsBounds:_canPushParentsBounds];
    [layoutInfoCopy setIsFloatPositioned:_isFloatPositioned];
    [layoutInfoCopy setIsAbsolutePositioned:_isAbsolutePositioned];
    [layoutInfoCopy setVerticalAlignment:_verticalAlignment];
    [layoutInfoCopy setHorizontalAlignment:_horizontalAlignment];
    [layoutInfoCopy setWidth:_width];
    [layoutInfoCopy setWidthWasDefined:_widthWasDefined];
    [layoutInfoCopy setHeight:_height];
    [layoutInfoCopy setHeightWasDefined:_heightWasDefined];
    [layoutInfoCopy setTopPosition:_topPosition];
    [layoutInfoCopy setTopPositionWasDefined:_topPositionWasDefined];
    [layoutInfoCopy setLeftPosition:_leftPosition];
    [layoutInfoCopy setLeftPositionWasDefined:_leftPositionWasDefined];
    [layoutInfoCopy setPaddingInsets:_paddingInsets];
    [layoutInfoCopy setMarginInsets:_marginInsets];
    return layoutInfoCopy;
}

-(void)refreshLayoutInfo
{
    _needsToRelayout = NO;
    _hasSeenLayout = NO;
    _layoutRect = CGRectZero;
    
    BOOL isHidden = ![[self propertyContainer] getBoolPropertyValue:@"visible" defaultValue:YES];
    if( _isHidden != isHidden )
    {
        _isHidden = isHidden;
        _needsToRelayout = YES;
    }
    
    BOOL fillRemainingWidth = [[self propertyContainer] getBoolPropertyValue:@"fill_remaining_width" defaultValue:NO];
    if( _fillRemainingWidth != fillRemainingWidth )
    {
        _fillRemainingWidth = fillRemainingWidth;
        _needsToRelayout = YES;
    }
    
    BOOL fillRemainingHeight = [[self propertyContainer] getBoolPropertyValue:@"fill_remaining_height" defaultValue:NO];
    if( _fillRemainingHeight != fillRemainingHeight )
    {
        _fillRemainingHeight = fillRemainingHeight;
        _needsToRelayout = YES;
    }

    BOOL canPushParentsBounds = [[self propertyContainer] getBoolPropertyValue:@"include_in_parent_autosize" defaultValue:YES];
    if( _canPushParentsBounds != canPushParentsBounds )
    {
        _canPushParentsBounds = canPushParentsBounds;
        _needsToRelayout = YES;
    }

    NSString* layoutType = [[self propertyContainer] getStringPropertyValue:@"layout_type" defaultValue:@"relative"];
    BOOL isFloatPositioned = [layoutType isEqualToString:@"float"];
    BOOL isAbsolutePositioned = [layoutType isEqualToString:@"absolute"] || _isFloatPositioned;
    if( _isFloatPositioned != isFloatPositioned )
    {
        _isFloatPositioned = isFloatPositioned;
        _needsToRelayout = YES;
    }
    if( _isAbsolutePositioned != isAbsolutePositioned )
    {
        _isAbsolutePositioned = isAbsolutePositioned;
        _needsToRelayout = YES;
    }
    
    NSString* verticalAlignmentString = [[self propertyContainer] getStringPropertyValue:@"vertical_alignment" defaultValue:@"top"];
    NSString* horizontalAlignmentString = [[self propertyContainer] getStringPropertyValue:@"horizontal_alignment" defaultValue:@"left"];
    
    IXLayoutVerticalAlignment verticalAlignment = IXLayoutVerticalAlignmentTop;
    IXLayoutHorizontalAlignment horizontalAlignment = IXLayoutHorizontalAlignmentLeft;

    if( [verticalAlignmentString isEqualToString:@"top"] )
        verticalAlignment = IXLayoutVerticalAlignmentTop;
    else if( [verticalAlignmentString isEqualToString:@"middle"] )
        verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:@"bottom"] )
        verticalAlignment = IXLayoutVerticalAlignmentBottom;
    
    if( [horizontalAlignmentString isEqualToString:@"left"] )
        horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    else if( [horizontalAlignmentString isEqualToString:@"center"] )
        horizontalAlignment = IXLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignmentString isEqualToString:@"right"] )
        horizontalAlignment = IXLayoutHorizontalAlignmentRight;
    
    if( _verticalAlignment != verticalAlignment )
    {
        _verticalAlignment = verticalAlignment;
        _needsToRelayout = YES;
    }
    if( _horizontalAlignment != horizontalAlignment )
    {
        _horizontalAlignment = horizontalAlignment;
        _needsToRelayout = YES;
    }

    IXSizePercentageContainer *width = [[self propertyContainer] getSizePercentageContainer:@"width" defaultValue:0.0f];
    if( ! [[self width] isEqual:width] )
    {
        _width = width;
        _widthWasDefined = [_width propertyWasDefined];
        _needsToRelayout = YES;
    }
    IXSizePercentageContainer *height = [[self propertyContainer] getSizePercentageContainer:@"height" defaultValue:0.0f];
    if( ! [[self height] isEqual:height] )
    {
        _height = height;
        _heightWasDefined = [_height propertyWasDefined];
        _needsToRelayout = YES;
    }
    IXSizePercentageContainer *topPosition = [[self propertyContainer] getSizePercentageContainer:@"top_position" defaultValue:0.0f];
    if( ! [[self topPosition] isEqual:topPosition] )
    {
        _topPosition = topPosition;
        _topPositionWasDefined = [_topPosition propertyWasDefined];
        _needsToRelayout = YES;
    }
    IXSizePercentageContainer *leftPosition = [[self propertyContainer] getSizePercentageContainer:@"left_position" defaultValue:0.0f];
    if( ! [[self leftPosition] isEqual:leftPosition] )
    {
        _leftPosition = leftPosition;
        _leftPositionWasDefined = [_leftPosition propertyWasDefined];
        _needsToRelayout = YES;
    }
    
    IXSizePercentageContainer *defaultPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.default" defaultValue:0.0f];
    if( [self paddingInsets] == nil )
    {
        _needsToRelayout = YES;
        _paddingInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultPadding
                                                                top:[[self propertyContainer] getSizePercentageContainer:@"padding.top"
                                                                                                            defaultValue:defaultPadding.value]
                                                               left:[[self propertyContainer] getSizePercentageContainer:@"padding.left"
                                                                                                            defaultValue:defaultPadding.value]
                                                             bottom:[[self propertyContainer] getSizePercentageContainer:@"padding.bottom"
                                                                                                            defaultValue:defaultPadding.value]
                                                              right:[[self propertyContainer] getSizePercentageContainer:@"padding.right"
                                                                                                            defaultValue:defaultPadding.value]];
    }
    else
    {
        if( ![[_paddingInsets defaultValue] isEqual:defaultPadding] )
        {
            [_paddingInsets setDefaultValue:defaultPadding];
            _needsToRelayout = YES;
        }
        
        CGFloat defaultPaddingsValue = [[_paddingInsets defaultValue] value];
        IXSizePercentageContainer *topPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.top" defaultValue:defaultPaddingsValue];
        if( ![[_paddingInsets top] isEqual:topPadding] )
        {
            [_paddingInsets setTop:topPadding];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *bottomPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.bottom" defaultValue:defaultPaddingsValue];
        if( ![[_paddingInsets bottom] isEqual:bottomPadding] )
        {
            [_paddingInsets setBottom:bottomPadding];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *leftPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.left" defaultValue:defaultPaddingsValue];
        if( ![[_paddingInsets left] isEqual:leftPadding] )
        {
            [_paddingInsets setLeft:leftPadding];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *rightPadding = [[self propertyContainer] getSizePercentageContainer:@"padding.right" defaultValue:defaultPaddingsValue];
        if( ![[_paddingInsets right] isEqual:rightPadding] )
        {
            [_paddingInsets setRight:rightPadding];
            _needsToRelayout = YES;
        }
    }
    
    IXSizePercentageContainer *defaultMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.default" defaultValue:0.0f];
    if( [self marginInsets] == nil )
    {
        _needsToRelayout = YES;
        _marginInsets = [[IXEdgeInsets alloc] initWithDefaultValue:defaultMargin
                                                               top:[[self propertyContainer] getSizePercentageContainer:@"margin.top"
                                                                                                           defaultValue:defaultMargin.value]
                                                              left:[[self propertyContainer] getSizePercentageContainer:@"margin.left"
                                                                                                           defaultValue:defaultMargin.value]
                                                            bottom:[[self propertyContainer] getSizePercentageContainer:@"margin.bottom"
                                                                                                           defaultValue:defaultMargin.value]
                                                             right:[[self propertyContainer] getSizePercentageContainer:@"margin.right"
                                                                                                           defaultValue:defaultMargin.value]];
        
    }
    else
    {
        if( ![[_marginInsets defaultValue] isEqual:defaultMargin] )
        {
            [_marginInsets setDefaultValue:defaultMargin];
            _needsToRelayout = YES;
        }
        
        CGFloat defaultMarginsValue = [[_marginInsets defaultValue] value];
        IXSizePercentageContainer *topMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.top" defaultValue:defaultMarginsValue];
        if( ![[_marginInsets top] isEqual:topMargin] )
        {
            [_marginInsets setTop:topMargin];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *bottomMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.bottom" defaultValue:defaultMarginsValue];
        if( ![[_marginInsets bottom] isEqual:bottomMargin] )
        {
            [_marginInsets setBottom:bottomMargin];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *leftMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.left" defaultValue:defaultMarginsValue];
        if( ![[_marginInsets left] isEqual:leftMargin] )
        {
            [_marginInsets setLeft:leftMargin];
            _needsToRelayout = YES;
        }
        IXSizePercentageContainer *rightMargin = [[self propertyContainer] getSizePercentageContainer:@"margin.right" defaultValue:defaultMarginsValue];
        if( ![[_marginInsets right] isEqual:rightMargin] )
        {
            [_marginInsets setRight:rightMargin];
            _needsToRelayout = YES;
        }
    }
}

@end
