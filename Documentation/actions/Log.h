//
//  IXLogAction.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/23/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

@interface Log

/***************************************************************/

/** Log has the following attributes:
 
 @param delay Log text delay<br><pre>float</pre>
 @param text Log text<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Log has the following events:
 
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Log has the following functions:
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Log returns the following values:
 
 
 
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
            "_type": "Log",
            "attributes": {
                "text": "log this, baby"
            },
            "on": "touchUp"
        }
    ],
    "attributes": {
        "bg.color": "cdcdcd",
        "size.h": 50,
        "size.w": 280
    }
}
</pre>
*/

-(void)Example
{
}
/***************************************************************/

@end
