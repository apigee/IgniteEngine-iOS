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
  "_id": "MediaPickerTest",
  "_type": "MediaPicker",
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
