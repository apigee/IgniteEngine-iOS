//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** It's a button. Put text on it and trigger an action, maybe even add an image.
*/

@implementation Button

/***************************************************************/

/** This control has the following attributes:

    @param text The text displayed<br>*(string)*
    @param text.color The text color *(default: #ffffff)*<br>*(color)*
"    @param font The text font name and size (font:size) 
See http://iosfonts.com/ for available fonts. *(default: HelveticaNeue:20)*<br>*(string)*"
    @param background.color The background color<br>*(color)*
    @param icon The icon image path<br>*(string)*
    @param icon.tintColor The icon tint color<br>*(color)*
    @param touch.text The text displayed on touch events<br>*(string)*
    @param touch.font The text font displayed on touch events<br>*(string)*
    @param touch.text.color The text color on touch events<br>*(color)*
    @param touch.background.color The background color on touch events<br>*(color)*
    @param touch.icon The icon image path on touch events<br>*(string)*
    @param touch.icon.tintColor The icon tint color on touch events<br>*(color)*
    @param touch.alpha The button alpha on touch events<br>*(float)*
    @param disabled.text The text displayed when button is disabled<br>*(string)*
    @param disabled.font The font when button is disabled<br>*(string)*
    @param disabled.text.color The text color when button is disabled<br>*(color)*
    @param disabled.background.color The background color when button is disabled<br>*(color)*
    @param disabled.icon The icon displayed when button is disabled<br>*(string)*
    @param disabled.icon.tintColor The icon tint color when button is disabled<br>*(color)*
    @param disabled.alpha The button alpha when button is disabled<br>*(float)*
    @param darkens_image_on_touch Darkens image on touch events *(default: FALSE)*<br>*(bool)*
    @param touch.duration The touch duration to trigger a touch event *(default: 0.4)*<br>*(float)*
    @param touch_up.duration The touch duration to trigger a touch_up event *(default: 0.4)*<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param touch Fires when the control is touched
    @param touch_up Fires when the control touch is released

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
 {
    "_id": "button",
    "_type": "Button",
    "actions": [
      {
        "_type": "Alert",
        "on": "touch_up",
        "attributes": {
          "title": "touch_up",
          "message": "You touched the button!"
        }
      }
    ],
    "attributes": {
      "width": 100,
      "height": 50,
      "text.color": "6c6c6c",
      "layout_type": "absolute",
      "background.color": "cdcdcd",
      "touch.text.color": "6c6c6c50",
      "horizontal_alignment": "center",
      "vertical_alignment": "middle",
      "touch.background.color": "cdcdcd",
      "border.radius": 0,
      "text": "Hi."
    }
  }
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
