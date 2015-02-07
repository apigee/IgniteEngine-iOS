//
//  IXButton.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/3/14.
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

/** It's a button. Put text on it and trigger an action, maybe even add an image.
*/

#import "IXButton.h"

#import "UIImage+IXAdditions.h"
#import "UIButton+IXAdditions.h"

// Attributes
IX_STATIC_CONST_STRING kIXTextDefault = @"text";
IX_STATIC_CONST_STRING kIXTextDefaultFont = @"font";
IX_STATIC_CONST_STRING kIXTextDefaultColor = @"color";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"bg.color";
IX_STATIC_CONST_STRING kIXIconDefault = @"icon";
IX_STATIC_CONST_STRING kIXIconDefaultTintColor = @"icon.tint";
IX_STATIC_CONST_STRING kIXAlpha = @"alpha";
IX_STATIC_CONST_STRING kIXDarkensImageOnTouch = @"darkenOnTouch.enabled";
IX_STATIC_CONST_STRING kIXTouchDuration = @"touch.duration";
IX_STATIC_CONST_STRING kIXTouchUpDuration = @"touchUp.duration";

# warning Deprecate these and merge into comma-separated values in default attribute
IX_STATIC_CONST_STRING kIXTouchText = @"touch.text";
IX_STATIC_CONST_STRING kIXTouchFont = @"touch.font";
IX_STATIC_CONST_STRING kIXTouchTextColor = @"touch.text.color";
IX_STATIC_CONST_STRING kIXTouchBackgroundColor = @"touch.background.color";
IX_STATIC_CONST_STRING kIXTouchIcon = @"touch.icon";
IX_STATIC_CONST_STRING kIXTouchIconTintColor = @"touch.icon.tintColor";
IX_STATIC_CONST_STRING kIXTouchAlpha = @"touch.alpha";
IX_STATIC_CONST_STRING kIXDisabledText = @"disabled.text";
IX_STATIC_CONST_STRING kIXDisabledFont = @"disabled.font";
IX_STATIC_CONST_STRING kIXDisabledTextColor = @"disabled.text.color";
IX_STATIC_CONST_STRING kIXDisabledBackgroundColor = @"disabled.background.color";
IX_STATIC_CONST_STRING kIXDisabledIcon = @"disabled.icon";
IX_STATIC_CONST_STRING kIXDisabledIconTintColor = @"disabled.icon.tintColor";
IX_STATIC_CONST_STRING kIXDisabledAlpha = @"disabled.alpha";

// IXButton states
IX_STATIC_CONST_STRING kIXNormal = @"normal";
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXDisabled = @"disabled";

@interface IXButton ()



@property (nonatomic,strong) UIButton* button;

@end



@implementation IXButton

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes:

    @param text The text displayed<br>*(string)*
    @param text.color The text color *(default: #ffffff)*<br>*(color)*
"    @param font The text font name and size (font:size) 
See http://iosfonts.com/ for available fonts. *(default: HelveticaNeue:20)*<br>*(string)*"
    @param background.color The background color<br>*(color)*
    @param icon The icon image path<br>*(string)*
    @param icon.tintColor The icon tint color<br>*(color)*
    @param touch.text The text displayed on touch events<br>*(string)*
    @param touch.font The text font displayed on touch events<br>*(string)*
    @param touch.text.color The text color on touch events<br>*(color)*
    @param touch.background.color The background color on touch events<br>*(color)*
    @param touch.icon The icon image path on touch events<br>*(string)*
    @param touch.icon.tintColor The icon tint color on touch events<br>*(color)*
    @param touch.alpha The button alpha on touch events<br>*(float)*
    @param disabled.text The text displayed when button is disabled<br>*(string)*
    @param disabled.font The font when button is disabled<br>*(string)*
    @param disabled.text.color The text color when button is disabled<br>*(color)*
    @param disabled.background.color The background color when button is disabled<br>*(color)*
    @param disabled.icon The icon displayed when button is disabled<br>*(string)*
    @param disabled.icon.tintColor The icon tint color when button is disabled<br>*(color)*
    @param disabled.alpha The button alpha when button is disabled<br>*(float)*
    @param darkens_image_on_touch Darkens image on touch events *(default: FALSE)*<br>*(bool)*
    @param touch.duration The touch duration to trigger a touch event *(default: 0.4)*<br>*(float)*
    @param touch_up.duration The touch duration to trigger a touch_up event *(default: 0.4)*<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param touch Fires when the control is touched
    @param touch_up Fires when the control touch is released

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
 {
    "_id": "button",
    "_type": "Button",
    "actions": [
      {
        "_type": "Alert",
        "on": "touch_up",
        "attributes": {
          "title": "touch_up",
          "message": "You touched the button!"
        }
      }
    ],
    "attributes": {
      "width": 100,
      "height": 50,
      "text.color": "6c6c6c",
      "layout_type": "absolute",
      "background.color": "cdcdcd",
      "touch.text.color": "6c6c6c50",
      "horizontal_alignment": "center",
      "vertical_alignment": "middle",
      "touch.background.color": "cdcdcd",
      "border.radius": 0,
      "text": "Hi."
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
        CGFloat buttonAlpha = [self.propertyContainer getFloatPropertyValue:kIXTouchAlpha defaultValue:1.0f];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             if (buttonAlpha < 1)
                             {
                                 self.button.alpha = buttonAlpha;
                             }
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
        CGFloat buttonAlpha = [self.propertyContainer getFloatPropertyValue:kIXAlpha defaultValue:1.0f];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.button.alpha = buttonAlpha;
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
        CGFloat buttonAlpha = [self.propertyContainer getFloatPropertyValue:kIXAlpha defaultValue:1.0f];
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.button.alpha = buttonAlpha;
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
