//
//  IXKnob.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     	1/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** A knob that allows the user to turn things up or down.
*/


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
static NSString* const kIXUpdateKnobValue = @"update_knob_value"; // Params : "animated"

// NSCoding Key Constants
static NSString* const kIXValueNSCodingKey = @"value";

@interface IXKnob ()

@property (nonatomic,strong) MHRotaryKnob* knobControl;
@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) NSNumber* encodedValue;

@end

@implementation IXKnob

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes:

    @param initial_value Initial value to display<br>*(float)*
    @param minimum_value Minimum value allowed<br>*(float)*
    @param maximum_value Minimum value allowed<br>*(float)*
    @param images.foreground Image to overlay<br>*(string)*
    @param images.background Image to underlay<br>*(string)*
    @param images.pointer Image pointer<br>*(string)*
    @param maximum_angle Maximum Angle<br>*(float)*
    @param knob_animation_duration Animation duration<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param value The value the knob it set to<br>*(float)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param value_changed Fires when knob value is changed
    @param touch Fires on touch
    @param touch_up Fires on touch up inside
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param update_knob_value Sets the knob to a new value

 <pre class="brush: js; toolbar: false;">

{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "customKnob",
    "function_name": "update_knob_value"
  },
  "set": {
    "value": 0,
    "animated": true
  }
}
 
 </pre>

*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">

{
  "_id": "customKnob",
  "_type": "Knob",
  "actions": [
    {
      "_type": "Refresh",
      "attributes": {
        "_target": "knobValue"
      },
      "enabled": true,
      "on": "value_changed"
    }
  ],
  "attributes": {
    "color": {
      "background": "#00000000"
    },
    "width": 250,
    "height": 250,
    "horizontal_alignment": "center",
    "layout_type": "relative",
    "initial_value": 0,
    "minimum_value": 0,
    "maximum_value": 100,
    "knob_animation_duration": 0.5,
    "images": {
      "pointer": "images/marker.png",
      "background": "images/bg.png"
    }
  }
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

/*
* /Docs
*
*/

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
    
    CGFloat maximumAngle = [[self propertyContainer] getFloatPropertyValue:kIXMaximumAngle defaultValue:145.0f];
    [[self knobControl] setMaximumAngle:maximumAngle];
    
    CGFloat animationDuration = [[self propertyContainer] getFloatPropertyValue:kIXKnobAnimationDuration defaultValue:0.2f];
    [[self knobControl] setAnimationDuration:animationDuration];
    
    [[self knobControl] setMinimumValue:[[self propertyContainer] getFloatPropertyValue:kIXMinimumValue defaultValue:0.0f]];
    [[self knobControl] setMaximumValue:[[self propertyContainer] getFloatPropertyValue:kIXMaximumValue defaultValue:1.0f]];
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImagesPointer
                                  successBlock:^(UIImage *image) {
                                      if(image)
                                      {
                                          [[weakSelf knobControl] setKnobImage:image forState:UIControlStateNormal];
                                      }
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesBackground
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
            CGFloat initialSlideValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0.0f];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXUpdateKnobValue] )
    {
        CGFloat knobValue = [parameterContainer getFloatPropertyValue:kIXValue defaultValue:[[self knobControl] value]];
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
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
