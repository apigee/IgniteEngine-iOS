//
//  IXButton.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXButton.h"

#import "UIImage+IXAdditions.h"
#import "UIButton+IXAdditions.h"

// IXButton states
static NSString* const kIXNormal = @"normal";
static NSString* const kIXTouch = @"touch";
static NSString* const kIXDisabled = @"disabled";

// IXButton properties
static NSString* const kIXTextDefault = @"text";
static NSString* const kIXTextDefaultFont = @"font";
static NSString* const kIXTextDefaultColor = @"text.color";
static NSString* const kIXBackgroundColor = @"background.color";
static NSString* const kIXIconDefault = @"icon";
static NSString* const kIXIconDefaultTintColor = @"icon.tintColor";

static NSString* const kIXTouchText = @"touch.text";
static NSString* const kIXTouchFont = @"touch.font";
static NSString* const kIXTouchTextColor = @"touch.text.color";
static NSString* const kIXTouchBackgroundColor = @"touch.background.color";
static NSString* const kIXTouchIcon = @"touch.icon";
static NSString* const kIXTouchIconTintColor = @"touch.icon.tintColor";

static NSString* const kIXDisabledText = @"disabled.text";
static NSString* const kIXDisabledFont = @"disabled.font";
static NSString* const kIXDisabledTextColor = @"disabled.text.color";
static NSString* const kIXDisabledBackgroundColor = @"disabled.background.color";
static NSString* const kIXDisabledIcon = @"disabled.icon";
static NSString* const kIXDisabledIconTintColor = @"disabled.icon.tintColor";

static NSString* const kIXDarkensImageOnTouch = @"darkens_image_on_touch";
static NSString* const kIXTouchDuration = @"touch.duration";
static NSString* const kIXTouchUpDuration = @"touch_up.duration";

@interface IXButton ()

@property (nonatomic,strong) UIButton* button;

@end

@implementation IXButton

-(void)dealloc
{
    [_button removeTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button removeTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button removeTarget:self action:@selector(buttonTouchCancelled:) forControlEvents:UIControlEventTouchCancel];
}

-(void)buildView
{
    [super buildView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_button addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(buttonTouchCancelled:) forControlEvents:UIControlEventTouchUpOutside];
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
    
    [[self button] setEnabled:[[self contentView] isEnabled]];
    
    self.button.shouldHighlightImageOnTouch = [self.propertyContainer getBoolPropertyValue:kIXDarkensImageOnTouch defaultValue:YES];
    [[self button] setAdjustsImageWhenHighlighted:NO];
    
    [[self button] setAttributedTitle:nil forState:UIControlStateNormal];
    [[self button] setAttributedTitle:nil forState:UIControlStateHighlighted];
    [[self button] setAttributedTitle:nil forState:UIControlStateDisabled];

    NSString* defaultTextForTitles = nil;
    UIColor* defaultColorForTitles = [UIColor lightGrayColor];
    UIFont* defaultFontForTitles = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];

    UIColor* defaultTintColorForImages = nil;
    
    NSArray* differentTitleStates = @[kIXNormal,kIXTouch,kIXDisabled];
    for( NSString* titleState in differentTitleStates )
    {
        UIControlState controlState = UIControlStateNormal;
        NSString* titleTextPropertyName = kIXTextDefault;
        NSString* titleColorPropertyName = kIXTextDefaultColor;
        NSString* titleFontPropertyName = kIXTextDefaultFont;
        NSString* imagePropertyName = kIXIconDefault;
        NSString* imageTintColorPropertyName = kIXIconDefaultTintColor;
        
        if( [titleState isEqualToString:kIXTouch])
        {
            controlState = UIControlStateHighlighted;
            titleTextPropertyName = kIXTouchText;
            titleColorPropertyName = kIXTouchTextColor;
            titleFontPropertyName = kIXTouchFont;
            imagePropertyName = kIXTouchIcon;
            imageTintColorPropertyName = kIXTouchIconTintColor;
        }
        else if( [titleState isEqualToString:kIXDisabled])
        {
            controlState = UIControlStateDisabled;
            titleTextPropertyName = kIXDisabledText;
            titleColorPropertyName = kIXDisabledTextColor;
            titleFontPropertyName = kIXDisabledFont;
            imagePropertyName = kIXDisabledIcon;
            imageTintColorPropertyName = kIXDisabledIconTintColor;
        }
        
        NSString* titleText = [[self propertyContainer] getStringPropertyValue:titleTextPropertyName defaultValue:defaultTextForTitles];
        if( [titleText length] )
        {
            UIColor* titleTextColor = [[self propertyContainer] getColorPropertyValue:titleColorPropertyName defaultValue:defaultColorForTitles];
            UIFont* titleTextFont = [[self propertyContainer] getFontPropertyValue:titleFontPropertyName defaultValue:defaultFontForTitles];
            
            NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:titleText
                                                                                  attributes:@{NSForegroundColorAttributeName: titleTextColor,
                                                                                               NSFontAttributeName:titleTextFont}];
            if( controlState == UIControlStateNormal )
            {
                defaultTextForTitles = titleText;
                defaultColorForTitles = titleTextColor;
                defaultFontForTitles = titleTextFont;
            }
            
            [[self button] setAttributedTitle:attributedTitle forState:controlState];
        }
        
        UIColor* imageTintColor = [[self propertyContainer] getColorPropertyValue:imageTintColorPropertyName defaultValue:defaultTintColorForImages];
        
        if( controlState == UIControlStateNormal )
        {
            defaultTintColorForImages = imageTintColor;
        }
                
        __weak typeof(self) weakSelf = self;
        [[self propertyContainer] getImageProperty:imagePropertyName
                                      successBlock:^(UIImage *image) {
                                          if( imageTintColor )
                                          {
                                              image = [image tintedImageUsingColor:imageTintColor];
                                          }
                                          [[weakSelf button] setImage:image forState:controlState];
                                      } failBlock:nil];
    }
}

-(void)buttonTouchedDown:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.propertyContainer getFloatPropertyValue:kIXTouchDuration defaultValue:0.04];
        UIColor* imageTintColor = [[self propertyContainer] getColorPropertyValue:kIXTouchIconTintColor defaultValue:nil];
        UIColor* buttonBackgroundColor = [[self propertyContainer] getColorPropertyValue:kIXTouchBackgroundColor defaultValue:nil];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             if (imageTintColor)
                             {
                                 [self.button setImage:[self.button.currentImage tintedImageUsingColor:imageTintColor] forState:UIControlStateHighlighted];
                             }
                             if (buttonBackgroundColor)
                             {
                                 self.contentView.backgroundColor = buttonBackgroundColor;
                             }
                         }
                         completion:^(BOOL finished){
                             [self processBeginTouch:YES];
                         }];
    }
    else
        [self processBeginTouch:YES];
}

-(void)buttonTouchUpInside:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.propertyContainer getFloatPropertyValue:kIXTouchDuration defaultValue:0.15];
        UIColor* imageTintColor = [[self propertyContainer] getColorPropertyValue:kIXIconDefaultTintColor defaultValue:nil];
        UIColor* buttonBackgroundColor = [[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:nil];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            if (imageTintColor)
                            {
                                [self.button setImage:[self.button.currentImage tintedImageUsingColor:imageTintColor] forState:UIControlStateNormal];
                            }
                            if (buttonBackgroundColor)
                            {
                                self.contentView.backgroundColor = buttonBackgroundColor;
                            }
                        }
                        completion:^(BOOL finished){
                            [self processEndTouch:YES];
                        }];
    }
    else
        [self processEndTouch:YES];
}

-(void)buttonTouchCancelled:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.propertyContainer getFloatPropertyValue:kIXTouchDuration defaultValue:0.15];
        UIColor* imageTintColor = [[self propertyContainer] getColorPropertyValue:kIXIconDefaultTintColor defaultValue:nil];
        UIColor* buttonBackgroundColor = [[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:nil];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            if (imageTintColor)
                            {
                                [self.button setImage:[self.button.currentImage tintedImageUsingColor:imageTintColor] forState:UIControlStateNormal];
                            }
                            if (buttonBackgroundColor)
                            {
                                self.contentView.backgroundColor = buttonBackgroundColor;
                            }
                        }
                        completion:^(BOOL finished){
                            [self processCancelTouch:YES];
                        }];
    }
    else
        [self processCancelTouch:YES];}

@end
