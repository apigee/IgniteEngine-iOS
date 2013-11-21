//
//  ixeImageControl.m
//  Ignite iOS Engine (ixe)
//
//  Created by Jeremy Anticouni on 11/15.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 
 - TYPE : "ToggleSwitch"
 
 - EVENTS
 
 * name="toggle"
 * name="toggle_on"
 * name="toggle_off"
  
 */

#import "ixeToggle.h"

@interface  ixeToggle()

@property (nonatomic,strong) NSString* imagePath;
@property (nonatomic,strong) NSString* touchedImagePath;

@end

@implementation ixeToggle

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
