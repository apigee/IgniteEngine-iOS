//
//  IXSlider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/10/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

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
static NSString* const kIXUpdateSliderValue = @"update_slider_value";
static NSString* const kIXAnimated = @"animated"; // Parameter of the "update_slider_value" function.

@interface IXSlider ()

@property (nonatomic,strong) UISlider* slider;
@property (nonatomic,assign,getter=isFirstLoad) BOOL firstLoad;

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
    
    NSString* maxInsetsString = [[self propertyContainer] getStringPropertyValue:kIXImagesMaximumCapInsets defaultValue:nil];
    NSString* minInsetsString = [[self propertyContainer] getStringPropertyValue:kIXImagesMinimumCapInsets defaultValue:nil];
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImagesMaximum
                                  successBlock:^(UIImage *image) {
                                      if( maxInsetsString )
                                      {
                                          UIEdgeInsets maxEdgeInsets = UIEdgeInsetsFromString(maxInsetsString);
                                          image = [image resizableImageWithCapInsets:maxEdgeInsets];
                                      }
                                      [[weakSelf slider] setMaximumTrackImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesMinimum
                                  successBlock:^(UIImage *image) {
                                      if( minInsetsString )
                                      {
                                          UIEdgeInsets minEdgeInsets = UIEdgeInsetsFromString(minInsetsString);
                                          image = [image resizableImageWithCapInsets:minEdgeInsets];
                                      }
                                      [[weakSelf slider] setMinimumTrackImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesThumb
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf slider] setThumbImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    
    [[self slider] setMinimumValue:[[self propertyContainer] getFloatPropertyValue:kIXMinimumValue defaultValue:0.0f]];
    [[self slider] setMaximumValue:[[self propertyContainer] getFloatPropertyValue:kIXMaximumValue defaultValue:1.0f]];

    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        CGFloat initialSlideValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0.0f];
        [self updateSliderValueWithValue:initialSlideValue animated:YES];
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
        BOOL animated = [parameterContainer getBoolPropertyValue:kIXAnimated defaultValue:YES];
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
