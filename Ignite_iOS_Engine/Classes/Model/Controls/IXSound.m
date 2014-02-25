//
//  IXSound.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXSound.h"

#import <AVFoundation/AVFoundation.h>

#import "IXAppManager.h"
#import "NSString+IXAdditions.h"

// Sound Properties
static NSString* const kIXSoundLocation = @"sound_location";
static NSString* const kIXVolume = @"volume";
static NSString* const kIXNumberOfLoops = @"number_of_loops";
static NSString* const kIXAutoPlay = @"auto_play";

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
@property (nonatomic,strong) NSURL* lastSoundURL;
@property (nonatomic,strong) AVAudioPlayer* audioPlayer;
@property (nonatomic,strong) NSString* lastCreationErrorMessage;
@end

@implementation IXSound

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
    
    NSURL* soundURL = [[self propertyContainer] getURLPathPropertyValue:kIXSoundLocation basePath:nil defaultValue:nil];
    if( ![[self lastSoundURL] isEqual:soundURL] )
    {
        [self setLastSoundURL:soundURL];
        
        [self setLastCreationErrorMessage:nil];
        [[self audioPlayer] setDelegate:nil];
        [[self audioPlayer] stop];
        
        NSError* audioPlayerError = nil;
        NSData* soundData = [NSData dataWithContentsOfURL:soundURL];
        [self setAudioPlayer:[[AVAudioPlayer alloc] initWithData:soundData error:&audioPlayerError]];
        if( [self audioPlayer] && audioPlayerError == nil )
        {
            [[self audioPlayer] prepareToPlay];
            [[self audioPlayer] setDelegate:self];
        }
        else
        {
            [self setLastCreationErrorMessage:[audioPlayerError description]];
            if( [[IXAppManager sharedAppManager] appMode] == IXDebugMode )
            {
                NSLog(@"IXSOUND WITH _id:%@ CREATION ERROR: %@",[self ID],[self lastCreationErrorMessage]);
            }
        }
    }
    
    if( [self audioPlayer] )
    {
        CGFloat volume = [[self propertyContainer] getFloatPropertyValue:kIXVolume defaultValue:1.0f];
        CGFloat numberOfLoops = [[self propertyContainer] getFloatPropertyValue:kIXNumberOfLoops defaultValue:0.0f];
        [[self audioPlayer] setVolume:volume];
        [[self audioPlayer] setNumberOfLoops:numberOfLoops];
        
        BOOL autoPlay = [[self propertyContainer] getBoolPropertyValue:kIXAutoPlay defaultValue:YES];
        if( autoPlay && ![[self audioPlayer] isPlaying] )
        {
            [[self audioPlayer] play];
        }
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
        returnValue = [NSString stringFromBOOL:[[self audioPlayer] isPlaying]];
    }
    else if( [propertyName isEqualToString:kIXDuration] )
    {
        returnValue = [NSString stringWithFormat:@"%f",[[self audioPlayer] duration]];
    }
    else if( [propertyName isEqualToString:kIXCurrentTime] )
    {
        returnValue = [NSString stringWithFormat:@"%f",[[self audioPlayer] currentTime]];
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

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[self actionContainer] executeActionsForEventNamed:kIXFinished];
}

@end
