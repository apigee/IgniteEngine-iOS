//
//  Shortcodes.doc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Fingerprint authentication. Hot.
*/

@implementation TouchID

/***************************************************************/

/** This control has the following attributes:

    @param title TouchID title<br>*(string)*

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

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>The following read-only attributes can be read:</p>
 </div>
 </div>

    @param success User authenticated successfully
    @param failed User did not authenticate successfully
    @param cancelled User cancelled the operation
    @param password Dismisses TouchID, allowing user to enter password
    @param unconfigured TouchID is not configured on the device
    @param unavailable TouchID is not available or not supported on the device

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:

 @param authenticate Present TouchID UI
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "speechTest",
    "function_name": "queue_utterance"
  },
  "set": {
    "utterance.sentences": "[[session.text_to_speak]]",
    "utterance.rate": "[[customSlider.value]]"
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
  "_type": "Speech",
  "_id": "speechTest"
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end