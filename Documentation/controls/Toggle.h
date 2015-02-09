//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Toggle switch to toggle on and to toggle off.
*/

@implementation Toggle

/***************************************************************/

/** IXToggle has the following attributes:
 
 @param defaultOn.enabled Default On<br><code>bool</code> *FALSE*
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXToggle has no events.
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXToggle has the following functions:
 
 @param toggle Toggle
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param toggleOff Toggle off
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param toggleOn Toggle on
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXToggle returns the following values:
 
 @param isOn Returns true if toggle is on<br><code>bool</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
{
    "_id": "toggleTest",
    "_type": "Toggle",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "toggleOn"
            },
            "on": "toggleOn"
        },
        {
            "_type": "Alert",
            "attributes": {
                "title": "toggleOff"
            },
            "on": "toggleOff"
        }
    ],
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "layoutType": "absolute"
    }
}
</pre>
 
*/

-(void)Example
{
}

/***************************************************************/

@end
