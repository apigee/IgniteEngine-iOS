//
//  ixe  Control.m
//  Ignite iOS Engine (ixe)
//
//  Created by Jeremy Anticouni on 11/18.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 /--------------------/
 - TYPE : "___"
 - DESCRIPTION: "___ Description."
 /--------------------/
 - PROPERTIES
 /--------------------/
 * name=""        default=""               type="___"
 /--------------------/
 - EVENTS
 /--------------------/
 * name="share_done"
 * name="share_cancelled"
 /--------------------/
 - Example
 /--------------------/
 
 /--------------------/
 - Changelog
 /--------------------/
 
 /--------------------/
 */

#import "ixePanel.h"
#import "ixeAppManager.h"
#import "ixeNavigationViewController.h"
#import "ixeViewController.h"
#import "JASidePanelController.h"

#import "UIViewController+JASidePanel.h"


@interface  ixePanel()

@end

@implementation ixePanel

-(void)buildView
{
    [super buildView];

}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}

-(void)applySettings
{
    [super applySettings];
    //[[ixeAppManager sharedInstance] rootViewController]]
    /*
     
     JASidePanelController* controller = [[JASidePanelController alloc] init];
     [controller.view setBackgroundColor:[UIColor magentaColor]];
     UIViewController* vc1 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
     [vc1.view setBackgroundColor:[UIColor greenColor]];
     UIViewController* vc2 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
     [vc2.view setBackgroundColor:[UIColor blueColor]];
     
     [controller setLeftPanel:vc1];
     [controller setRightPanel:vc2];
     [controller setCenterPanel:[[ixeAppManager sharedInstance] rootViewController]];

     
     */

    
    UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
	label.text = @"Left Panel";
	[label sizeToFit];
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [[self contentView] addSubview:label];
    
    
    
}


@end
