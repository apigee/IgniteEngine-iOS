//
//  IXTextControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXText.h"

#import "UILabel+IXAdditions.h"

@interface IXText ()

@property (nonatomic,strong) UILabel* label;

@end

@implementation IXText

-(void)buildView
{
    [super buildView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:[self label]];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    CGSize sizeThatFits = [[self label] sizeThatFits:size];
    float height = [[self label] sizeForFixedWidth:size.width].height;
    return CGSizeMake(sizeThatFits.width, height);
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self label] setFrame:rect];
    [[self label] sizeToFit];
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* text = [self.propertyContainer getStringPropertyValue:@"text" defaultValue:nil];
    [[self label] setText:text];
    
    UIFont* font = [[self propertyContainer] getFontPropertyValue:@"font" defaultValue:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];

    [[self label] setTextColor:[[self propertyContainer] getColorPropertyValue:@"color.text" defaultValue:[UIColor blackColor]]];
    
    [[self label] setFont:font];
}

@end
