//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A knob that allows the user to turn things up or down.
*/

@implementation Knob

/***************************************************************/

/** This control has the following attributes:

    @param initial_value Initial value to display<br>*(float)*
    @param minimum_value Minimum value allowed<br>*(float)*
    @param maximum_value Minimum value allowed<br>*(float)*
    @param images.foreground Image to overlay<br>*(string)*
    @param images.background Image to underlay<br>*(string)*
    @param images.pointer Image pointer<br>*(string)*
    @param maximum_angle Maximum Angle<br>*(float)*
    @param knob_animation_duration Animation duration<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param value The value the knob it set to<br>*(float)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param value_changed Fires when knob value is changed
    @param touch Fires on touch
    @param touch_up Fires on touch up inside
 
*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param update_knob_value Sets the knob to a new value

 <pre class="brush: js; toolbar: false;">

{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "customKnob",
    "function_name": "update_knob_value"
  },
  "set": {
    "value": 0,
    "animated": true
  }
}
 
 </pre>

*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">

{
  "_id": "customKnob",
  "_type": "Knob",
  "actions": [
    {
      "_type": "Refresh",
      "attributes": {
        "_target": "knobValue"
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
    "knob_animation_duration": 0.5,
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
