//
//  IXVideoControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*
 
 CONTROL
 /--------------------/
 - TYPE : "IXMediaPlayerControl"
 - DESCRIPTION: "IXVideoControl Description."
 /--------------------/
 - PROPERTIES
 /--------------------/
 * name=""        default=""               type="___"
 /--------------------/
 - EVENTS
 /--------------------/
 * name="share_done"
 * name="share_cancelled"
 /--------------------/
 - Example
 /--------------------/

 {
 "type": "MediaPlayer",
 "attributes": {
 "id": "myLinkText",
 "layout_type": "relative",
 "height": "180",
 "width": "320",
 "controls":"default",
 "bar":
 {
 "height":"50",
 "color": "#00FF0050"
 },
 "auto_play":true,
 "video": "http://archive.org/download/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto-HawaiianHoliday1937-Video.mp4"
 }
 },
 
 /--------------------/
 - Changelog
 /--------------------/
 
 /--------------------/
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

@end

@implementation IXMediaPlayer

-(void)dealloc
{
    [_moviePlayer setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectZero];
    [_moviePlayer setDelegate:self];
    
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
    NSString* controlsStyle = [[self propertyContainer] getStringPropertyValue:@"controls" defaultValue:@"default"];
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
    [movieControls setBarColor:[[self propertyContainer] getColorPropertyValue:@"bar.color" defaultValue:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]]];
    [movieControls setBarHeight:[[self propertyContainer] getFloatPropertyValue:@"bar.height" defaultValue:50.0f]];
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
        float seconds = [[self propertyContainer] getFloatPropertyValue:@"seconds" defaultValue:[[self moviePlayer] currentPlaybackTime]];
        [[self moviePlayer] setCurrentPlaybackTime:seconds];
//            [self.moviePlayer setContentURL:[self movieURL]];
//            [self.moviePlayer stop];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
