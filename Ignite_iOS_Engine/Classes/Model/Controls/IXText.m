//
//  IXTextControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Brandon Shelley
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    Text input control. Utilizes a hybrid of iOS native controls to provide a unified input interface.
 
 ####
 #### Attributes
 |  Name                                |   Type                    |   Description                                         |   Default
 |:-------------------------------------|:-------------------------:|:------------------------------------------------------|:-------------:|
 | *enabled*                            |  bool                     |                                                       |  true
 | *repeats*                            |  bool                     |  Indicates whether or not the timer repeats           |  false
 | *time_interval*                      |  integer                  |  Duration of time interval                            |  0 (disabled)

 
 ####
 #### Inherits
 >  IXBaseControl
 
 ####
 #### Events
 |  Name                                |   Description                                         |
 |:-------------------------------------|:------------------------------------------------------|
 @"timer_fired";
 | *timer_fired*                        |   Event that occurs each time the timer fires.

 ####
 #### Functions
 
 *start*
    
    {
        "_type": "Function",
        "on": "did_appear",
        "attributes": {
            "function_name": "start"
        }
    }
  
 *stop*
    
    {
        "_type": "Function",
        "on": "did_appear",
        "attributes": {
            "function_name": "stop"
        }
    }
 
 ####
 #### Read-Only Properties

 
 ####
 #### Example JSON
 
    {
        "_id": "timerControl",
        "_type": "Timer",
        "actions": [
            {
                "_type": "Alert",
                "attributes": {
                    "title": "Timer Fired!"
                },
                "on": "timer_fired"
            }
        ],
        "attributes": {
            "enabled": true,
            "repeats": true,
            "time_interval": 5
        }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

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
