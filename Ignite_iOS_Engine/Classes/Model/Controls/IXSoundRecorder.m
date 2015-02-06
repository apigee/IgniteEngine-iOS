//
//  IXSoundRecorder.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     42034
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/**
 
 Record audio from the device microphone.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXSoundRecorder_0.png" data-imagelightbox="c"><img src="../images/IXSoundRecorder_0.png"></a></li>
 <li><a href="../images/IXSoundRecorder_1.png" data-imagelightbox="c"><img src="../images/IXSoundRecorder_1.png"></a></li>
 <li><a href="../images/IXSoundRecorder_2.png" data-imagelightbox="c"><img src="../images/IXSoundRecorder_2.png"></a></li>
 </ul>
</div>
 
*/

/*
 *      /Docs
 *
*/


#import "IXSoundRecorder.h"

@import AVFoundation.AVAudioSession;
@import AVFoundation.AVAudioRecorder;

#import "NSString+IXAdditions.h"

#import "IXAppManager.h"
#import "IXPathHandler.h"
#import "IXLogger.h"

// IXSoundRecorder Properties
static NSString* const kIXRecordToLocation = @"record_to_location";
static NSString* const kIXDuration = @"duration";

// IXSoundRecorder Read-Only Properties
static NSString* const kIXRecordPermissionGranted = @"record_permission_granted";
static NSString* const kIXLastErrorMessage = @"last_error_message";
static NSString* const kIXCurrentTime = @"current_time";
static NSString* const kIXIsRecording = @"is_recording";

// IXSoundRecorder Functions
static NSString* const kIXStartRecording = @"start_recording";
static NSString* const kIXPauseRecording = @"pause_recording";
static NSString* const kIXResumeRecording = @"resume_recording";
static NSString* const kIXStopRecording = @"stop_recording";

// IXSoundRecorder Events
// kIX_FINISHED -> Fires when the recording has finished.
// kIX_ERROR    -> Fires when the sound recorder control throws an error when "record_permission_granted" is false as well as when "record_to_location" is an invalid path.

@interface IXSoundRecorder () <AVAudioRecorderDelegate>

@property (nonatomic,assign,readonly) BOOL recordPermissionGranted;
@property (nonatomic,strong) NSString* lastErrorMessage;

@property (nonatomic,strong) AVAudioRecorder* audioRecorder;
@property (nonatomic,strong) NSURL* recordToLocationURL;
@property (nonatomic,assign) NSTimeInterval recordingDuration;

@end

@implementation IXSoundRecorder

/*
* Docs
*
*/

/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-warning">
 <i class="ti-panel"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Attributes</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

    @param record_to_location /path/to/save/recording.mp3<br>*(string)*
    @param duration (!) Not sure.. *(default: -1)*<br>*(float)*

*/

-(void)attributes
{
}
/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-info">
 <i class="ti-loop"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Returns</h3>
 <p>This has the following attributes:</p>
 </div>
 </div>

 @param record_permission_granted Has the user granted access to the microphone?<br>*(bool)*
 @param is_recording Are we recording?<br>*(bool)*
 @param current_time Current duration of recording<br>*(float)*
 @param last_error_message Whoopsie?<br>*(string)*

*/

-(void)returns
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-success">
 <i class="ti-pulse"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Events</h3>
 <p>This control fires the following events:</p>
 </div>
 </div>


    @param finished Fires when the recording is finished
    @param error Fires when an error occurs

*/

-(void)events
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-danger">
 <i class="ti-direction"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Functions</h3>
 <p>This control supports the following functions:</p>
 </div>
 </div>


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

-(void)functions
{
}

/***************************************************************/
/***************************************************************/

/** <div class="ui-bullet">
 <div class="btn-icon btn-icon-round btn-icon-lg bg-primary">
 <i class="ti-shortcode"></i>
 </div>
 <div class="ui-bullet-content">
 <h3>Example</h3>
 <p>Go on, try it out!</p>
 </div>
 </div>


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

-(void)example
{
}

/***************************************************************/

/*
* /Docs
*
*/

-(void)dealloc
{
    [_audioRecorder setDelegate:nil];
    [_audioRecorder stop];
}

-(void)buildView
{
    // IXSoundRecorder does not have a view.
}

-(BOOL)recordPermissionGranted
{
    return [[IXAppManager sharedAppManager] accessToMicrophoneGranted];
}

-(void)applySettings
{
    [super applySettings];
    
    if( [self recordPermissionGranted] )
    {
        [self setRecordToLocationURL:nil];
        
        NSURL* recordToLocation = [[self propertyContainer] getURLPathPropertyValue:kIXRecordToLocation basePath:nil defaultValue:nil];
        if( [IXPathHandler pathIsLocal:[recordToLocation absoluteString]] )
        {
            [self setRecordToLocationURL:recordToLocation];
            [self setRecordingDuration:[[self propertyContainer] getFloatPropertyValue:kIXDuration defaultValue:-1.0f]];
        }
        else
        {
            [self setLastErrorMessage:[NSString stringWithFormat:@"ERROR: Property named %@ must be a local path.",kIXRecordToLocation]];
            [[self actionContainer] executeActionsForEventNamed:kIX_ERROR];
        }
    }
    else
    {
        [self setLastErrorMessage:@"ERROR: Record Permission was not granted by user."];
        [[self actionContainer] executeActionsForEventNamed:kIX_ERROR];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartRecording] )
    {
        [self startRecording];
    }
    else if( [functionName isEqualToString:kIXPauseRecording] )
    {
        [self pauseRecording];
    }
    else if( [functionName isEqualToString:kIXResumeRecording] )
    {
        [self resumeRecording];
    }
    else if( [functionName isEqualToString:kIXStopRecording] )
    {
        [self stopRecording];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXRecordPermissionGranted] )
    {
        returnValue = [NSString ix_stringFromBOOL:[self recordPermissionGranted]];
    }
    else if( [propertyName isEqualToString:kIXIsRecording] )
    {
        returnValue = [NSString ix_stringFromBOOL:[[self audioRecorder] isRecording]];
    }
    else if( [propertyName isEqualToString:kIXCurrentTime] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self audioRecorder] currentTime]];
    }
    else if( [propertyName isEqualToString:kIXLastErrorMessage] )
    {
        returnValue = [self lastErrorMessage];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)startRecording
{
    [self stopRecording];
    
    if( [self recordToLocationURL] )
    {
        NSError* error = nil;
        AVAudioRecorder* audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self recordToLocationURL]
                                                                     settings:nil
                                                                        error:&error];
        
        if( audioRecorder == nil || error != nil )
        {
            [self setLastErrorMessage:[NSString stringWithFormat:@"ERROR: Problem Creating AVAudioRecorder using URL %@: \n\n%@",[[self recordToLocationURL] absoluteString],[error description]]];
            [[self actionContainer] executeActionsForEventNamed:kIX_ERROR];
            IX_LOG_ERROR(@"ERROR: from %@ in %@ : SOUNDRECORDER CONTROL ID:%@ CREATION ERROR USING URL %@: %@",THIS_FILE,THIS_METHOD,[[self ID] uppercaseString],[[self recordToLocationURL] absoluteString],[self lastErrorMessage]);
        }
        else
        {
            [audioRecorder setDelegate:self];
            
            if( [self recordingDuration] <= 0.0f )
            {
                [audioRecorder record];
            }
            else
            {
                [audioRecorder recordForDuration:[self recordingDuration]];
            }
            
            [self setAudioRecorder:audioRecorder];
        }
    }
}

-(void)pauseRecording
{
    [[self audioRecorder] pause];
}

-(void)resumeRecording
{
    [[self audioRecorder] record];
}

-(void)stopRecording
{
    BOOL audioRecorderWasRecording = [[self audioRecorder] isRecording];
    [[self audioRecorder] setDelegate:nil];
    [[self audioRecorder] stop];
    [self setAudioRecorder:nil];
    
    if( audioRecorderWasRecording )
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_FINISHED];
    }
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [[self actionContainer] executeActionsForEventNamed:kIX_FINISHED];
}

@end
