//
//  IXAnimateAction.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseAction.h"

@interface Animate

/***************************************************************/

/** Animate has the following attributes:
 
 @param _target Animation target ID<br><pre>string</pre>
 @param animation Animation directiondirection
 @param direction Direction?
 @param duration Animation duration<br><pre>float</pre>
 @param repeatCount Repeat count<br><pre>int</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Animate has no events.
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Animate has no functions.
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Animate returns no values.
 
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
            "_type": "Animate",
            "attributes": {
                "_target": "layoutSpinMe",
                "animation": "spin",
                "duration": 1,
                "repeatCount": 0
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
        "text": "animate",
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
