//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Native iOS UI control that displays a menu from the bottom of the screen.
*/

@implementation ActionSheet

/***************************************************************/

/** ActionSheet has the following attributes:
 
 @param style Style of sheet<ul><li>*default*</li><li>automatic</li><li>black.translucent</li><li>black.opaque</li></ul>
 @param buttons.cancel Text displayed on cancel button<br><code>string</code> *Cancel*
 @param buttons.others Text displayed on other buttons (comma-separated)<br><code>string</code>
 @param buttons.destructive Text displayed on the destructive (red) button<br><code>string</code>
 @param title Title of sheet<br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** ActionSheet has the following events:
 
 @param %@ A named (other) button was pressed
 @param cancelled The cancel button was pressed
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** ActionSheet has the following functions:
 
 @param dismiss Dismisses the action sheet
 <pre class=""brush: js; toolbar: false;"">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "actionSheetTest",
    "function_name": "dismiss"
  }
}
 
 </pre>
 
 @param present Presents the action sheet
 <pre class=""brush: js; toolbar: false;"">
 
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

/** ActionSheet returns no values.
 
 */

-(void)Returns
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

@end