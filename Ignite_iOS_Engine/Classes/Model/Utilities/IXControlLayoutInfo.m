//
//  IXControlLayoutInfo.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/23/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXControlLayoutInfo.h"
#import "IXPropertyContainer.h"

@interface IXControlLayoutInfo ()

@property (nonatomic,assign) BOOL isHidden;
@property (nonatomic,assign) BOOL fillRemainingWidth;
@property (nonatomic,assign) BOOL fillRemainingHeight;
@property (nonatomic,assign) BOOL canPushParentsBounds;
@property (nonatomic,assign) BOOL isFloatPositioned;
@property (nonatomic,assign) BOOL isAbsolutePositioned;

@property (nonatomic,assign) IXLayoutVerticalAlignment verticalAlignment;
@property (nonatomic,assign) IXLayoutHorizontalAlignment horizontalAlignment;

@property (nonatomic,assign) BOOL widthWasDefined;
@property (nonatomic,assign) IXSizeValuePercentage width;
@property (nonatomic,assign) BOOL heightWasDefined;
@property (nonatomic,assign) IXSizeValuePercentage height;
@property (nonatomic,assign) BOOL topPositionWasDefined;
@property (nonatomic,assign) IXSizeValuePercentage topPosition;
@property (nonatomic,assign) BOOL leftPositionWasDefined;
@property (nonatomic,assign) IXSizeValuePercentage leftPosition;

@property (nonatomic,assign) IXEdgeInsets marginInsets;
@property (nonatomic,assign) IXEdgeInsets paddingInsets;

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
        
        _height = IXSizeValuePercentageZero();
        _width = IXSizeValuePercentageZero();
        _topPosition = IXSizeValuePercentageZero();
        _leftPosition = IXSizeValuePercentageZero();
        _bottomPosition = IXSizeValuePercentageZero();
        
        _marginInsets = IXEdgeInsetsZero();
        _paddingInsets = IXEdgeInsetsZero();
        
        [self refreshLayoutInfo];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXControlLayoutInfo* layoutInfoCopy = [[[self class] allocWithZone:zone] initWithPropertyContainer:[self propertyContainer]];
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
    
    _width = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"width" defaultValue:nil], 0.0f);
    _height = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"height" defaultValue:nil], 0.0f);
    _topPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"top_position" defaultValue:nil], 0.0f);
    _leftPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"left_position" defaultValue:nil], 0.0f);
    _bottomPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"bottom_position" defaultValue:nil], 0.0f);
    
    _paddingInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"padding" defaultValue:nil], 0.0f);
    
    CGFloat defaultPaddingValue = _paddingInsets.defaultInset.value;
    _paddingInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"padding.top" defaultValue:nil], defaultPaddingValue);
    _paddingInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"padding.left" defaultValue:nil], defaultPaddingValue);
    _paddingInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"padding.bottom" defaultValue:nil], defaultPaddingValue);
    _paddingInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"padding.right" defaultValue:nil], defaultPaddingValue);
    
    _marginInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"margin" defaultValue:nil], 0.0f);
    
    CGFloat defaultMarginValue = _marginInsets.defaultInset.value;
    _marginInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"margin.top" defaultValue:nil], defaultMarginValue);
    _marginInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"margin.left" defaultValue:nil], defaultMarginValue);
    _marginInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"margin.bottom" defaultValue:nil], defaultMarginValue);
    _marginInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:@"margin.right" defaultValue:nil], defaultMarginValue);
    
    _widthWasDefined = _width.propertyWasDefined;
    _heightWasDefined = _height.propertyWasDefined;
    _topPositionWasDefined = _topPosition.propertyWasDefined;
    _leftPositionWasDefined = _leftPosition.propertyWasDefined;
    _bottomPositionWasDefined = _bottomPosition.propertyWasDefined;
}

+(BOOL)doesPropertyNameTriggerLayout:(NSString*)propertyName
{
    BOOL triggersLayout = NO;
    if( [propertyName isEqualToString:@"visible"] || [propertyName isEqualToString:@"layout_type"] )
    {
        triggersLayout = YES;
    }
    else if( [propertyName rangeOfString:@"height"].location != NSNotFound || [propertyName rangeOfString:@"width"].location != NSNotFound  )
    {
        triggersLayout = YES;
    }
    else if( [propertyName hasPrefix:@"margin"] || [propertyName hasPrefix:@"padding"] )
    {
        triggersLayout = YES;
    }
    else if( [propertyName hasSuffix:@"position"] || [propertyName hasSuffix:@"alignment"] )
    {
        triggersLayout = YES;
    }
    return triggersLayout;
}

IXEdgeInsets IXEdgeInsetsZero()
{
    IXEdgeInsets edgeInsets;
    edgeInsets.defaultInset = IXSizeValuePercentageZero();
    edgeInsets.top = IXSizeValuePercentageZero();
    edgeInsets.left = IXSizeValuePercentageZero();
    edgeInsets.bottom = IXSizeValuePercentageZero();
    edgeInsets.right = IXSizeValuePercentageZero();
    return edgeInsets;
}

-(UIEdgeInsets)evaluateEdgeInsets:(IXEdgeInsets)edgeInsets usingMaxSize:(CGSize)maxSize
{
    return UIEdgeInsetsMake(ixEvaluateSizeValuePercentageForMaxValue(edgeInsets.top, maxSize.height),
                            ixEvaluateSizeValuePercentageForMaxValue(edgeInsets.left, maxSize.width),
                            ixEvaluateSizeValuePercentageForMaxValue(edgeInsets.bottom, maxSize.height),
                            ixEvaluateSizeValuePercentageForMaxValue(edgeInsets.right, maxSize.width));
}

IXSizeValuePercentage IXSizeValuePercentageZero()
{
    IXSizeValuePercentage sizeValuePercentage;
    sizeValuePercentage.propertyWasDefined = NO;
    sizeValuePercentage.isPercentage = NO;
    sizeValuePercentage.value = 0.0f;
    return sizeValuePercentage;
}

IXSizeValuePercentage ixSizePercentageValueWithStringOrDefaultValue(NSString* stringValue, float defaultValue)
{
    IXSizeValuePercentage sizeValuePercentage = IXSizeValuePercentageZero();
    sizeValuePercentage.propertyWasDefined = ( stringValue != nil );
    if( sizeValuePercentage.propertyWasDefined )
    {
        sizeValuePercentage.isPercentage = [stringValue hasSuffix:@"\%"];
        if( sizeValuePercentage.isPercentage )
        {
            sizeValuePercentage.value = [[stringValue stringByReplacingOccurrencesOfString:@"\%" withString:@""] floatValue] / 100.0f;
        }
        else
        {
            sizeValuePercentage.value = [stringValue floatValue];
        }
    }
    else
    {
        sizeValuePercentage.isPercentage = NO;
        sizeValuePercentage.value = defaultValue;
    }
    return sizeValuePercentage;
}

float ixEvaluateSizeValuePercentageForMaxValue(IXSizeValuePercentage sizeValuePercentage, CGFloat maxValue)
{
    float returnFloat = sizeValuePercentage.value;
    if( sizeValuePercentage.isPercentage )
    {
        returnFloat = returnFloat * maxValue;
    }
    return returnFloat;
}

@end
