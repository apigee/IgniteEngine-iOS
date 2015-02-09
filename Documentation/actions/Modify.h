//
//  IXModifyAction.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 ACTION
 
 - TYPE : "Modify"
 
 - PROPERTIES
 
 * name="id"            default=""        type="STRING"
 * name="duration"      default=""        type="STRING"
 * name="parameters"    default=""        type="ATTRIBUTE CONTAINER"
 
 */

@interface Modify

/***************************************************************/

/** Modify has the following attributes:
 
 @param _target Modify target ID<br><pre>string</pre>
 @param animationStyle Animation style<ul><li>*easeInOut*</li><li>easeIn</li><li>easeOut</li><li>linear</li></ul>
 @param duration Modify duration<br><pre>float</pre>
 @param easeIn Ease in
 @param easeInOut Ease in and out
 @param easeOut Ease out
 @param linear Linear
 @param staggerDelay Stagger execution of multiple target IDs<br><pre>float</pre>
 
*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Modify has no events.
 
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Modify has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Modify returns no values.
 
 
 
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
            "_type": "Modify",
            "attributes": {
                "_target": "button1"
            },
            "enabled": true,
            "on": "touchUp",
            "set": {
                "text": "this is different."
            }
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
