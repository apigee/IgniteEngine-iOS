//
//  IXSound.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
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
 
 Plays sound. That's about it.
 

 <div id="container">
 <ul>
 <li><a href="../images/IXSound_0.png" data-imagelightbox="c"><img src="../images/IXSound_0.png"></a></li>
 <li><a href="../images/IXSound_1.png" data-imagelightbox="c"><img src="../images/IXSound_1.png"></a></li>
 <li><a href="../images/IXSound_2.png" data-imagelightbox="c"><img src="../images/IXSound_2.png"></a></li>
 </ul>
</div>
 
*/

/*
 *      /Docs
 *
*/

#import "IXSound.h"

@import AVFoundation.AVAudioPlayer;

#import "IXAppManager.h"
#import "IXLogger.h"

#import "NSString+IXAdditions.h"

// Sound Properties
static NSString* const kIXSoundLocation = @"sound_location";
static NSString* const kIXVolume = @"volume";
static NSString* const kIXNumberOfLoops = @"number_of_loops";
static NSString* const kIXAutoPlay = @"auto_play";
static NSString* const kIXForceSoundReload = @"force_sound_reload";

// Sound Read-Only Properties
static NSString* const kIXIsPlaying = @"is_playing";
static NSString* const kIXDuration = @"duration";
static NSString* const kIXCurrentTime = @"current_time";
static NSString* const kIXLastCreationError = @"last_creation_error";

// Sound Events
static NSString* const kIXFinished = @"finished";

// Sound Functions
static NSString* const kIXPlay = @"play";
static NSString* const kIXPause = @"pause";
static NSString* const kIXStop = @"stop";

@interface IXSound () <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer* audioPlayer;

@property (nonatomic,strong) NSURL* lastSoundURL;
@property (nonatomic,strong) NSString* lastCreationErrorMessage;

@property (nonatomic,assign) BOOL forceSoundReload;
@property (nonatomic,assign) BOOL shouldAutoPlay;
@property (nonatomic,assign) float volume;
@property (nonatomic,assign) NSInteger numberOfLoops;

@end

@implementation IXSound

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

    @param sound_location http:// or /path/to/sound.mp3<br>*(string)*
    @param volume LOUD?<br>*(float)*
    @param number_of_loops How many times do you want to loop it?<br>*(int)*
    @param auto_play Automatically play the sound?<br>*(bool)*
    @param force_sound_reload Clear cache and load fresh<br>*(bool)*

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

 @param is_playing Are we playing anything?<br>*(bool)*
 @param duration Duration of the track<br>*(float)*
 @param current_time Time of playhead<br>*(float)*
 @param last_creation_error Whoopsie?<br>*(string)*

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


    @param finished Fires when the sound finishes playing

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
  "_id": "soundTest",
  "_type": "Sound",
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
    [_audioPlayer setDelegate:nil];
    [_audioPlayer stop];
}

-(void)buildView
{
    // Sound has no view.
}

-(void)applySettings
{
    [super applySettings];
    
    [self setVolume:[[self propertyContainer] getFloatPropertyValue:kIXVolume defaultValue:1.0f]];
    [self setNumberOfLoops:[[self propertyContainer] getIntPropertyValue:kIXNumberOfLoops defaultValue:0]];
    [self setForceSoundReload:[[self propertyContainer] getBoolPropertyValue:kIXForceSoundReload defaultValue:NO]];

    NSURL* soundURL = [[self propertyContainer] getURLPathPropertyValue:kIXSoundLocation basePath:nil defaultValue:nil];
    if( ![[self lastSoundURL] isEqual:soundURL] || [self audioPlayer] == nil || [self forceSoundReload] )
    {
        [self setLastSoundURL:soundURL];
        [self setShouldAutoPlay:[[self propertyContainer] getBoolPropertyValue:kIXAutoPlay defaultValue:YES]];

        [self setLastCreationErrorMessage:nil];
        [[self audioPlayer] setDelegate:nil];
        [[self audioPlayer] stop];
        
        [self createAudioPlayer];
    }
    
    if( [self audioPlayer] )
    {
        [self applyAudioPlayerSettings];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXPlay] )
    {
        [[self audioPlayer] play];
    }
    else if( [functionName isEqualToString:kIXPause] )
    {
        [[self audioPlayer] pause];
    }
    else if( [functionName isEqualToString:kIXStop] )
    {
        [[self audioPlayer] stop];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXIsPlaying] )
    {
        returnValue = [NSString ix_stringFromBOOL:[[self audioPlayer] isPlaying]];
    }
    else if( [propertyName isEqualToString:kIXDuration] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self audioPlayer] duration]];
    }
    else if( [propertyName isEqualToString:kIXCurrentTime] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self audioPlayer] currentTime]];
    }
    else if( [propertyName isEqualToString:kIXLastCreationError] )
    {
        returnValue = [self lastCreationErrorMessage];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)createAudioPlayer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* soundData = [[NSData alloc] initWithContentsOfURL:[self lastSoundURL]];
        
        NSError* audioPlayerError = nil;
        [self setAudioPlayer:[[AVAudioPlayer alloc] initWithData:soundData error:&audioPlayerError]];
        if( [self audioPlayer] && !audioPlayerError )
        {
            [self applyAudioPlayerSettings];
            [[self audioPlayer] prepareToPlay];
            [[self audioPlayer] setDelegate:self];
        }
        else
        {
            if( audioPlayerError )
            {
                [self setLastCreationErrorMessage:[audioPlayerError description]];
            }
            else
            {
                if( !soundData )
                {
                    [self setLastCreationErrorMessage:[NSString stringWithFormat:@"No sound data found at path: \n %@.",[[self lastSoundURL] absoluteString]]];
                }
            }
            
            IX_LOG_ERROR(@"ERROR: from %@ in %@ : SOUND CONTROL ID:%@ CREATION ERROR: %@",THIS_FILE,THIS_METHOD,[[self ID] uppercaseString],[self lastCreationErrorMessage]);
        }
        
        IX_dispatch_main_sync_safe(^{
            if( [self shouldAutoPlay] && ![[self audioPlayer] isPlaying] )
            {
                [[self audioPlayer] play];
            }
        });
    });
}

-(void)applyAudioPlayerSettings
{
    [[self audioPlayer] setVolume:[self volume]];
    [[self audioPlayer] setNumberOfLoops:[self numberOfLoops]];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[self actionContainer] executeActionsForEventNamed:kIXFinished];
}

@end
