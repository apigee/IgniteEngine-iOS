//
//  IXKnob.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXKnob.h"

#import "RWKnobControl.h"
#import "RWKnobRenderer.h"

// Knob Properties
static NSString* const kIXInitialValue = @"initial_value";
static NSString* const kIXLineWidth = @"line_width";
static NSString* const kIXPointerLength = @"pointer_length";
static NSString* const kIXMinimumValue = @"minimum_value";
static NSString* const kIXMaximumValue = @"maximum_value";
static NSString* const kIXTrackColor = @"track_color";
static NSString* const kIXPointerColor = @"pointer_color";
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
@property (nonatomic,strong) RWKnobControl* knobControl;

@end

@implementation IXKnob

-(void)buildView
{
    [super buildView];
    
    _firstLoad = YES;

    _knobControl = [[RWKnobControl alloc] initWithFrame:CGRectZero];
    
    [_knobControl addTarget:self action:@selector(knobValueChanged:) forControlEvents:UIControlEventValueChanged];

    [[self contentView] addSubview:_knobControl];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self knobControl] setFrame:rect];
    [[[self knobControl] knobRenderer] updateWithBounds:rect];
}

-(void)applySettings
{
    [super applySettings];
    
    [[self knobControl] setLineWidth:[[self propertyContainer] getFloatPropertyValue:kIXLineWidth defaultValue:2.0f]];
    [[self knobControl] setPointerLength:[[self propertyContainer] getFloatPropertyValue:kIXPointerLength defaultValue:10.0f]];
    [[self knobControl] setMinimumValue:[[self propertyContainer] getFloatPropertyValue:kIXMinimumValue defaultValue:0.0f]];
    [[self knobControl] setMaximumValue:[[self propertyContainer] getFloatPropertyValue:kIXMaximumValue defaultValue:1.0f]];
    
    CGFloat startAngle = [[self propertyContainer] getFloatPropertyValue:kIXStartAngle defaultValue:-M_PI * 11 / 8.0];
    CGFloat endAngle = [[self propertyContainer] getFloatPropertyValue:kIXEndAngle defaultValue:M_PI * 3 / 8.0];
    [[self knobControl] setStartAngle:startAngle];
    [[self knobControl] setEndAngle:endAngle];
    
    UIColor* trackColor = [[self propertyContainer] getColorPropertyValue:kIXTrackColor defaultValue:[UIColor blueColor]];
    UIColor* pointerColor = [[self propertyContainer] getColorPropertyValue:kIXPointerColor defaultValue:[UIColor redColor]];
    [[[[self knobControl] knobRenderer] trackLayer] setStrokeColor:[trackColor CGColor]];
    [[[[self knobControl] knobRenderer] pointerLayer] setStrokeColor:[pointerColor CGColor]];
    
    BOOL trackVisible = [[self propertyContainer] getBoolPropertyValue:kIXTrackVisible defaultValue:NO];
    BOOL pointerVisible = [[self propertyContainer] getBoolPropertyValue:kIXPointerVisible defaultValue:YES];
    [[[[self knobControl] knobRenderer] trackLayer] setHidden:!trackVisible];
    [[[[self knobControl] knobRenderer] pointerLayer] setHidden:!pointerVisible];
    
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        CGFloat initialValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0];
        [self updateKnobValueWithValue:initialValue animated:YES];
    }
}

-(void)knobValueChanged:(RWKnobControl*)knobControl
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
