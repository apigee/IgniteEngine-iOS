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
static NSString* const kIXLineWidth = @"line_width";
static NSString* const kIXPointerLength = @"pointer_length";
static NSString* const kIXMinimumValue = @"minimum_value";
static NSString* const kIXMaximumValue = @"maximum_value";
static NSString* const kIXTrackColor = @"track_color";
static NSString* const kIXPointerColor = @"pointer_color";
static NSString* const kIXImagesForeground = @"images.foreground";
static NSString* const kIXImagesBackground = @"images.background";
static NSString* const kIXImagesPointer = @"images.pointer";
static NSString* const kIXTrackVisible = @"track_visible";
static NSString* const kIXPointerVisible = @"pointer_visible";
static NSString* const kIXStartAngle = @"start_angle";
static NSString* const kIXEndAngle = @"end_angle";

// Knob Read-Only Properties
static NSString* const kIXValue = @"value";

// Knob Events
static NSString* const IXValueChanged = @"value_changed";

// Knob Functions
static NSString* const kIXUpdateKnobValue = @"update_knob_value";
static NSString* const kIXAnimated = @"animated"; // Parameter of the "update_knob_value" function.

@interface IXKnob ()

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) MHRotaryKnob* knobControl;

@end

@implementation IXKnob

-(void)buildView
{
    [super buildView];
    
    _firstLoad = YES;
    
    _knobControl = [[MHRotaryKnob alloc] initWithFrame:CGRectZero];
    [_knobControl addTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];

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
        
        _knobControl.knobImageCenter = center;
        [self updateKnobValueWithValue:[[self knobControl] value] animated:NO];
    }
}

-(void)applySettings
{
    [super applySettings];
    
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
    [[self actionContainer] executeActionsForEventNamed:IXValueChanged];
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
