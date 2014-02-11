//
//  IXSlider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/10/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXSlider.h"

// Slider Properties
static NSString* const kIXInitialValue = @"initial_value";
static NSString* const kIXImagesThumb = @"images.thumb";
static NSString* const kIXImagesMinimum = @"images.minimum";
static NSString* const kIXImagesMaximum = @"images.maximum";

// Slider Read-Only Properties
static NSString* const kIXValue = @"value";

// Slider Events
static NSString* const IXValueChanged = @"value_changed";

// Slider Functions
static NSString* const kIXUpdateSliderValue = @"update_slider_value";
static NSString* const kIXAnimated = @"animated"; // Parameter of the "update_slider_value" function.

@interface IXSlider ()

@property (nonatomic,strong) UISlider* slider;
@property (nonatomic,assign,getter=isFirstLoad) BOOL firstLoad;

@end

@implementation IXSlider

-(void)buildView
{
    [super buildView];

    _firstLoad = YES;
    
    _slider = [[UISlider alloc] initWithFrame:CGRectZero];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
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
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImagesMaximum
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf slider] setMaximumTrackImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesMinimum
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf slider] setMinimumTrackImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesThumb
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf slider] setThumbImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];
    
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        CGFloat initialSlideValue = [[self propertyContainer] getFloatPropertyValue:kIXInitialValue defaultValue:0.0f];
        [self updateSliderValueWithValue:initialSlideValue animated:YES];
    }
}

-(void)sliderValueChanged:(UISlider*)slider
{
    [[self actionContainer] executeActionsForEventNamed:IXValueChanged];
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
        returnValue = [NSString stringWithFormat:@"%f",[[self slider] value]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
