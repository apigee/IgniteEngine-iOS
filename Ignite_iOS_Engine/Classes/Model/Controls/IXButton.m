//
//  IXButton.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXButton.h"

#import "UIImage+IXAdditions.h"

// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXImagesDisabled = @"images.disabled";
static NSString* const kIXImagesTouchTintColor = @"images.touch.tintColor";
static NSString* const kIXImagesDefaultTintColor = @"images.default.tintColor";
static NSString* const kIXImagesDisabledTintColor = @"images.disabled.tintColor";
static NSString* const kIXDarkensImageOnTouch = @"darkens_image_on_touch";

@interface IXButton ()

@property (nonatomic,strong) UIButton* button;

@end

@implementation IXButton

-(void)dealloc
{
    [_button removeTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button removeTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button removeTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_button removeTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel];
}

-(void)buildView
{
    [super buildView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_button addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel];

    [[self contentView] addSubview:_button];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [[self button] sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self button] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];
    
    BOOL darkensImageOnTouch = [[self propertyContainer] getBoolPropertyValue:kIXDarkensImageOnTouch defaultValue:NO];
    [[self button] setAdjustsImageWhenHighlighted:darkensImageOnTouch];
    
    UIColor* imageDefaultTintColor = [[self propertyContainer] getColorPropertyValue:kIXImagesDefaultTintColor defaultValue:nil];
    UIColor* imageTouchTintColor = [[self propertyContainer] getColorPropertyValue:kIXImagesTouchTintColor defaultValue:nil];
    UIColor* imageDisabledTintColor = [[self propertyContainer] getColorPropertyValue:kIXImagesDisabledTintColor defaultValue:nil];

    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImagesDefault
                                  successBlock:^(UIImage *image) {
                                      if( imageDefaultTintColor )
                                      {
                                          image = [image tintedImageUsingColor:imageDefaultTintColor];
                                      }
                                      [[weakSelf button] setBackgroundImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];    
    [[self propertyContainer] getImageProperty:kIXImagesTouch
                                  successBlock:^(UIImage *image) {
                                      if( imageTouchTintColor )
                                      {
                                          image = [image tintedImageUsingColor:imageTouchTintColor];
                                      }
                                      [[weakSelf button] setBackgroundImage:image forState:UIControlStateHighlighted];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesDisabled
                                  successBlock:^(UIImage *image) {
                                      if( imageDisabledTintColor )
                                      {
                                          image = [image tintedImageUsingColor:imageDisabledTintColor];
                                      }
                                      [[weakSelf button] setBackgroundImage:image forState:UIControlStateDisabled];
                                  } failBlock:^(NSError *error) {
                                  }];
}

-(void)buttonTouchedDown:(id)sender
{
    [self processBeginTouch:YES];
}

-(void)buttonTouchUpInside:(id)sender
{
    [self processEndTouch:YES];
}

-(void)buttonTouchUpOutside:(id)sender
{
    [self processCancelTouch:YES];
}

@end
