//
//  IXDial.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/11/14.
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

#import "IXDial.h"

#import "MHRotaryKnob.h"

// Knob Properties
static NSString* const kIXInitialValue = @"value.default";
static NSString* const kIXMinimumValue = @"value.min";
static NSString* const kIXMaximumValue = @"value.max";
static NSString* const kIXImagesForeground = @"fg.image";
static NSString* const kIXImagesBackground = @"bg.image";
static NSString* const kIXImagesPointer = @"pointer.image";
static NSString* const kIXMaximumAngle = @"maxAngle";
static NSString* const kIXDialAnimationDuration = @"animation.duration";

// Knob Read-Only Properties
static NSString* const kIXValue = @"value";

// Knob Events
static NSString* const kIXValueChanged = @"valueChanged";
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touchUp";

// Knob Functions
static NSString* const kIXUpdateKnobValue = @"setValue"; // Params : "animated"

// NSCoding Key Constants
static NSString* const kIXValueNSCodingKey = @"value";

@interface IXDial ()

@property (nonatomic,strong) MHRotaryKnob* knobControl;
@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) NSNumber* encodedValue;

@end

@implementation IXDial

-(void)dealloc
{
    [_knobControl removeTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_knobControl removeTarget:self action:@selector(knobDragStarted:) forControlEvents:UIControlEventTouchDown];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchCancel];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithFloat:[[self knobControl] value]] forKey:kIXValueNSCodingKey];
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
    
    _knobControl = [[MHRotaryKnob alloc] initWithFrame:CGRectZero];
    
    [_knobControl addTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_knobControl addTarget:self action:@selector(knobDragStarted:) forControlEvents:UIControlEventTouchDown];
    [_knobControl addTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_knobControl addTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_knobControl addTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchCancel];

    [[self contentView] addSubview:_knobControl];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
    if(!CGRectEqualToRect([[self knobControl] frame], rect) || !CGPointEqualToPoint([[self knobControl] center], center) )
    {
        [[self knobControl] setFrame:rect];
        [[self knobControl] setKnobImageCenter:center];
        [self updateKnobValueWithValue:[[self knobControl] value] animated:NO];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    CGFloat maximumAngle = [[self attributeContainer] getFloatValueForAttribute:kIXMaximumAngle defaultValue:145.0f];
    [[self knobControl] setMaximumAngle:maximumAngle];
    
    CGFloat animationDuration = [[self attributeContainer] getFloatValueForAttribute:kIXDialAnimationDuration defaultValue:0.2f];
    [[self knobControl] setAnimationDuration:animationDuration];
    
    [[self knobControl] setMinimumValue:[[self attributeContainer] getFloatValueForAttribute:kIXMinimumValue defaultValue:0.0f]];
    [[self knobControl] setMaximumValue:[[self attributeContainer] getFloatValueForAttribute:kIXMaximumValue defaultValue:1.0f]];
    
    __weak typeof(self) weakSelf = self;
    [[self attributeContainer] getImageAttribute:kIXImagesPointer
                                  successBlock:^(UIImage *image) {
                                      if(image)
                                      {
                                          [[weakSelf knobControl] setKnobImage:image forState:UIControlStateNormal];
                                      }
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self attributeContainer] getImageAttribute:kIXImagesBackground
                                  successBlock:^(UIImage *image) {
                                      if(image)
                                      {
                                          [[weakSelf knobControl] setBackgroundImage:image];
                                      }
                                  } failBlock:^(NSError *error) {
                                  }];
    
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        if( [self encodedValue] != nil )
        {
            [self updateKnobValueWithValue:[[self encodedValue] floatValue] animated:YES];
        }
        else
        {
            CGFloat initialSlideValue = [[self attributeContainer] getFloatValueForAttribute:kIXInitialValue defaultValue:0.0f];
            [self updateKnobValueWithValue:initialSlideValue animated:YES];
        }
    }
}

-(void)knobValueChanged:(MHRotaryKnob*)knobControl
{
    [[self actionContainer] executeActionsForEventNamed:kIXValueChanged];
}

-(void)knobDragStarted:(MHRotaryKnob*)knobControl
{
    [[self actionContainer] executeActionsForEventNamed:kIXTouch];
}

-(void)knobDragEnded:(MHRotaryKnob*)knobControl
{
    [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
}

-(void)updateKnobValueWithValue:(CGFloat)knobValue animated:(BOOL)animated
{
    [[self knobControl] setValue:knobValue animated:animated];
    [self knobValueChanged:[self knobControl]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXUpdateKnobValue] )
    {
        CGFloat knobValue = [parameterContainer getFloatValueForAttribute:kIXValue defaultValue:[[self knobControl] value]];
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolValueForAttribute:kIX_ANIMATED defaultValue:animated];
        }
        [self updateKnobValueWithValue:knobValue animated:animated];
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
        returnValue = [NSString stringWithFormat:@"%li",lroundf([[self knobControl] value])];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
