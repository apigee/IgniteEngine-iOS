//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Calls upon the device camera to capture an image.
*/

@implementation Camera : BaseControl

/***************************************************************/

/** Camera has the following attributes:
 
 @param autoStart.enabled Automatically present camera view controller<br><code>bool</code> *TRUE*
 @param autoSave.enabled Automatically save image<br><code>bool</code> *TRUE*
 @param cameraSource Camera source<ul><li>*rear*</li><li>front</li></ul>
 @param captureDelay Capture delay<br><code>float</code>
 @param size.h Height of camera capture view<br><code>float</code>
 @param resizeMask Resize mask<br><code>float</code>
 @param size.w Width of camera capture view<br><code>float</code>
 @param capturedImage <br><code>string</code>
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** Camera has the following events:
 
 @param didCaptureImage Fires when image captured
 @param didSaveImage Fires when image saved
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** Camera has the following functions:
 
 @param capture Capture image
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param restart Restart camera view
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param start Start recording
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param stop Stop recording
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** Camera returns the following values:
 
 */

-(void)Returns
{
}
/***************************************************************/




/***************************************************************/

/** This control supports the following functions:


 @param start Presents the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "start"
  }
}
 </pre>

 @param restart Restarts the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "restart"
  }
}
 </pre>
 
  @param stop Dismisses the Camera view controller
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "stop"
  }
}
 </pre>

  @param capture_image Captures + saves the image.
<pre class="brush: js; toolbar: false;">
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "cameraTest",
    "function_name": "capture_image"
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
  "_id": "cameraTest",
  "_type": "Camera",
  "actions": [
    {
      "on": "did_capture_image",
      "_type": "Alert",
      "attributes": {
        "title": "did_capture_image"
      }
    },
    {
      "on": "did_finish_saving_capture",
      "_type": "Alert",
      "attributes": {
        "title": "did_finish_saving_capture"
      }
    }
  ],
  "attributes": {
    "camera": "rear",
    "height": "100%",
    "width": "100%"
  }
}
 
 </pre>
 

*/

-(void)Example
{
}

/***************************************************************/

@end
