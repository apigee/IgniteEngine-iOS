//
//  IXSlider.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/10/14.
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

#import "IXSlider.h"

#import "NSString+IXAdditions.h"
#import "UIImage+ImageEffects.h"

// Slider Properties
IX_STATIC_CONST_STRING kIXInitialValue = @"value.default";
IX_STATIC_CONST_STRING kIXTint = @"tint";
IX_STATIC_CONST_STRING kIXImagesThumb = @"thumbImage";
IX_STATIC_CONST_STRING kIXImagesThumbTint = @"thumbImage.tint";
IX_STATIC_CONST_STRING kIXImagesMinimum = @"image.min";
IX_STATIC_CONST_STRING kIXImagesMinimumTint = @"image.min.tint";
IX_STATIC_CONST_STRING kIXImagesMaximum = @"image.max";
IX_STATIC_CONST_STRING kIXImagesMaximumTint = @"image.max.tint";
IX_STATIC_CONST_STRING kIXMinimumValue = @"value.min";
IX_STATIC_CONST_STRING kIXMaximumValue = @"value.max";
IX_STATIC_CONST_STRING kIXImagesMaximumCapInsets = @"capInsets.max";
IX_STATIC_CONST_STRING kIXImagesMinimumCapInsets = @"capInsets.min";

// Slider Read-Only Properties
IX_STATIC_CONST_STRING kIXValue = @"value";

// Slider Events
IX_STATIC_CONST_STRING kIXValueChanged = @"valueChanged";
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXTouchUp = @"touchUp";

// Slider Functions
IX_STATIC_CONST_STRING kIXUpdateSliderValue = @"setValue"; // Params : "animated"

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXValueNSCodingKey = @"value";

@interface IXSlider ()

@property (nonatomic,strong) UISlider* slider;
@property (nonatomic,assign,getter=isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) NSNumber* encodedValue;

@end

@implementation IXSlider

-(void)dealloc
{
    [_slider removeTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider removeTarget:self action:@selector(sliderDragStarted:) forControlEvents:UIControlEventTouchDown];
    [_slider removeTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_slider removeTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_slider removeTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchCancel];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithFloat:[[self slider] value]] forKey:kIXValueNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setEncodedValue:[aDecoder decodeObjectForKey:kIXValueNSCodingKey]];
    }
    return self;
}

-(void)buildView
{
    [super buildView];

    _firstLoad = YES;
    
    _slider = [[UISlider alloc] initWithFrame:CGRectZero];
    
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(sliderDragStarted:) forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_slider addTarget:self action:@selector(sliderDragEnded:) forControlEvents:UIControlEventTouchCancel];
    
    [[self contentView] addSubview:_slider];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize returnSize = [[self slider] sizeThatFits:size];
    return returnSize;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self slider] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];
    
    UIColor* tint = [[self attributeContainer] getColorValueForAttribute:kIXTint defaultValue:nil];
    if( tint != nil )
    {
        [[self slider] setTintColor:tint];
    }

    UIImage* maxImage = [UIImage imageNamed:[[self attributeContainer] getStringValueForAttribute:kIXImagesMaximum defaultValue:nil]];
    if( maxImage )
    {
        NSString* maxInsetsString = [[self attributeContainer] getStringValueForAttribute:kIXImagesMaximumCapInsets defaultValue:nil];
        if( maxInsetsString )
        {
            UIEdgeInsets maxEdgeInsets = UIEdgeInsetsFromString(maxInsetsString);
            maxImage = [maxImage resizableImageWithCapInsets:maxEdgeInsets];
        }

        UIColor* maxImageTint = [[self attributeContainer] getColorValueForAttribute:kIXImagesMaximumTint defaultValue:nil];
        if( maxImageTint != nil )
        {
            maxImage = [maxImage applyTintEffectWithColor:maxImageTint];
        }

        [[self slider] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    }
    
    UIImage* minImage = [UIImage imageNamed:[[self attributeContainer] getStringValueForAttribute:kIXImagesMinimum defaultValue:nil]];
    if( minImage )
    {
        NSString* minInsetsString = [[self attributeContainer] getStringValueForAttribute:kIXImagesMinimumCapInsets defaultValue:nil];
        if( minInsetsString )
        {
            UIEdgeInsets minEdgeInsets = UIEdgeInsetsFromString(minInsetsString);
            minImage = [minImage resizableImageWithCapInsets:minEdgeInsets];
        }
        
        UIColor* minImageTint = [[self attributeContainer] getColorValueForAttribute:kIXImagesMinimumTint defaultValue:nil];
        if( minImageTint != nil )
        {
            minImage = [minImage applyTintEffectWithColor:minImageTint];
        }

        [[self slider] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    }
    
    UIImage* thumbImage = [UIImage imageNamed:[[self attributeContainer] getStringValueForAttribute:kIXImagesThumb defaultValue:nil]];
    if( thumbImage )
    {
        UIColor* thumbImageTint = [[self attributeContainer] getColorValueForAttribute:kIXImagesThumbTint defaultValue:nil];
        if( thumbImageTint != nil )
        {
            thumbImage = [thumbImage applyTintEffectWithColor:thumbImageTint];
        }

        [[self slider] setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    
    [[self slider] setMinimumValue:[[self attributeContainer] getFloatValueForAttribute:kIXMinimumValue defaultValue:0.0f]];
    [[self slider] setMaximumValue:[[self attributeContainer] getFloatValueForAttribute:kIXMaximumValue defaultValue:1.0f]];

    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        if( [self encodedValue] != nil )
        {
            [self updateSliderValueWithValue:[[self encodedValue] floatValue] animated:YES];
        }
        else
        {
            CGFloat initialSlideValue = [[self attributeContainer] getFloatValueForAttribute:kIXInitialValue defaultValue:0.0f];
            [self updateSliderValueWithValue:initialSlideValue animated:YES];
        }
    }
}

-(void)sliderValueChanged:(UISlider*)slider
{
    [[self actionContainer] executeActionsForEventNamed:kIXValueChanged];
}

-(void)sliderDragStarted:(UISlider*)slider
{
    [[self actionContainer] executeActionsForEventNamed:kIXTouch];
}

-(void)sliderDragEnded:(UISlider*)slider
{
    [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
}

-(void)updateSliderValueWithValue:(CGFloat)sliderValue animated:(BOOL)animated
{
    [[self slider] setValue:sliderValue animated:animated];
    [self sliderValueChanged:[self slider]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXUpdateSliderValue] )
    {
        CGFloat sliderValue = [parameterContainer getFloatValueForAttribute:kIXValue defaultValue:[[self slider] value]];
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
        }
        [self updateSliderValueWithValue:sliderValue animated:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXValue] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self slider] value]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
