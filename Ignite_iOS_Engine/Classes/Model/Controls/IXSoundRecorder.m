//
//  IXSoundRecorder.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXSoundRecorder.h"

#import <AVFoundation/AVFoundation.h>

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
static NSString* const kIXError = @"error";
static NSString* const kIXFinished = @"finished";

@interface IXSoundRecorder () <AVAudioRecorderDelegate>

@property (nonatomic,assign) BOOL recordPermissionGranted;
@property (nonatomic,strong) NSString* lastErrorMessage;

@property (nonatomic,strong) AVAudioRecorder* audioRecorder;
@property (nonatomic,strong) NSURL* recordToLocationURL;
@property (nonatomic,assign) NSTimeInterval recordingDuration;

@end

@implementation IXSoundRecorder

-(void)dealloc
{
    [_audioRecorder setDelegate:nil];
    [_audioRecorder stop];
}

-(void)buildView
{
    // IXSoundRecorder does not have a view.
    
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:YES error:nil];
    [audioSession requestRecordPermission:^(BOOL granted) {
        [self setRecordPermissionGranted:granted];
    }];
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
            [[self actionContainer] executeActionsForEventNamed:kIXError];
        }
    }
    else
    {
        [self setLastErrorMessage:@"ERROR: Record Permission was not granted by user."];
        [[self actionContainer] executeActionsForEventNamed:kIXError];
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
        returnValue = [NSString stringFromBOOL:[self recordPermissionGranted]];
    }
    else if( [propertyName isEqualToString:kIXIsRecording] )
    {
        returnValue = [NSString stringFromBOOL:[[self audioRecorder] isRecording]];
    }
    else if( [propertyName isEqualToString:kIXCurrentTime] )
    {
        returnValue = [NSString stringWithFormat:@"%f",[[self audioRecorder] currentTime]];
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
            [[self actionContainer] executeActionsForEventNamed:kIXError];
            DDLogError(@"ERROR: from %@ in %@ : SOUNDRECORDER CONTROL ID:%@ CREATION ERROR USING URL %@: %@",THIS_FILE,THIS_METHOD,[[self ID] uppercaseString],[[self recordToLocationURL] absoluteString],[self lastErrorMessage]);
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
        [[self actionContainer] executeActionsForEventNamed:kIXFinished];
    }
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [[self actionContainer] executeActionsForEventNamed:kIXFinished];
}

@end
