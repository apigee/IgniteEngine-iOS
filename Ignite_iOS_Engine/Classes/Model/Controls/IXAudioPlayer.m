//
//  IXSound.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/11/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXAudioPlayer.h"

@import AVFoundation.AVAudioPlayer;

#import "IXAppManager.h"
#import "IXLogger.h"

#import "NSString+IXAdditions.h"

// Sound Properties
IX_STATIC_CONST_STRING kIXSoundLocation = @"audioUrl";
IX_STATIC_CONST_STRING kIXVolume = @"volume";
IX_STATIC_CONST_STRING kIXNumberOfLoops = @"repeatCount";
IX_STATIC_CONST_STRING kIXAutoPlay = @"autoPlay.enabled";
IX_STATIC_CONST_STRING kIXForceSoundReload = @"forceAudioReload.enabled";

// Sound Read-Only Properties
IX_STATIC_CONST_STRING kIXIsPlaying = @"isPlaying";
IX_STATIC_CONST_STRING kIXDuration = @"duration";
IX_STATIC_CONST_STRING kIXCurrentTime = @"now";

IX_STATIC_CONST_STRING kIXSecondsDuration = @"seconds.duration";
IX_STATIC_CONST_STRING kIXSecondsRemaining = @"seconds.remaining";
IX_STATIC_CONST_STRING kIXSecondsElapsed = @"seconds.elapsed";

IX_STATIC_CONST_STRING kIXTimeDuration = @"time.duration";
IX_STATIC_CONST_STRING kIXTimeRemaining = @"time.remaining";
IX_STATIC_CONST_STRING kIXTimeElapsed = @"time.elapsed";

IX_STATIC_CONST_STRING kIXLastCreationError = @"error.message";

// Sound Events
IX_STATIC_CONST_STRING kIXFinished = @"done";

// Sound Functions
IX_STATIC_CONST_STRING kIXPlay = @"play";
IX_STATIC_CONST_STRING kIXPause = @"pause";
IX_STATIC_CONST_STRING kIXStop = @"stop";
IX_STATIC_CONST_STRING kIXGoTo = @"goTo";

// IXMediaPlayer Function parameters
IX_STATIC_CONST_STRING kIXGoToSeconds = @"seconds";

@interface IXAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer* audioPlayer;

@property (nonatomic,strong) NSURL* lastSoundURL;
@property (nonatomic,strong) NSString* lastCreationErrorMessage;

@property (nonatomic,assign) BOOL forceSoundReload;
@property (nonatomic,assign) BOOL shouldAutoPlay;
@property (nonatomic,assign) float volume;
@property (nonatomic,assign) NSInteger numberOfLoops;

@end

@implementation IXAudioPlayer



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
    else if( [functionName compare:kIXGoTo] == NSOrderedSame )
    {
        float seconds = [parameterContainer getFloatPropertyValue:kIXGoToSeconds defaultValue:[[self audioPlayer] currentTime]];
        if( [[self audioPlayer] isPlaying])
        {
            [[self audioPlayer] setCurrentTime:seconds];
        }
        else
        {
            [[self audioPlayer] setCurrentTime:seconds];
        }
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
    
    else if( [propertyName isEqualToString:kIXSecondsDuration] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self audioPlayer] duration]];
    }
    else if( [propertyName isEqualToString:kIXSecondsElapsed] )
    {
        returnValue = [NSString ix_stringFromFloat:[[self audioPlayer] currentTime]];
    }
    else if( [propertyName isEqualToString:kIXSecondsRemaining] )
    {
        NSInteger duration = [[self audioPlayer] duration];
        NSInteger elapsed = [[self audioPlayer] currentTime];
        NSInteger remaining = duration - elapsed;
        returnValue = [NSString ix_stringFromFloat:remaining];
    }
    else if( [propertyName isEqualToString:kIXTimeDuration] )
    {
        NSInteger duration = [[self audioPlayer] duration];
        return [self timeFormatted:duration];
    }
    else if( [propertyName isEqualToString:kIXTimeElapsed] )
    {
        NSInteger currentTime = (int) [[self audioPlayer] currentTime];
        return [self timeFormatted:currentTime];
    }
    else if( [propertyName isEqualToString:kIXTimeRemaining] )
    {
        NSInteger currentTime = (int) [[self audioPlayer] currentTime];
        NSInteger duration = (int) [[self audioPlayer] duration];
        NSInteger remainingTime = duration - currentTime;
        return [self timeFormatted:remainingTime];
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

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    NSString* returnString;
    
    if( hours > 0 )
    {
        returnString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        returnString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
    return returnString;
}

@end