//
//  IXButton.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXButton.h"

#import "UIImage+IXAdditions.h"

// IXButton states
static NSString* const kIXNormal = @"normal";
static NSString* const kIXTouch = @"touch";
static NSString* const kIXDisabled = @"disabled";

// IXButton properties
static NSString* const kIXTextDefault = @"text";
static NSString* const kIXTextDefaultFont = @"text.font";
static NSString* const kIXTextDefaultColor = @"text.color";
static NSString* const kIXIconDefault = @"icon";
static NSString* const kIXIconDefaultTintColor = @"icon.tintcolor";

static NSString* const kIXTextTouch = @"text.touch";
static NSString* const kIXTextTouchFont = @"text.touch.font";
static NSString* const kIXTextTouchColor = @"text.touch.color";
static NSString* const kIXIconTouch = @"icon.touch";
static NSString* const kIXIconTouchTintColor = @"icon.touch.tintcolor";

static NSString* const kIXTextDisabled = @"text.disabled";
static NSString* const kIXTextDisabledFont = @"text.disabled.font";
static NSString* const kIXTextDisabledColor = @"text.disabled.color";
static NSString* const kIXIconDisabled = @"icon.disabled";
static NSString* const kIXIconDisabledTintColor = @"icon.disabled.tintcolor";

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
    
    NSArray* differentTitleStates = @[kIXNormal,kIXTouch,kIXDisabled];
    for( NSString* titleState in differentTitleStates )
    {
        UIControlState controlState = UIControlStateNormal;
        NSString* titleTextPropertyName = kIXTextDefault;
        NSString* titleColorPropertyName = kIXTextDefaultColor;
        NSString* titleFontPropertyName = kIXTextDefaultFont;
        NSString* imagePropertyName = kIXIconDefault;
        NSString* imageTintColorPropertyName = kIXIconDefaultTintColor;
        
        if( [titleState isEqualToString:kIXTouch] )
        {
            controlState = UIControlStateHighlighted;
            titleTextPropertyName = kIXTextTouch;
            titleColorPropertyName = kIXTextTouchColor;
            titleFontPropertyName = kIXTextTouchFont;
            imagePropertyName = kIXIconTouch;
            imageTintColorPropertyName = kIXIconTouchTintColor;
        }
        else if( [titleState isEqualToString:kIXDisabled] )
        {
            controlState = UIControlStateDisabled;
            titleTextPropertyName = kIXTextDisabled;
            titleColorPropertyName = kIXTextDisabledColor;
            titleFontPropertyName = kIXTextDisabledFont;
            imagePropertyName = kIXIconDisabled;
            imageTintColorPropertyName = kIXIconDisabledTintColor;
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
