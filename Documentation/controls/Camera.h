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

/** Go on, try it out!


 <pre class="brush: js; toolbar: false;">
{
    "_id": "cameraTest",
    "_type": "Camera",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "Captured!"
            },
            "on": "didCaptureImage"
        },
        {
            "_type": "Alert",
            "attributes": {
                "title": "Saved!"
            },
            "on": "didSaveImage"
        }
    ],
    "attributes": {
        "camera": "rear",
        "size.h": "100%",
        "size.w": "100%"
    }
},
{
    "_id": "button",
    "_type": "Button",
    "actions": [
        {
            "_type": "Function",
            "attributes": {
                "_target": "cameraTest",
                "functionName": "capture"
            },
            "on": "touchUp"
        }
    ],
    "attributes": {
        "align.h": "center",
        "align.v": "middle",
        "bg.color": "cdcdcd",
        "border.radius": 0,
        "color": "6c6c6c",
        "layoutType": "absolute",
        "size.h": 50,
        "size.w": 150,
        "text": "Capture image.",
        "touch.bg.color": "cdcdcd",
        "touch.color": "6c6c6c50"
    }
}
 </pre>
 

*/

-(void)Example
{
}

/***************************************************************/

@end
