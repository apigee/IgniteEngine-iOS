//
//  IXActionSheet.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/28/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 http://ignite.apigee.com/training/ix/docs/images/IXActionSheet.png
 
 ####
 #### Attributes
 |  Name                                |   Type                    |   Description                                         |   Default
 |:-------------------------------------|:-------------------------:|:------------------------------------------------------|:-------------:|
 | *sheet.style*                        |   *default<br>automatic<br>black.translucent<br>black.opaque*  |   The sheet style                                   |   large
 | *sheet.title*                        |   *(string)*               |   The sheet title                                   |   #ffffff
 | *sheet.button.title.cancel*          |   *(string)*               |   Cancel button text                                   |   #ffffff
 | *sheet.button.title.destructive*     |   *(string)*               |   Destructive button text                                   |   #ffffff
 | *sheet.button.title.others*          |   *(string)*               |   Other button(s) text                                   |   #ffffff
 
 ####
 #### Inherits
 >  IXBaseControl
 
 ####
 #### Events
 |  Name                                |   Description                                         |
 |:-------------------------------------|:------------------------------------------------------|
 | *cancel_pressed*                     |   The 'cancel' button was pressed.
 | *%@_pressed*                         |   The '%@' button was pressed.
 
 ####
 #### Functions
 
 *show_sheet*
    
    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "actionSheetTest",
        "function_name": "show_sheet"
      }
    }
 
 *dismiss_sheet*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "actionSheetTest",
        "function_name": "dismiss_sheet"
      }
    }
 
 ####
 #### Example JSON
 
    {
      "_type": "ActionSheet",
      "_id": "actionSheetTest",
      "attributes": {
        "sheet.style": "black.opaque",
        "sheet.title": "sheetTitle",
        "sheet.button.title.cancel": "cancelButtonTitle",
        "sheet.button.title.destructive": "destructiveButtonTitle",
        "sheet.button.title.others": "other,someOther2"
      },
      "actions": [
        {
          "on": "cancel_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "Cancel Pressed"
          }
        },
        {
          "on": "other_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "other pressed [[app.bundle.version]]"
          }
        },
        {
          "on": "someOther2_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "someOther2 pressed"
          }
        },
        {
          "on": "destructiveButtonTitle_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "destructiveButtonTitle pressed"
          }
        }
      ]
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXActionSheet.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"

// IXActionSheet Attributes
IX_STATIC_CONST_STRING kIXSheetStyle = @"sheet.style";
IX_STATIC_CONST_STRING kIXSheetTitle = @"sheet.title";
IX_STATIC_CONST_STRING kIXSheetButtonTitleCancel = @"sheet.button.title.cancel";
IX_STATIC_CONST_STRING kIXSheetButtonTitleDestructive = @"sheet.button.title.destructive";
IX_STATIC_CONST_STRING kIXSheetButtonTitleOthers = @"sheet.button.title.others";

// kIXSheetStyle Accepted Values
IX_STATIC_CONST_STRING kIXSheetStyleDefault = @"default";
IX_STATIC_CONST_STRING kIXSheetStyleAutomatic = @"automatic";
IX_STATIC_CONST_STRING kIXSheetStyleBlackTranslucent = @"black.translucent";
IX_STATIC_CONST_STRING kIXSheetStyleBlackOpaque = @"black.opaque";

// IXActionSheet Functions
IX_STATIC_CONST_STRING kIXShowSheet = @"show_sheet";
IX_STATIC_CONST_STRING kIXDismissSheet = @"dismiss_sheet";

// IXActionSheet Events
IX_STATIC_CONST_STRING kIXCancelPressed = @"cancel_pressed";
IX_STATIC_CONST_STRING kIXButtonPressedFormat = @"%@_pressed";

@interface IXActionSheet () <UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet* actionSheet;
@property (nonatomic,strong) NSString* sheetTitle;
@property (nonatomic,assign) UIActionSheetStyle actionSheetStyle;
@property (nonatomic,strong) NSString* cancelButtonTitle;
@property (nonatomic,strong) NSString* destructiveButtonTitle;
@property (nonatomic,strong) NSArray* otherTitles;

@end

@implementation IXActionSheet

-(void)buildView
{

}

-(void)applySettings
{
    [super applySettings];

    [self setActionSheetStyle:UIActionSheetStyleAutomatic];

    NSString* style = [[self propertyContainer] getStringPropertyValue:kIXSheetStyle defaultValue:nil];
    if( [style isEqualToString:kIXSheetStyleDefault] )
    {
        [self setActionSheetStyle:UIActionSheetStyleDefault];
    }
    else if( [style isEqualToString:kIXSheetStyleBlackTranslucent] )
    {
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    }
    else if( [style isEqualToString:kIXSheetStyleBlackOpaque] )
    {
        [self setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    }

    [self setSheetTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetTitle defaultValue:nil]];
    [self setCancelButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleCancel defaultValue:@"Cancel"]];
    [self setDestructiveButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleDestructive defaultValue:nil]];
    [self setOtherTitles:[[self propertyContainer] getCommaSeperatedArrayListValue:kIXSheetButtonTitleOthers defaultValue:nil]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXShowSheet] )
    {
        if( [self actionSheet] != nil && [[self actionSheet] isVisible] )
        {
            [[self actionSheet] dismissWithClickedButtonIndex:0 animated:NO];
            [self setActionSheet:nil];
        }

        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:[self sheetTitle]
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:[self destructiveButtonTitle]
                                                        otherButtonTitles:nil];

        for( NSString* otherTitle in [self otherTitles] )
        {
            [actionSheet addButtonWithTitle:otherTitle];
        }

        if( [self cancelButtonTitle] != nil )
        {
            [actionSheet addButtonWithTitle:[self cancelButtonTitle]];
            [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons] - 1];
        }

        [self setActionSheet:actionSheet];
        [[self actionSheet] showInView:[[[IXAppManager sharedAppManager] rootViewController] view]];
    }
    else if( [functionName isEqualToString:kIXDismissSheet] )
    {
        if( [self actionSheet] != nil && [[self actionSheet] isVisible] )
        {
            [[self actionSheet] dismissWithClickedButtonIndex:0 animated:NO];
            [self setActionSheet:nil];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == [actionSheet cancelButtonIndex] )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXCancelPressed];
    }
    else
    {
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSString* eventName = [NSString stringWithFormat:kIXButtonPressedFormat,buttonTitle];
        [[self actionContainer] executeActionsForEventNamed:eventName];
    }
}

@end