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
static NSString* const kIXTouch = @"touch";
static NSString* const kIXDisabled = @"disabled";
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXImagesDisabled = @"images.disabled";
static NSString* const kIXImagesTouchTintColor = @"images.touch.tintColor";
static NSString* const kIXImagesDefaultTintColor = @"images.default.tintColor";
static NSString* const kIXImagesDisabledTintColor = @"images.disabled.tintColor";
static NSString* const kIXDarkensImageOnTouch = @"darkens_image_on_touch";
static NSString* const kIXTitleDefaultText = @"title.default.text";
static NSString* const kIXTitleDefaultFont = @"title.default.font";
static NSString* const kIXTitleDefaultColor = @"title.default.color";
static NSString* const kIXTitleTouchText = @"title.touch.text";
static NSString* const kIXTitleTouchFont = @"title.touch.font";
static NSString* const kIXTitleTouchColor = @"title.touch.color";
static NSString* const kIXTitleDisabledText = @"title.disabled.text";
static NSString* const kIXTitleDisabledFont = @"title.disabled.font";
static NSString* const kIXTitleDisabledColor = @"title.disabled.color";

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
    
    [[self button] setEnabled:[[self contentView] isEnabled]];
    
    BOOL darkensImageOnTouch = [[self propertyContainer] getBoolPropertyValue:kIXDarkensImageOnTouch defaultValue:NO];
    [[self button] setAdjustsImageWhenHighlighted:darkensImageOnTouch];
    
    [[self button] setAttributedTitle:nil forState:UIControlStateNormal];
    [[self button] setAttributedTitle:nil forState:UIControlStateHighlighted];
    [[self button] setAttributedTitle:nil forState:UIControlStateDisabled];

    NSString* defaultTextForTitles = nil;
    UIColor* defaultColorForTitles = [UIColor lightGrayColor];
    UIFont* defaultFontForTitles = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];

    UIColor* defaultTintColorForImages = nil;
    
    NSArray* differentTitleStates = @[kIX_DEFAULT,kIXTouch,kIXDisabled];
    for( NSString* titleState in differentTitleStates )
    {
        UIControlState controlState = UIControlStateNormal;
        NSString* titleTextPropertyName = kIXTitleDefaultText;
        NSString* titleColorPropertyName = kIXTitleDefaultColor;
        NSString* titleFontPropertyName = kIXTitleDefaultFont;
        NSString* imagePropertyName = kIXImagesDefault;
        NSString* imageTintColorPropertyName = kIXImagesDefaultTintColor;
        
        if( [titleState isEqualToString:kIXTouch] )
        {
            controlState = UIControlStateHighlighted;
            titleTextPropertyName = kIXTitleTouchText;
            titleColorPropertyName = kIXTitleTouchColor;
            titleFontPropertyName = kIXTitleTouchFont;
            imagePropertyName = kIXImagesTouch;
            imageTintColorPropertyName = kIXImagesTouchTintColor;
        }
        else if( [titleState isEqualToString:kIXDisabled] )
        {
            controlState = UIControlStateDisabled;
            titleTextPropertyName = kIXTitleDisabledText;
            titleColorPropertyName = kIXTitleDisabledColor;
            titleFontPropertyName = kIXTitleDisabledFont;
            imagePropertyName = kIXImagesDisabled;
            imageTintColorPropertyName = kIXImagesDisabledTintColor;
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
                                          [[weakSelf button] setBackgroundImage:image forState:controlState];
                                      } failBlock:nil];
    }
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
