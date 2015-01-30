//
//  IXVideoControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/28/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name                              | Type                             | Description                         | Default |
 |-----------------------------------|----------------------------------|-------------------------------------|---------|
 | controls                          | *embedded<br>fullscreen<br>none* | Style of controls to use            |         |
 | bar.color                         | *(color)*                        | Color of the player UI              |         |
 | bar.height                        | *(float)*                        | Height of the player UI             |         |
 | video                             | *(string)*                       | URL or /path/to/video.mov           |         |
 | auto_play                         | *(bool)*                         | Automatically play?                 |         |

 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name            | Description                         |
 |-----------------|-------------------------------------|
 | movie_timed_out | Fires when the file is inaccessible |
 | movie_stopped   | Fires on touch                      |
 | touch_up        | Fires on touch up inside            |
 

 ##  <a name="functions">Functions</a>
 
Play media file: *play*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaPlayerTest",
        "function_name": "play"
      }
    }

Pause media file: *pause*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaPlayerTest",
        "function_name": "pause"
      }
    }
 
Stop media file: *stop*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaPlayerTest",
        "function_name": "stop"
      }
    }

 Seek to time: *goto*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "mediaPlayerTest",
        "function_name": "goto",
        "seconds": 42
      }
    }
 
 ##  <a name="example">Example JSON</a> 
 
     
 */
//
//  [/Documentation]
/*  -----------------------------  */


#import "IXMediaPlayer.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"

#import "ALMoviePlayerController.h"

@interface  IXMediaPlayer() <ALMoviePlayerControllerDelegate>

@property (nonatomic,strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSURL* movieURL;
@property (nonatomic,assign) CGRect lastFrameForMovieControl;
@property (nonatomic,assign) MPMoviePlaybackState lastKnownState;
@property (nonatomic,assign) BOOL didFireStopped;

@end

@implementation IXMediaPlayer

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];

    [_moviePlayer setDelegate:nil];
    [_moviePlayer stop];
}

-(void)buildView
{
    [super buildView];
    
    _moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectZero];
    [_moviePlayer setShouldAutoplay:NO];
    [_moviePlayer setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStopped) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
    
    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:_moviePlayer style:ALMoviePlayerControlsStyleNone];
    [_moviePlayer setControls:movieControls];
    
    [[self contentView] addSubview:_moviePlayer.view];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self setLastFrameForMovieControl:rect];
    if( ![[self moviePlayer] isFullscreen] )
    {
        [[self moviePlayer] setFrame:rect];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    ALMoviePlayerControls* movieControls = [[self moviePlayer] controls];
    NSString* controlsStyle = [[self propertyContainer] getStringPropertyValue:@"controls" defaultValue:kIX_DEFAULT];
    if( [controlsStyle isEqualToString:@"embedded"] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleEmbedded];
    }
    else if( [controlsStyle isEqualToString:@"fullscreen"] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleFullscreen];
    }
    else if( [controlsStyle isEqualToString:@"none"] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleNone];
    }
    else
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleDefault];
    }
    
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[[self propertyContainer] getColorPropertyValue:@"bar.color" defaultValue:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]]];
    [movieControls setBarHeight:[[self propertyContainer] getFloatPropertyValue:@"bar.height" defaultValue:30.0f]];
    [movieControls setTimeRemainingDecrements:YES];
    //[movieControls setFadeDelay:2.0];
    //[movieControls setBarHeight:100.f];
    //[movieControls setSeekRate:2.f];
    
    //delay initial load so statusBarOrientation returns correct value
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            //            self.navigationItem.leftBarButtonItem.enabled = YES;
            //            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    });
    
    //THEN set contentURL
    [self setMovieURL:[[self propertyContainer] getURLPathPropertyValue:@"video" basePath:nil defaultValue:nil]];
    
    if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
    {
        [[self moviePlayer] setContentURL:[self movieURL]];
    }
    
    BOOL autoPlay = [[self propertyContainer] getBoolPropertyValue:@"auto_play" defaultValue:YES];
    if( autoPlay )
    {
        if( [[self moviePlayer] playbackState] != MPMoviePlaybackStatePlaying )
        {
            [[self moviePlayer] play];
        }
    }
}

-(void)moviePlayerWillMoveFromWindow
{
    if( [[[self moviePlayer] view] superview] != [self contentView] )
    {
        [[self contentView] addSubview:[[self moviePlayer] view]];
        [[self moviePlayer] setFrame:[self lastFrameForMovieControl]];
    }
}

-(void)movieTimedOut
{
    [[self actionContainer] executeActionsForEventNamed:@"movie_timed_out"];
}

-(void)moviePlaybackStopped
{
    if( ![self didFireStopped] )
    {
        [self setDidFireStopped:YES];
        [[self actionContainer] executeActionsForEventNamed:@"movie_stopped"];
    }
}

-(void)moviePlaybackStateChanged
{
    MPMoviePlaybackState currentPlaybackState = [[self moviePlayer] playbackState];
    if( [self lastKnownState] != currentPlaybackState )
    {
        [self setLastKnownState:currentPlaybackState];
        switch (currentPlaybackState) {
            case MPMoviePlaybackStatePlaying:
                [self setDidFireStopped:NO];
                break;
            default:
                break;
        }
    }
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName compare:@"play"] == NSOrderedSame )
    {
        if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
        {
            [[self moviePlayer] setContentURL:[self movieURL]];
        }        
        [[self moviePlayer] play];
    }
    else if( [functionName compare:@"pause"] == NSOrderedSame )
    {
        [[self moviePlayer] pause];
    }
    else if( [functionName compare:@"stop"] == NSOrderedSame )
    {
        [[self moviePlayer] stop];
    }
    else if( [functionName compare:@"goto"] == NSOrderedSame )
    {
        float seconds = [parameterContainer getFloatPropertyValue:@"seconds" defaultValue:[[self moviePlayer] currentPlaybackTime]];
        if( [[self moviePlayer] playbackState] != MPMoviePlaybackStatePlaying )
        {
            [[self moviePlayer] setInitialPlaybackTime:seconds];
            [[self moviePlayer] setCurrentPlaybackTime:seconds];
        }
        else
        {
            [[self moviePlayer] setCurrentPlaybackTime:seconds];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
