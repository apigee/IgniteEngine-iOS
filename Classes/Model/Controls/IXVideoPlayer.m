//
//  IXVideoControl.m
//  Ignite Engine
//
//  Created by Jeremy Anticouni on 11/16/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXVideoPlayer.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "ALMoviePlayerController.h"

// IXMediaPlayer Attributes
IX_STATIC_CONST_STRING kIXAutoPlayEnabled = @"autoPlay.enabled";
IX_STATIC_CONST_STRING kIXBarColor = @"bar.color";
IX_STATIC_CONST_STRING kIXBarSize = @"bar.size.h";
IX_STATIC_CONST_STRING kIXPlayerControls = @"interface"; //default
IX_STATIC_CONST_STRING kIXVideoUrl = @"videoUrl";

// IXMediaPlayer Attribute Values
IX_STATIC_CONST_STRING kIXDefault = @"default"; //kIXPlayerControls
IX_STATIC_CONST_STRING kIXEmbedded = @"embedded"; //kIXPlayerControls
IX_STATIC_CONST_STRING kIXFullscreen = @"fullscreen"; //kIXPlayerControls
IX_STATIC_CONST_STRING kIXNone = @"none"; //kIXPlayerControls

// IXMediaPlayer Events
IX_STATIC_CONST_STRING kIXPlaybackStopped = @"playbackStopped";
IX_STATIC_CONST_STRING kIXPlaybackTimedOut = @"playbackTimedOut";
IX_STATIC_CONST_STRING kIXTouchUp = @"touchUp";

// IXMediaPlayer Functions
IX_STATIC_CONST_STRING kIXPause = @"pause";
IX_STATIC_CONST_STRING kIXPlay = @"play";
IX_STATIC_CONST_STRING kIXStop = @"stop";
IX_STATIC_CONST_STRING kIXGoTo = @"goTo";

// IXMediaPlayer Function parameters
IX_STATIC_CONST_STRING kIXGoToSeconds = @"seconds";

@interface  IXVideoPlayer() <ALMoviePlayerControllerDelegate>

@property (nonatomic,strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSURL* movieURL;
@property (nonatomic,assign) CGRect lastFrameForMovieControl;
@property (nonatomic,assign) MPMoviePlaybackState lastKnownState;
@property (nonatomic,assign) BOOL didFireStopped;

@end

@implementation IXVideoPlayer

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
    NSString* controlsStyle = [[self attributeContainer] getStringValueForAttribute:kIXPlayerControls defaultValue:kIX_DEFAULT];
    if( [controlsStyle isEqualToString:kIXEmbedded] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleEmbedded];
    }
    else if( [controlsStyle isEqualToString:kIXFullscreen] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleFullscreen];
    }
    else if( [controlsStyle isEqualToString:kIXNone] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleNone];
    }
    else
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleDefault];
    }
    
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[[self attributeContainer] getColorValueForAttribute:kIXBarColor defaultValue:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]]];
    [movieControls setBarHeight:[[self attributeContainer] getFloatValueForAttribute:kIXBarSize defaultValue:30.0f]];
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
    [self setMovieURL:[[self attributeContainer] getURLValueForAttribute:kIXVideoUrl basePath:nil defaultValue:nil]];
    
    if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
    {
        [[self moviePlayer] setContentURL:[self movieURL]];
    }
    
    BOOL autoPlay = [[self attributeContainer] getBoolValueForAttribute:kIXAutoPlayEnabled defaultValue:YES];
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
    [[self actionContainer] executeActionsForEventNamed:kIXPlaybackTimedOut];
}

-(void)moviePlaybackStopped
{
    if( ![self didFireStopped] )
    {
        [self setDidFireStopped:YES];
        [[self actionContainer] executeActionsForEventNamed:kIXPlaybackStopped];
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

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
{
    if( [functionName compare:kIXPlay] == NSOrderedSame )
    {
        if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
        {
            [[self moviePlayer] setContentURL:[self movieURL]];
        }        
        [[self moviePlayer] play];
    }
    else if( [functionName compare:kIXPause] == NSOrderedSame )
    {
        [[self moviePlayer] pause];
    }
    else if( [functionName compare:kIXStop] == NSOrderedSame )
    {
        [[self moviePlayer] stop];
    }
    else if( [functionName compare:kIXGoTo] == NSOrderedSame )
    {
        float seconds = [parameterContainer getFloatValueForAttribute:kIXGoToSeconds defaultValue:[[self moviePlayer] currentPlaybackTime]];
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
