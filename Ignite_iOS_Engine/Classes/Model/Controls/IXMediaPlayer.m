//
//  IXVideoControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
 
 Plays media.. audio, video, you name it.
 

 <div id="container">
 <a href="../images/IXMediaPlayer.png" data-imagelightbox="c"><img src="../images/IXMediaPlayer.png" alt=""></a>
 
</div>
 
 */

/*
 *      /Docs
 *
 */

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

    @param controls Style of controls to use<br>*embeddedfullscreennone*
    @param bar.color Color of the player UI<br>*(color)*
    @param bar.height Height of the player UI<br>*(float)*
    @param video URL or /path/to/video.mov<br>*(string)*
    @param auto_play Automatically play?<br>*(bool)*

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


    @param movie_timed_out Fires when the file is inaccessible
    @param movie_stopped Fires on touch
    @param touch_up Fires on touch up inside
 
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


    @param play Play media file
 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

    @param pause Pause media file

 <pre class="brush: js; toolbar: false;">
 
 </pre>


    @param stop Stop media file

 <pre class="brush: js; toolbar: false;">
 
 </pre>


    @param goto Go to time

 <pre class="brush: js; toolbar: false;">
 
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
