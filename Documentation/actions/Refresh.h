//
//  IXRefreshAction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/3/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

/*
 
 ACTION
 
 - TYPE : "Refresh"
 
 - PROPERTIES
 
 * name="id"            default=""        type="STRING"
 
 */

@interface Refresh

/***************************************************************/

/** Refresh has the following attributes:
 
 @param _target Refresh target ID<br><pre>string</pre>
 @param reloadData.enabled Refreshing a datasource without fetching new data<br><pre>bool</pre>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Refresh has no events.
 
 
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Refresh has no functions.
 
 
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Refresh returns no values.
 
 
 
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
            "_type": "Refresh",
            "attributes": {
                "_target": "button1"
            },
            "enabled": true,
            "on": "touchUp"
        }
    ],
    "attributes": {
        "bg.color": "cdcdcd",
        "size.h": 50,
        "size.w": 280,
        "text": "refresh button1 text"
    }
}
</pre>
*/

-(void)Example
{
}
/***************************************************************/

@end
