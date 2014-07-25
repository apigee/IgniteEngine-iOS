//
//  IXTextControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXText.h"

#import "UILabel+IXAdditions.h"
#import "NSString+FontAwesome.h"

// IXText Properties
static NSString* const kIXText = @"text";
static NSString* const kIXTextAlignment = @"text.alignment";
static NSString* const kIXTextColor = @"text.color";
static NSString* const kIXFont = @"font";
static NSString* const kIXSizeToFit = @"size_to_fit";

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
    CGSize sizeThatFits = [[self label] sizeThatFits:size];
    float height = ceilf([[self label] sizeForFixedWidth:size.width].height);
    return CGSizeMake(sizeThatFits.width, height);
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self label] setFrame:rect];
    if( [self shouldSizeLabelToFit] )
    {
        [[self label] sizeToFit];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    [[self label] setUserInteractionEnabled:[[self contentView] isEnabled]];
    [[self label] setTextColor:[[self propertyContainer] getColorPropertyValue:kIXTextColor defaultValue:[UIColor blackColor]]];
    [[self label] setFont:[[self propertyContainer] getFontPropertyValue:kIXFont defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]]];

    NSString* text = [[self propertyContainer] getStringPropertyValue:kIXText defaultValue:nil];
    if( [[[[self label] font] familyName] isEqualToString:kFontAwesomeFamilyName] )
    {
        [[self label] setText:[NSString fontAwesomeIconStringForIconIdentifier:text]];
    }
    else
    {
        [[self label] setText:text];
    }
    [[self label] setTextAlignment:[UILabel ix_textAlignmentFromString:[[self propertyContainer] getStringPropertyValue:kIXTextAlignment defaultValue:nil]]];
    [[self label] setNumberOfLines:0];
    [[self label] setLineBreakMode:NSLineBreakByWordWrapping];
    
    BOOL sizeLabelToFitDefaultValue = ([[self label] textAlignment] == NSTextAlignmentLeft);
    [self setSizeLabelToFit:[[self propertyContainer] getBoolPropertyValue:kIXSizeToFit defaultValue:sizeLabelToFitDefaultValue]];
}

@end
