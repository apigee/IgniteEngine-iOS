//
//  IXControlLayoutInfo.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/23/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXControlLayoutInfo.h"
#import "IXPropertyContainer.h"

// Attributes
IX_STATIC_CONST_STRING kIXVisible = @"visible";
// TODO: These are bool values - should be .enabled
IX_STATIC_CONST_STRING kIXFillRemainingWidth = @"autofill.w";
IX_STATIC_CONST_STRING kIXFillRemainingHeight = @"autofill.h";
// TODO: This is a bool value - should be .enabled
IX_STATIC_CONST_STRING kIXIncludeInParentAutosize = @"autosize.includeInParent";
// TODO: Suggest simply "layout"
IX_STATIC_CONST_STRING kIXLayoutType = @"layoutType";
IX_STATIC_CONST_STRING kIXVerticalAlignment = @"align.v";
IX_STATIC_CONST_STRING kIXVerticalAlignmentX = @"align.vertical";
IX_STATIC_CONST_STRING kIXHorizontalAlignment = @"align.h";
IX_STATIC_CONST_STRING kIXHorizontalAlignmentX = @"align.horizontal";
IX_STATIC_CONST_STRING kIXTopPosition = @"position.t";
IX_STATIC_CONST_STRING kIXLeftPosition = @"position.l";
IX_STATIC_CONST_STRING kIXBottomPosition = @"position.b";
IX_STATIC_CONST_STRING kIXPadding = @"padding"; // sets all 4 sides to this value.
IX_STATIC_CONST_STRING kIXPaddingTop = @"padding.top";
IX_STATIC_CONST_STRING kIXPaddingRight = @"padding.right";
IX_STATIC_CONST_STRING kIXPaddingBottom = @"padding.bottom";
IX_STATIC_CONST_STRING kIXPaddingLeft = @"padding.left";
IX_STATIC_CONST_STRING kIXMargin = @"margin"; // sets all 4 sides to this value.
IX_STATIC_CONST_STRING kIXMarginTop = @"margin.top";
IX_STATIC_CONST_STRING kIXMarginRight = @"margin.right";
IX_STATIC_CONST_STRING kIXMarginBottom = @"margin.bottom";
IX_STATIC_CONST_STRING kIXMarginLeft = @"margin.left";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXLayoutTypeRelative = @"relative"; // layoutType
IX_STATIC_CONST_STRING kIXLayoutTypeAbsolute = @"absolute"; // layoutType
IX_STATIC_CONST_STRING kIXLayoutTypeFloat = @"float"; // layoutType
IX_STATIC_CONST_STRING kIXTop = @"top"; // align.v
IX_STATIC_CONST_STRING kIXVerticalCenter = @"middle"; // align.v
IX_STATIC_CONST_STRING kIXVerticalCenterAlt = @"center"; // align.v
IX_STATIC_CONST_STRING kIXBottom = @"bottom"; // align.v
IX_STATIC_CONST_STRING kIXLeft = @"left"; // align.h
IX_STATIC_CONST_STRING kIXHorizontalCenter = @"center"; // align.h
IX_STATIC_CONST_STRING kIXRight = @"right"; // align.h

// Attribute Value Defaults
IX_STATIC_CONST_STRING kIXDefaultLayoutTypeRelative = @"relative"; // Default layout type

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

// Internal Properties
IX_STATIC_CONST_STRING kIXAlign = @"align"; // used as prefix to determine if control is a layout control
IX_STATIC_CONST_STRING kIXPosition = @"position"; // used as prefix to determine if control is a layout control
IX_STATIC_CONST_STRING kIXSize = @"size"; // used as prefix to determine if control is a layout control

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
    _layoutRect = CGRectZero;
    
    _isHidden = ![[self propertyContainer] getBoolPropertyValue:kIXVisible defaultValue:YES];
    _fillRemainingWidth = [[self propertyContainer] getBoolPropertyValue:kIXFillRemainingWidth defaultValue:NO];
    _fillRemainingHeight = [[self propertyContainer] getBoolPropertyValue:kIXFillRemainingHeight defaultValue:NO];
    _canPushParentsBounds = [[self propertyContainer] getBoolPropertyValue:kIXIncludeInParentAutosize defaultValue:YES];

    NSString* layoutType = [[self propertyContainer] getStringPropertyValue:kIXLayoutType defaultValue:kIXDefaultLayoutTypeRelative];
    _isFloatPositioned = [layoutType isEqualToString:kIXLayoutTypeFloat];
    _isAbsolutePositioned = (_isFloatPositioned || [layoutType isEqualToString:kIXLayoutTypeAbsolute] );
    
    _verticalAlignment = IXLayoutVerticalAlignmentTop;
    
    NSString* verticalAlignmentString = ([[self propertyContainer] getStringPropertyValue:kIXVerticalAlignment defaultValue:nil]) ?: [[self propertyContainer] getStringPropertyValue:kIXVerticalAlignmentX defaultValue:kIXTop];
    
    if( [verticalAlignmentString isEqualToString:kIXTop] )
        _verticalAlignment = IXLayoutVerticalAlignmentTop;
    else if( [verticalAlignmentString isEqualToString:kIXVerticalCenter] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:kIXVerticalCenterAlt] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:kIXBottom] )
        _verticalAlignment = IXLayoutVerticalAlignmentBottom;
    
    _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    NSString* horizontalAlignmentString = ([[self propertyContainer] getStringPropertyValue:kIXHorizontalAlignment defaultValue:nil]) ?: [[self propertyContainer] getStringPropertyValue:kIXHorizontalAlignmentX defaultValue:kIXLeft];
    
    if( [horizontalAlignmentString isEqualToString:kIXLeft] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentRight;
    else if( [horizontalAlignmentString isEqualToString:kIXHorizontalCenter] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignmentString isEqualToString:kIXRight] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    IXSize* size = [[self propertyContainer] getSizePropertyValueWithPrefix:nil];
    _width = ixSizePercentageValueWithStringOrDefaultValue(size.width, 0.0f);
    _height = ixSizePercentageValueWithStringOrDefaultValue(size.height, 0.0f);
    _topPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXTopPosition defaultValue:nil], 0.0f);
    _leftPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXLeftPosition defaultValue:nil], 0.0f);
    _bottomPosition = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXBottomPosition defaultValue:nil], 0.0f);
    
    _paddingInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXPadding defaultValue:nil], 0.0f);
    
    CGFloat defaultPaddingValue = _paddingInsets.defaultInset.value;
    _paddingInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXPaddingTop defaultValue:nil], defaultPaddingValue);
    _paddingInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXPaddingLeft defaultValue:nil], defaultPaddingValue);
    _paddingInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXPaddingBottom defaultValue:nil], defaultPaddingValue);
    _paddingInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXPaddingRight defaultValue:nil], defaultPaddingValue);
    
    _marginInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXMargin defaultValue:nil], 0.0f);
    
    CGFloat defaultMarginValue = _marginInsets.defaultInset.value;
    _marginInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXMarginTop defaultValue:nil], defaultMarginValue);
    _marginInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXMarginLeft defaultValue:nil], defaultMarginValue);
    _marginInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXMarginBottom defaultValue:nil], defaultMarginValue);
    _marginInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self propertyContainer] getStringPropertyValue:kIXMarginRight defaultValue:nil], defaultMarginValue);
    
    _widthWasDefined = _width.propertyWasDefined;
    _heightWasDefined = _height.propertyWasDefined;
    _topPositionWasDefined = _topPosition.propertyWasDefined;
    _leftPositionWasDefined = _leftPosition.propertyWasDefined;
    _bottomPositionWasDefined = _bottomPosition.propertyWasDefined;
}

+(BOOL)doesPropertyNameTriggerLayout:(NSString*)propertyName
{
    if([propertyName isEqualToString:kIXVisible] ||
       [propertyName isEqualToString:kIXLayoutType] ||
       [propertyName containsString:kIXSize] ||
       [propertyName hasPrefix:kIXMargin] ||
       [propertyName hasPrefix:kIXPadding] ||
       [propertyName hasPrefix:kIXPosition] ||
       [propertyName hasPrefix:kIXAlign]) {
        return YES;
    } else {
        return NO;
    }
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

UIEdgeInsets ixEvaluateEdgeInsets(IXEdgeInsets edgeInsets, CGSize maxSize)
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

IXSizeValuePercentage ixSizePercentageValueWithStringOrDefaultValue(NSString* stringValue, CGFloat defaultValue)
{
    IXSizeValuePercentage sizeValuePercentage = IXSizeValuePercentageZero();
    sizeValuePercentage.propertyWasDefined = ( stringValue != nil );
    if( sizeValuePercentage.propertyWasDefined )
    {
        sizeValuePercentage.isPercentage = [stringValue hasSuffix:@"\%"];
        if( sizeValuePercentage.isPercentage )
        {
            sizeValuePercentage.value = [[stringValue stringByReplacingOccurrencesOfString:@"\%" withString:kIX_EMPTY_STRING] floatValue] / 100.0f;
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

CGFloat ixEvaluateSizeValuePercentageForMaxValue(IXSizeValuePercentage sizeValuePercentage, CGFloat maxValue)
{
    CGFloat returnFloat = sizeValuePercentage.value;
    if( sizeValuePercentage.isPercentage )
    {
        returnFloat = returnFloat * maxValue;
    }
    return returnFloat;
}

@end
