//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
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
 ###    Native iOS toggle control.
 
 ####
 #### Attributes
 |  Name                                |   Type                    |   Description                                         |   Default
 |:-------------------------------------|:-------------------------:|:------------------------------------------------------|:-------------:|
 
 ####
 #### Inherits
 >  IXBaseControl
 
 ####
 #### Events
 |  Name                                |   Description                                         |
 |:-------------------------------------|:------------------------------------------------------|

 ####
 #### Functions

 
 ####
 #### Read-Only Properties

    {
        "_id": "aLabel",
        "_type": "Text",
        "attributes": {
            "text": "The toggle is currently [[toggle1.is_on]]"
        }
    }
 
 ####
 #### Example JSON
 
    {
        "_id": "button",
        "_type": "Button",
        "actions": [
            {
                "_type": "Function",
                "attributes": {
                    "_target": "myToggle",
                    "function_name": "toggle"
                },
                "on": "touch_up"
            }
        ]
    },
    {
        "_id": "button2",
        "_type": "Button",
        "actions": [
            {
                "_type": "Function",
                "attributes": {
                    "_target": "myToggle",
                    "function_name": "toggle_off"
                },
                "on": "touch_up"
            }
        ]
    },
    {
        "_id": "button3",
        "_type": "Button",
        "actions": [
            {
                "_type": "Function",
                "attributes": {
                    "_target": "myToggle",
                    "function_name": "toggle_on"
                },
                "on": "touch_up"
            }
        ]
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXToggle.h"

#import "NSString+IXAdditions.h"

@interface  IXToggle ()

@property (nonatomic,assign) BOOL hasAppliedSettings;
@property (nonatomic,strong) UISwitch *toggleSwitch;

@end

@implementation IXToggle

-(void)buildView
{
    [super buildView];
    
    _hasAppliedSettings = NO;
    
    _toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    [[self contentView] addSubview:_toggleSwitch];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeMake([self toggleSwitch].frame.size.width, [self toggleSwitch].frame.size.height);
}

-(void)applySettings
{
    [super applySettings];
    
    if( ![self hasAppliedSettings] )
    {
        [self setHasAppliedSettings:YES];
        [[self toggleSwitch] setOn:[[self propertyContainer] getBoolPropertyValue:@"initally_selected" defaultValue:NO] animated:NO];
    }
}

-(void)switchToggled:(UISwitch*)sender
{
    if( [[self toggleSwitch] isOn] )
    {
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_on"];
    }
    else
    {        
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_off"];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:@"toggle"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:![[self toggleSwitch] isOn] animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];

    }
    else if( [functionName isEqualToString:@"toggle_on"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:YES animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_on"];

    }
    else if( [functionName isEqualToString:@"toggle_off"] )
    {
        BOOL animated = YES;
        if( parameterContainer ) {
            animated = [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:animated];
        }
        [[self toggleSwitch] setOn:NO animated:animated];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_off"];
        
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:@"is_on"] )
    {
        returnValue = [NSString ix_stringFromBOOL:[[self toggleSwitch] isOn]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

@end
