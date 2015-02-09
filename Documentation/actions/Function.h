//
//  IXFunctionAction.h
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

@interface Function

/***************************************************************/

/** Function has the following attributes:
 
 @param _target Function target ID
 @param duration Duration
 @param functionName Name of the function to execute<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Function has no events.
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Function has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Function returns no values.
 
 
 
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
            "_type": "Function",
            "attributes": {
                "_target": "actionSheetTest",
                "functionName": "show"
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
        "text": "function: show_sheet",
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
