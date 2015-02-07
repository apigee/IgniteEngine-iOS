//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Allows you to select media from the device camera or library.
*/

@implementation MediaSource

/***************************************************************/

/** This control has the following attributes:

    @param urce Style of controls to use<br>*cameralibrary*
    @param camera Color of the player UI<br>*frontrear*
    @param show_camera_controls Height of the player UI<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param selected_media The value the knob has been set to<br>*(string)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param did_load_media Fires when the media loads successfully
    @param failed_load_media Fires when the media fails to load

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

   
 @param present_picker Present the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "present_picker"
  }
}
 
 </pre>
 
 @param dismiss_picker Dismiss the media picker view controller.
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "mediaSourceTest",
    "function_name": "dismiss_picker"
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
  "_id": "mediaSourceTest",
  "_type": "MediaSource",
  "actions": [
    {
      "on": "did_load_media",
      "_type": "Alert",
      "attributes": {
        "title": "did_load_media: [[$self.selected_media]]"
      }
    }
  ],
  "attributes": {
    "source": "library"
  }
}
 
 </pre>



*/

-(void)Example
{
}

/***************************************************************/

@end
