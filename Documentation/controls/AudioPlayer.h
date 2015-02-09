//
//  AudioPlayer.h
//  Documentation
//  Ignite_iOS_Engine
//
//  Created by Jeremy Anticouni on 2/6/2015.
//  Copyright (c) 2015 Ignite. All rights reserved.
//
/** Plays sound. That's about it.
*/

@implementation Audio Player

/***************************************************************/

/** This control has the following attributes:

    @param sound_location http:// or /path/to/sound.mp3<br>*(string)*
    @param volume LOUD?<br>*(float)*
    @param number_of_loops How many times do you want to loop it?<br>*(int)*
    @param auto_play Automatically play the sound?<br>*(bool)*
    @param force_sound_reload Clear cache and load fresh<br>*(bool)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:

 @param is_playing Are we playing anything?<br>*(bool)*
 @param duration Duration of the track<br>*(float)*
 @param current_time Time of playhead<br>*(float)*
 @param last_creation_error Whoopsie?<br>*(string)*

*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param finished Fires when the sound finishes playing

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


 @param play Plays sound file
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundTest",
    "function_name": "play"
  }
}
 
 </pre>
 
 @param pause Pauses sound file
 
 <pre class="brush: js; toolbar: false;">

{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundTest",
    "function_name": "pause"
  }
}
 
 </pre>
 
 @param stop Stops playback
 
 <pre class="brush: js; toolbar: false;">
 
{
  "_type": "Function",
  "on": "touch_up",
  "attributes": {
    "_target": "soundTest",
    "function_name": "stop"
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
  "_id": "soundTest",
  "_type": "Audio",
  "actions": [
    {
      "on": "finished",
      "_type": "Alert",
      "attributes": {
        "title": "Finished",
        "message": "Played sound: /resources/sounds/powerup.caf"
      }
    }
  ],
  "attributes": {
    "sound_location": "/resources/sounds/powerup.caf",
    "number_of_loops": 0,
    "auto_play": false
  }
}
 
</pre>

*/

-(void)Example
{
}

/***************************************************************/

@end
