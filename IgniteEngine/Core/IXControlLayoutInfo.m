//
//  IXControlLayoutInfo.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/23/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXControlLayoutInfo.h"
#import "IXAttributeContainer.h"

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

@synthesize attributeContainer = _attributeContainer;

-(instancetype)init
{
    return [self initWithAttributeContainer:nil];
}

+(instancetype)controlLayoutInfoWithPropertyContainer:(IXAttributeContainer*)attributeContainer
{
    return [[[self class] alloc] initWithAttributeContainer:attributeContainer];
}

-(instancetype)initWithAttributeContainer:(IXAttributeContainer *)attributeContainer
{
    self = [super init];
    if( self != nil )
    {
        _attributeContainer = attributeContainer;
        
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
    IXControlLayoutInfo* layoutInfoCopy = [[[self class] allocWithZone:zone] initWithAttributeContainer:[self attributeContainer]];
    return layoutInfoCopy;
}

-(void)refreshLayoutInfo
{
    _layoutRect = CGRectZero;
    
    _isHidden = ![[self attributeContainer] getBoolValueForAttribute:kIXVisible defaultValue:YES];
    _fillRemainingWidth = [[self attributeContainer] getBoolValueForAttribute:kIXFillRemainingWidth defaultValue:NO];
    _fillRemainingHeight = [[self attributeContainer] getBoolValueForAttribute:kIXFillRemainingHeight defaultValue:NO];
    _canPushParentsBounds = [[self attributeContainer] getBoolValueForAttribute:kIXIncludeInParentAutosize defaultValue:YES];

    NSString* layoutType = [[self attributeContainer] getStringValueForAttribute:kIXLayoutType defaultValue:kIXDefaultLayoutTypeRelative];
    _isFloatPositioned = [layoutType isEqualToString:kIXLayoutTypeFloat];
    _isAbsolutePositioned = (_isFloatPositioned || [layoutType isEqualToString:kIXLayoutTypeAbsolute] );
    
    _verticalAlignment = IXLayoutVerticalAlignmentTop;
    
    NSString* verticalAlignmentString = ([[self attributeContainer] getStringValueForAttribute:kIXVerticalAlignment defaultValue:nil]) ?: [[self attributeContainer] getStringValueForAttribute:kIXVerticalAlignmentX defaultValue:kIXTop];
    
    if( [verticalAlignmentString isEqualToString:kIXTop] )
        _verticalAlignment = IXLayoutVerticalAlignmentTop;
    else if( [verticalAlignmentString isEqualToString:kIXVerticalCenter] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:kIXVerticalCenterAlt] )
        _verticalAlignment = IXLayoutVerticalAlignmentMiddle;
    else if( [verticalAlignmentString isEqualToString:kIXBottom] )
        _verticalAlignment = IXLayoutVerticalAlignmentBottom;
    
    _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    NSString* horizontalAlignmentString = ([[self attributeContainer] getStringValueForAttribute:kIXHorizontalAlignment defaultValue:nil]) ?: [[self attributeContainer] getStringValueForAttribute:kIXHorizontalAlignmentX defaultValue:kIXLeft];
    
    if( [horizontalAlignmentString isEqualToString:kIXLeft] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentRight;
    else if( [horizontalAlignmentString isEqualToString:kIXHorizontalCenter] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentCenter;
    else if( [horizontalAlignmentString isEqualToString:kIXRight] )
        _horizontalAlignment = IXLayoutHorizontalAlignmentLeft;
    
    IXSize* size = [[self attributeContainer] getSizeValueForAttributeWithPrefix:nil];
    _width = ixSizePercentageValueWithStringOrDefaultValue(size.width, 0.0f);
    _height = ixSizePercentageValueWithStringOrDefaultValue(size.height, 0.0f);
    _topPosition = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXTopPosition defaultValue:nil], 0.0f);
    _leftPosition = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXLeftPosition defaultValue:nil], 0.0f);
    _bottomPosition = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXBottomPosition defaultValue:nil], 0.0f);
    
    _paddingInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXPadding defaultValue:nil], 0.0f);
    
    CGFloat defaultPaddingValue = _paddingInsets.defaultInset.value;
    _paddingInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXPaddingTop defaultValue:nil], defaultPaddingValue);
    _paddingInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXPaddingLeft defaultValue:nil], defaultPaddingValue);
    _paddingInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXPaddingBottom defaultValue:nil], defaultPaddingValue);
    _paddingInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXPaddingRight defaultValue:nil], defaultPaddingValue);
    
    _marginInsets.defaultInset = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXMargin defaultValue:nil], 0.0f);
    
    CGFloat defaultMarginValue = _marginInsets.defaultInset.value;
    _marginInsets.top = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXMarginTop defaultValue:nil], defaultMarginValue);
    _marginInsets.left = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXMarginLeft defaultValue:nil], defaultMarginValue);
    _marginInsets.bottom = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXMarginBottom defaultValue:nil], defaultMarginValue);
    _marginInsets.right = ixSizePercentageValueWithStringOrDefaultValue([[self attributeContainer] getStringValueForAttribute:kIXMarginRight defaultValue:nil], defaultMarginValue);
    
    _widthWasDefined = _width.propertyWasDefined;
    _heightWasDefined = _height.propertyWasDefined;
    _topPositionWasDefined = _topPosition.propertyWasDefined;
    _leftPositionWasDefined = _leftPosition.propertyWasDefined;
    _bottomPositionWasDefined = _bottomPosition.propertyWasDefined;
}

+(BOOL)doesAttributeTriggerLayout:(NSString*)propertyName
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
