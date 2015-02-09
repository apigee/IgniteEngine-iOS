//
//  IXDeleteAction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

@interface Delete

/***************************************************************/

/** Delete has the following attributes:
 
 @param _target Delete target ID<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Delete has the following events:
 
 @param error Fires when control fails to delete
 @param success Fires when control is deleted successfully
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Delete has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Delete returns no values.
 
 
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/
/** Go on, try it out!
 
 <pre class="brush: js; toolbar: false;">
{
    "_id": "button0",
    "_type": "Button",
    "actions": [
        {
            "_type": "Delete",
            "attributes": {
                "_target": "button1"
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
        "size.w": 280,
        "text": "delete button1",
        "touch.bg.color": "cdcdcd",
        "touch.color": "6c6c6c50"
    }
},
{
    "_id": "button1",
    "_type": "Button",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "button.titles": "button0,button1",
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
        "size.w": 280,
        "text": "button1 title",
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
