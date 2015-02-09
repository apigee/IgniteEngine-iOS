//
//  IXCreateAction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseAction.h"

@interface Create

/***************************************************************/

/** Create has the following attributes:
 
 @param control.url Location of control to create<br><pre>string</pre>
 @param parentId Parent ID of newly created control<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Create has the following events:
 
 @param created Fires when the control is created. Note: This fires on the control itself
 @param error Fires if control creation fails
 @param success Fires when control is created
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Create has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Create returns no values.
 
 
 
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
            "_type": "Create",
            "attributes": {
                "control.url": "../custom/IXCreateActionTest.json",
                "parentId": "layoutParent"
            },
            "on": "touchUp"
        }
    ],
    "attributes": {
        "bg.color": "cdcdcd",
        "color": "6c6c6c",
        "margin.top": 15,
        "size.h": 50,
        "size.w": 280,
        "text": "create something",
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
