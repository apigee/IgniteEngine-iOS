//
//  IXActionSheet.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/18/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:       01/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** Native iOS UI control that displays a menu from the bottom of the screen.
*/


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

/*
 * Docs
 *
*/


/***************************************************************/

/** This control has the following attributes:
 
 @param buttons.cancel Text displayed on cancel button<br><code>string</code> *Cancel*
 @param buttons.destructive Text displayed on the destructive (red) button<br><code>string</code>
 @param buttons.others Text displayed on other buttons (comma-separated)<br><code>string</code>
 @param style The sheet style<ul><li>*default*</li><li>automatic</li><li>black.translucent</li><li>black.opaque</li></ul>
 @param title The sheet title<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/**  This control has no read-only properties.
 
 */

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:
 
 @param %@ButtonPressed A numbered (other) button was pressed
 @param cancelled The cancel button was pressed
 
 */

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:
 
 
 @param dismiss Dismisses the action sheet
 <pre class="brush: js; toolbar: false;">
 {
 "_type": "Function",
 "on": "touch_up",
 "attributes": {
 "_target": "actionSheetTest",
 "function_name": "dismiss"
 }
 }
 </pre>
 
 @param show Presents the action sheet
 <pre class="brush: js; toolbar: false;">
 {
 "_type": "Function",
 "on": "touch_up",
 "attributes": {
 "_target": "actionSheetTest",
 "function_name": "present"
 }
 }
 </pre>
 
 */

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!
 
 <pre class="brush: js; toolbar: false;">
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