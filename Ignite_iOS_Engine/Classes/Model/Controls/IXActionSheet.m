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

/**
 
 Native iOS UI control that displays a menu from the bottom of the screen.
 
 <div id="container">   <ul>
         <li><a href="../images/IXActionSheet_0.png" data-imagelightbox="c"><img src="../images/IXActionSheet_0.png"></a></li>
         <li><a href="../images/IXActionSheet_1.png" data-imagelightbox="c"><img src="../images/IXActionSheet_1.png"></a></li>
         <li><a href="../images/IXActionSheet_2.png" data-imagelightbox="c"><img src="../images/IXActionSheet_2.png"></a></li>
     </ul>
 </div>
 
*/


#import "IXActionSheet.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"

// Attributes
IX_STATIC_CONST_STRING kIXSheetStyle = @"style";
IX_STATIC_CONST_STRING kIXSheetTitle = @"title";
IX_STATIC_CONST_STRING kIXSheetButtonTitleCancel = @"buttons.cancel";
IX_STATIC_CONST_STRING kIXSheetButtonTitleDestructive = @"buttons.destructive";
IX_STATIC_CONST_STRING kIXSheetButtonTitleOthers = @"buttons.others";

// Attribute Value Available Parameters
IX_STATIC_CONST_STRING kIXSheetStyleDefault = @"default";
IX_STATIC_CONST_STRING kIXSheetStyleAutomatic = @"automatic";
IX_STATIC_CONST_STRING kIXSheetStyleBlackTranslucent = @"black.translucent";
IX_STATIC_CONST_STRING kIXSheetStyleBlackOpaque = @"black.opaque";

// Attribute Value Defaults
IX_STATIC_CONST_STRING kIXDefaultCancelButtonTitle = @"Cancel";
IX_STATIC_CONST_OBJECT kIXDefaultSheetTitle = nil;
IX_STATIC_CONST_OBJECT kIXDefaultDestructiveButtonTitle = nil;
IX_STATIC_CONST_OBJECT kIXDefaultOtherButtonTitles = nil;

// Returns

// Events
IX_STATIC_CONST_STRING kIXCancelPressed = @"cancelled";
IX_STATIC_CONST_STRING kIXButtonPressedFormat = @"%@";

// Functions
IX_STATIC_CONST_STRING kIXShowSheet = @"show_sheet";
IX_STATIC_CONST_STRING kIXDismissSheet = @"dismiss_sheet";

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

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>
 
    @param sheet.style The sheet style<br>*defaultautomaticblack.translucentblack.opaque*
    @param sheet.title The sheet title<br>*(string)*
    @param sheet.button.title.cancel Cancel button text<br>*(string)*
    @param sheet.button.title.destructive Destructive button text<br>*(string)*
    @param sheet.button.title.others Other button(s) text<br>*(string)*
    
*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/**  Returns the following readonly properties:

 */

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param cancel_pressed The ‘cancel’ button was pressed.
    @param %@_pressed The ‘%@’ button was pressed.

*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


    @param show_sheet 
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "actionSheetTest",
    "function_name": "show_sheet"
  }
}
 </pre>


    @param dismiss_sheet 
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "actionSheetTest",
    "function_name": "dismiss_sheet"
  }
}
</pre>


*/

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>

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

-(void)example
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

    [self setSheetTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetTitle defaultValue:kIXDefaultSheetTitle]];
    [self setCancelButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleCancel defaultValue:kIXDefaultCancelButtonTitle]];
    [self setDestructiveButtonTitle:[[self propertyContainer] getStringPropertyValue:kIXSheetButtonTitleDestructive defaultValue:kIXDefaultDestructiveButtonTitle]];
    [self setOtherTitles:[[self propertyContainer] getCommaSeperatedArrayListValue:kIXSheetButtonTitleOthers defaultValue:kIXDefaultOtherButtonTitles]];
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