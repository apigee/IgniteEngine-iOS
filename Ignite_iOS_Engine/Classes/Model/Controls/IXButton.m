//
//  IXButton.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXButton.h"

// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXImagesDisabled = @"images.disabled";

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
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImagesDefault
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf button] setBackgroundImage:image forState:UIControlStateNormal];
                                  } failBlock:^(NSError *error) {
                                  }];    
    [[self propertyContainer] getImageProperty:kIXImagesTouch
                                  successBlock:^(UIImage *image) {
                                      [[weakSelf button] setBackgroundImage:image forState:UIControlStateHighlighted];
                                  } failBlock:^(NSError *error) {
                                  }];
    [[self propertyContainer] getImageProperty:kIXImagesDisabled
                                  successBlock:^(UIImage *image) {
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
