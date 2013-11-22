//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
 
 - TYPE : "ToggleSwitch"
 
 - EVENTS
 
 * name="toggle"
 * name="toggle_on"
 * name="toggle_off"
  
 */

#import "IXToggle.h"

@interface  IXToggle()

@property (nonatomic,strong) NSString* imagePath;
@property (nonatomic,strong) NSString* touchedImagePath;

@end

@implementation IXToggle

-(void)buildView
{
    [super buildView];
    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [toggleSwitch addTarget:self action:@selector(eventSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    [toggleSwitch setOn:[[self propertyContainer] getBoolPropertyValue:@"selected" defaultValue:NO]];
    
    [[self contentView] addSubview:toggleSwitch];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeMake(toggleSwitch.frame.size.width, toggleSwitch.frame.size.height);
}

-(void)applySettings
{
    [super applySettings];
    

}

- (void)eventSwitchChanged: (id)sender
{
    if (![sender isKindOfClass: [UISwitch class]])
    {
        //error handling
        return;
    }
    
    if (toggleSwitch.on){
        
//        [self.settings setSetting:@"selected" value:@"YES"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_on"];
        
    }
    else {
        
//        [self.settings setSetting:@"selected" value:@"NO"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle"];
        [[self actionContainer] executeActionsForEventNamed:@"toggle_off"];
        
    }
    
}

@end
