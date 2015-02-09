//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A Dial that allows the user to turn things up or down.
*/

@implementation Dial

/***************************************************************/

/** Dial has the following attributes:
 
 @param animation.duration Animation duration<br><code>float</code>
 @param bg.image Background image<br><code>string</code>
 @param value.default Default value<br><code>float</code>
 @param fg.image Foreground image<br><code>string</code>
 @param maxAngle Maximum angle<br><code>float</code>
 @param value.max Maximum value<br><code>float</code>
 @param pointer.image Pointer image<br><code>string</code>
 @param value.min Value minimum<br><code>float</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Dial has the following events:
 
 @param touch Fires on touch
 @param touchUp Fires on touch up inside
 @param valueChanged Fires when value changes
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Dial has the following functions:
 
 @param setValue Set value
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Dial returns the following values:
 
 @param value Value<br><code>float</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">

{
  "_id": "customDial",
  "_type": "Dial",
  "actions": [
    {
      "_type": "Refresh",
      "attributes": {
        "_target": "DialValue"
      },
      "enabled": true,
      "on": "value_changed"
    }
  ],
  "attributes": {
    "color": {
      "background": "#00000000"
    },
    "width": 250,
    "height": 250,
    "horizontal_alignment": "center",
    "layout_type": "relative",
    "initial_value": 0,
    "minimum_value": 0,
    "maximum_value": 100,
    "Dial_animation_duration": 0.5,
    "images": {
      "pointer": "images/marker.png",
      "background": "images/bg.png"
    }
  }
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
