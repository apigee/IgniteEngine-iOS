//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Renders an image. Supports nifty blurs, real-time color overlay and even animated GIFs.
*/

@implementation Image

/***************************************************************/

/** This control has the following attributes:


    @param images.default /path/to/image.png<br>*(string)*
    @param images.default.tintColor Color to overlay transparent png<br>*(color)*
    @param images.default.blur.radius Blur image<br>*(float)*
    @param images.default.blur.tintColor Blur tint<br>*(color)*
    @param images.default.blur.saturation Blur saturation<br>*(float)*
    @param images.default.force_refresh Force image to reload when enters view<br>*(bool)*
    @param images.height.max Maximum height of image<br>*(int)*
    @param images.width.max Maximum width of image<br>*(int)*
    @param gif_duration Duration of GIF (pronounced JIF) animation<br>*(float)*
    @param flip_horizontal Flip image horizontally *(default: FALSE)*<br>*(bool)*
    @param flip_vertical Flip image vertically *(default: FALSE)*<br>*(bool)*
    @param rotate Rotate image in degrees<br>*(int)*
    @param image.binary Binary data of image file<br>*(string)*
    @param images.default.resize Dynamically resize image using imageMagick<br>*(special)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param is_animating Is it animating?<br>*(bool)*
 @param image.height Actual height of image<br>*(int)*
 @param image.width Actual width of image<br>*(int)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param images_default_loaded Fires when the image loads successfully
    @param images_default_failed Fires when the image fails to load

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param start_animation Starts a GIF animation
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "imageTest",
    "function_name": "start_animation"
  }
}
 
 </pre>

    @param restart_animation Restarts GIF animation
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "imageTest",
    "function_name": "restart_animation"
  }
}
 
 </pre>

    @param stop_animation Stops GIF animation
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "imageTest",
    "function_name": "stop_animation"
  }
}
 
 </pre>

    @param load_last_photo Loads the most recent photo from device Camera Roll
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "imageTest",
    "function_name": "load_last_photo"
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
  "_id": "imageTest",
  "_type": "Image",
  "actions": [
    {
      "_type": "Alert",
      "on": "touch_up",
      "attributes": {
        "title": "touch_up",
        "message": "Sized to [[$self.actual.width]]pt x [[$self.actual.height]]pt."
      }
    }
  ],
  "attributes": {
    "images.width.max": "100%",
    "images.default": "/images/bgs/storage_wars.jpg",
    "text.color": "6c6c6c",
    "images.default.blur.radius": 0,
    "layout_type": "absolute",
    "vertical_alignment": "middle",
    "horizontal_alignment": "center"
  }
}
 
 </pre>


*/

-(void)Example
{
}

/***************************************************************/

@end
