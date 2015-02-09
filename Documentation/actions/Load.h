//
//  IXLoadAction.h
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/6/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

@interface Load

/***************************************************************/

/** Load has the following attributes:
 
 @param _target Load target ID<br><pre>string</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Load has no events.
 
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Load has no functions.
 
 
 
*/

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Load returns no values.
 
 
 
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
            "_type": "Load",
            "attributes": {
                "_target": "dataMenu"
            },
            "enabled": true,
            "on": "touchUp"
        }
    ],
    "attributes": {
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
