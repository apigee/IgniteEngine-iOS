//
//  IXEventAction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/25/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

@interface Event

/***************************************************************/

/** Event has the following attributes:
 
 @param _target Event target ID
 @param eventName Name of the event to raise<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Event has the following events:
 
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Event has the following functions:
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Event returns the following values:
 
 
 
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
            "_type": "Event",
            "attributes": {
                "_target": "button1",
                "eventName": "touchUp"
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
        "text": "raise touchUp on button1",
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
                "message": "[[$self.text]]",
                "title": "[[$self._id]]"
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
