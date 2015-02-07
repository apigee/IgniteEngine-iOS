//
//  ActionSheet.ixdoc
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

/** Record audio from the device microphone.
*/

@implementation SoundRecorder

/***************************************************************/

/** This control has the following attributes:

    @param record_to_location /path/to/save/recording.mp3<br>*(string)*
    @param duration (!) Not sure.. *(default: -1)*<br>*(float)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param record_permission_granted Has the user granted access to the microphone?<br>*(bool)*
 @param is_recording Are we recording?<br>*(bool)*
 @param current_time Current duration of recording<br>*(float)*
 @param last_error_message Whoopsie?<br>*(string)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param finished Fires when the recording is finished
    @param error Fires when an error occurs

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param start_recording
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundRecorderTest",
    "function_name": "start_recording"
  }
}
 
 </pre>
 
 @param pause_recording
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundRecorderTest",
    "function_name": "pause_recording"
  }
}
 
 </pre>
 
 @param resume_recording
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundRecorderTest",
    "function_name": "resume_recording"
  }
}
 
 </pre>
 
 @param stop_recording
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundRecorderTest",
    "function_name": "stop_recording"
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
  "_id": "soundRecorderTest",
  "_type": "SoundRecorder",
  "actions": [
    {
      "on": "finished",
      "_type": "Alert",
      "attributes": {
        "title": "Finished",
        "message": "Recorded sound: [[$self.record_to_location]]"
      }
    }
  ],
  "attributes": {
    "record_to_location": "docs://recording.mp3"
  }
}
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
