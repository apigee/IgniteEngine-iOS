//
//  IXSlider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/10/14.
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

/** A slider that moves side-to-side.
*/

#import "IXSlider.h"

#import "NSString+IXAdditions.h"

// Slider Properties
static NSString* const kIXInitialValue = @"initial_value";
static NSString* const kIXImagesThumb = @"images.thumb";
static NSString* const kIXImagesMinimum = @"images.minimum";
static NSString* const kIXImagesMaximum = @"images.maximum";
static NSString* const kIXMinimumValue = @"minimum_value";
static NSString* const kIXMaximumValue = @"maximum_value";
static NSString* const kIXImagesMaximumCapInsets = @"images.maximum.capInsets";
static NSString* const kIXImagesMinimumCapInsets = @"images.minimum.capInsets";

// Slider Read-Only Properties
static NSString* const kIXValue = @"value";

// Slider Events
static NSString* const kIXValueChanged = @"value_changed";
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";

// Slider Functions
static NSString* const kIXUpdateSliderValue = @"update_slider_value"; // Params : "animated"

// NSCoding Key Constants
static NSString* const kIXValueNSCodingKey = @"value";

@interface IXSlider ()

@property (nonatomic,strong) UISlider* slider;
@property (nonatomic,assign,getter=isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) NSNumber* encodedValue;

@end

@implementation IXSlider

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes:

    @param initial_value Initial value of the slider<br>*(float)*
    @param images.thumb /path/to/image.png<br>*(string)*
    @param images.minimum /path/to/image.png<br>*(string)*
    @param images.maximum /path/to/image.png<br>*(string)*
    @param minimum_value Minimum value boundary<br>*(float)*
    @param maximum_value Maximum value boundary<br>*(float)*
    @param images.maximum.capInsets /path/to/image.png<br>*(string)*
    @param images.minimum.capInsets /path/to/image.png<br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param value Current value of the slider<br>*(float)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param value_changed Fires when the value of the slider changes

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param update_slider_value 
 
<pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "sliderTest",
    "function_name": "update_slider_value"
  },
  "set": {
    "value": 0.75
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
  "_id": "sliderTest",
  "_type": "Slider",
  "actions": [
    {
      "on": "value_changed",
      "_type": "Refresh",
      "attributes": {
        "_target": "title"
      }
    }
  ],
  "attributes": {
    "layout_type": "absolute",
    "width": 280,
    "horizontal_alignment": "center",
    "vertical_alignment": "middle"
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
    
    UIImage* maxImage = [UIImage imageNamed:[[self propertyContainer] getStringPropertyValue:kIXImagesMaximum defaultValue:nil]];
    if( maxImage )
    {
        NSString* maxInsetsString = [[self propertyContainer] getStringPropertyValue:kIXImagesMaximumCapInsets defaultValue:nil];
        if( maxInsetsString )
        {
            UIEdgeInsets maxEdgeInsets = UIEdgeInsetsFromString(maxInsetsString);
            maxImage = [maxImage resizableImageWithCapInsets:maxEdgeInsets];
        }
        [[self slider] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    }
    
    UIImage* minImage = [UIImage imageNamed:[[self propertyContainer] getStringPropertyValue:kIXImagesMinimum defaultValue:nil]];
    if( minImage )
    {
        NSString* minInsetsString = [[self propertyContainer] getStringPropertyValue:kIXImagesMinimumCapInsets defaultValue:nil];
        if( minInsetsString )
        {
            UIEdgeInsets minEdgeInsets = UIEdgeInsetsFromString(minInsetsString);
            minImage = [minImage resizableImageWithCapInsets:minEdgeInsets];
        }
        [[self slider] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    }
    
    UIImage* thumbImage = [UIImage imageNamed:[[self propertyContainer] getStringPropertyValue:kIXImagesThumb defaultValue:nil]];
    if( thumbImage )
    {
        [[self slider] setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    
    [[self slider] setMinimumValue:[[self propertyContainer] getFloatPropertyValue:kIXMinimumValue defaultValue:0.0f]];
    [[self slider] setMaximumValue:[[self propertyContainer] getFloatPropertyValue:kIXMaximumValue defaultValue:1.0f]];

    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        if( [self encodedValue] != nil )
        {
            [self updateSliderValueWithValue:[[self encodedValue] floatValue] animated:YES];
        }
        else
        {
            CGFloat initialSlideValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0.0f];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXUpdateSliderValue] )
    {
        CGFloat sliderValue = [parameterContainer getFloatPropertyValue:kIXValue defaultValue:[[self slider] value]];
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
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
