//
//  IXKnob.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXKnob.h"

#import "MHRotaryKnob.h"

// Knob Properties
static NSString* const kIXInitialValue = @"initial_value";
static NSString* const kIXMinimumValue = @"minimum_value";
static NSString* const kIXMaximumValue = @"maximum_value";
static NSString* const kIXImagesForeground = @"images.foreground";
static NSString* const kIXImagesBackground = @"images.background";
static NSString* const kIXImagesPointer = @"images.pointer";
static NSString* const kIXMaximumAngle = @"maximum_angle";
static NSString* const kIXKnobAnimationDuration = @"knob_animation_duration";

// Knob Read-Only Properties
static NSString* const kIXValue = @"value";

// Knob Events
static NSString* const kIXValueChanged = @"value_changed";
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";

// Knob Functions
static NSString* const kIXUpdateKnobValue = @"update_knob_value";
static NSString* const kIXAnimated = @"animated"; // Parameter of the "update_knob_value" function.

@interface IXKnob ()

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) MHRotaryKnob* knobControl;

@end

@implementation IXKnob

-(void)dealloc
{
    [_knobControl removeTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_knobControl removeTarget:self action:@selector(knobDragStarted:) forControlEvents:UIControlEventTouchDown];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [_knobControl removeTarget:self action:@selector(knobDragEnded:) forControlEvents:UIControlEventTouchCancel];
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
    
    CGFloat maximumAngle = [[self propertyContainer] getFloatPropertyValue:kIXMaximumAngle defaultValue:145.0f];
    [[self knobControl] setMaximumAngle:maximumAngle];
    
    CGFloat animationDuration = [[self propertyContainer] getFloatPropertyValue:kIXKnobAnimationDuration defaultValue:0.2f];
    [[self knobControl] setAnimationDuration:animationDuration];
    
    [[self knobControl] setMinimumValue:[[self propertyContainer] getFloatPropertyValue:kIXMinimumValue defaultValue:0.0f]];
    [[self knobControl] setMaximumValue:[[self propertyContainer] getFloatPropertyValue:kIXMaximumValue defaultValue:1.0f]];
    
    [[self propertyContainer] getImageProperty:kIXImagesPointer
                                  successBlock:^(UIImage *image) {
                                      if(image)
                                      {
                                          [[self knobControl] setKnobImage:image forState:UIControlStateNormal];
                                      }
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesBackground
                                  successBlock:^(UIImage *image) {
                                      if(image)
                                      {
                                          [[self knobControl] setBackgroundImage:image];
                                      }
                                  } failBlock:^(NSError *error) {
                                  }];
    
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        CGFloat initialValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0];
        [self updateKnobValueWithValue:initialValue animated:NO];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXUpdateKnobValue] )
    {
        CGFloat knobValue = [parameterContainer getFloatPropertyValue:kIXValue defaultValue:[[self knobControl] value]];
        BOOL animated = [parameterContainer getBoolPropertyValue:kIXAnimated defaultValue:YES];
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
