//
//  IXAlertAction.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/* Displays a native alert. Can be informational with a single button or actionable with two buttons.
*/


@interface Alert

/***************************************************************/

/** Alert has the following attributes:
 
 @param button.titles Button titles<br><pre>comma</pre>
 @param message Message of alert<br><pre>string</pre>
 @param title Title of alert<br><pre>string</pre>
 
*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Alert fires the following events:
 
 @param button.%lu.pressed Fires when %lu button pressed
 @param button.pressed Fires when button pressed
 @param didPresent Fires when alert did present
 @param willPresent Fires when alert will present
 
*/

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Alert has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/
/** Go on, try it out!
 
 <pre class="brush: js; toolbar: false;">
{
    "_id": "button",
    "_type": "Button",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "message": "You touched the button!",
                "title": "touchUp"
            },
            "enabled": true,
            "on": "touchUp"
        }
    ],
    "attributes": {
        "bg.color": "cdcdcd",
        "color": "6c6c6c",
        "margin.top": 15,
        "size.h": 50,
        "size.w": 150,
        "text": "simple alert.",
        "touch.bg.color": "cdcdcd",
        "touch.color": "6c6c6c50"
    }
}
</pre>
*/

-(void)Example
{
}
/***************************************************************/

@end