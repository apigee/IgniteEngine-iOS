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

/** This control has the following attributes:

    @param initally_selected Should the toggle be selected by default? *(default: FALSE)*<br>*bool*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param is_on Is the toggle on?<br>*(bool)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:
*/

-(void)Events
{
}


/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param toggle Toggle the toggle
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText"
  }
}
 
 </pre>
 
 @param toggle_on Turn the toggle on
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText",
    "function_name":"toggle_on"
  }
}
 
 </pre>
 
 @param toggle_off Turn the toggle off
 
 <pre class="brush: js; toolbar: false;">
 
{
  "on": "touch_up",
  "_type": "Function",
  "attributes": {
    "_target": "toggleText",
    "function_name":"toggle_off"
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
  "_id": "toggleTest",
  "_type": "Toggle",
  "attributes": {
    "layout_type": "absolute",
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
