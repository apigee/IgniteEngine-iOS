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

@implementation MediaPicker

/***************************************************************/

/** IXMediaPicker has the following attributes:
 
 @param cameraSource Camera source<ul><li>*rear*</li><li>front</li></ul>
 @param cameraControls.enabled Display default camera UI controls<br><code>bool</code> *TRUE*
 @param source
 
 */

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** IXMediaPicker has the following events:
 
 @param didLoadMedia Fires on did load media
 @param error Fires on error
 
 */

-(void)Events
{
}
/***************************************************************/
/***************************************************************/

/** IXMediaPicker has the following functions:
 
 @param success Fires on success
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 @param present Present picker
 <pre class=""brush: js; toolbar: false;"">
 
 
 
 </pre>
 
 */

-(void)Functions
{
}
/***************************************************************/
/***************************************************************/

/** IXMediaPicker returns the following values:
 
 @param selectedMedia Returns path to selected media<br><code>string</code>
 
 */

-(void)Returns
{
}
/***************************************************************/
/***************************************************************/

/** Go on, try it out!


<pre class="brush: js; toolbar: false;">
{
    "_id": "mediaPickerTest",
    "_type": "MediaPicker",
    "actions": [
        {
            "_type": "Alert",
            "attributes": {
                "title": "Loaded media at [[$self.selectedMedia]]"
            },
            "on": "didLoadMedia"
        }
    ],
    "attributes": {
        "camera": "front",
        "cameraControls.enabled": true,
        "source": "library"
    }
},
{
    "_id": "button",
    "_type": "Button",
    "actions": [
        {
            "_type": "Function",
            "attributes": {
                "_target": "mediaPickerTest",
                "functionName": "present"
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
        "size.w": 200,
        "text": "Pick something.",
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
