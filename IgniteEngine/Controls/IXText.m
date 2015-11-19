//
//  IXTextControl.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXText.h"

#import "UIFont+IXAdditions.h"
#import "UILabel+IXAdditions.h"
#import "NSString+FontAwesome.h"

// IXText Properties
static NSString* const kIXText = @"text";
static NSString* const kIXTextAlignment = @"text.align";
static NSString* const kIXTextColor = @"color";
static NSString* const kIXFont = @"font";
static NSString* const kIXSizeToFit = @"fitTextToWidth.enabled";

@interface IXText ()

@property (nonatomic,strong) UILabel* label;
@property (nonatomic,assign,getter = shouldSizeLabelToFit) BOOL sizeLabelToFit;

@end

@implementation IXText

-(void)buildView
{
    [super buildView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _sizeLabelToFit = YES;
    
    [[self contentView] addSubview:[self label]];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    float width = ceilf([[self label] sizeThatFits:size].width);
    float height = ceilf([[self label] sizeForFixedWidth:size.width].height);
    return CGSizeMake(width, height);
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self label] setFrame:rect];
    if( [self shouldSizeLabelToFit] )
    {
        UIFont* autoSizedFont = [UIFont ix_fontForString:self.label.text toFitInRect:rect seedFont:self.label.font];
        [self.label setFont:autoSizedFont];
    }
}

-(void)applySettings
{
    [super applySettings];

    [self setSizeLabelToFit:[[self attributeContainer] getBoolValueForAttribute:kIXSizeToFit defaultValue:NO]];

    [[self label] setNumberOfLines:0];
    [[self label] setLineBreakMode:NSLineBreakByWordWrapping];
    [[self label] setTextAlignment:[UILabel ix_textAlignmentFromString:[[self attributeContainer] getStringValueForAttribute:kIXTextAlignment defaultValue:nil]]];
    [[self label] setUserInteractionEnabled:[[self contentView] isEnabled]];
    [[self label] setTextColor:[[self attributeContainer] getColorValueForAttribute:kIXTextColor defaultValue:[UIColor blackColor]]];
    [[self label] setFont:[[self attributeContainer] getFontValueForAttribute:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]]];

    NSString* text = [[self attributeContainer] getStringValueForAttribute:kIXText defaultValue:nil];

    if( [self.label.font.familyName isEqualToString:kFontAwesomeFamilyName] )
    {
        [[self label] setText:[NSString fontAwesomeIconStringForIconIdentifier:text]];
    }
    else
    {
        [[self label] setText:text];
    }
}

@end
