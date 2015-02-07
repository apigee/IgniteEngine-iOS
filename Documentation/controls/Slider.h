//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** A slider that moves side-to-side.
*/

@implementation Slider

/***************************************************************/

/** This control has the following attributes:

    @param initial_value Initial value of the slider<br>*(float)*
    @param images.thumb /path/to/image.png<br>*(string)*
    @param images.minimum /path/to/image.png<br>*(string)*
    @param images.maximum /path/to/image.png<br>*(string)*
    @param minimum_value Minimum value boundary<br>*(float)*
    @param maximum_value Maximum value boundary<br>*(float)*
    @param images.maximum.capInsets /path/to/image.png<br>*(string)*
    @param images.minimum.capInsets /path/to/image.png<br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param value Current value of the slider<br>*(float)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param value_changed Fires when the value of the slider changes

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param update_slider_value 
 
<pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "sliderTest",
    "function_name": "update_slider_value"
  },
  "set": {
    "value": 0.75
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
  "_id": "sliderTest",
  "_type": "Slider",
  "actions": [
    {
      "on": "value_changed",
      "_type": "Refresh",
      "attributes": {
        "_target": "title"
      }
    }
  ],
  "attributes": {
    "layout_type": "absolute",
    "width": 280,
    "horizontal_alignment": "center",
    "vertical_alignment": "middle"
  }
}
 
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
