//
//  IXVideoControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16.
//  Copyright (c) 2013 All rights reserved.
//

/*
 
 WIDGET
 /--------------------/
 - TYPE : "IXVideoControl"
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
 "type": "Video",
 "properties": {
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


@interface  IXMediaPlayer()

@property (nonatomic, strong) ALMoviePlayerController *moviePlayer;
@property NSInteger *controls;


@end

@implementation IXMediaPlayer



-(void)buildView
{
    [super buildView];

}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    
    //    self.moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:320.0f], [[self propertyContainer] getFloatPropertyValue:@"height" defaultValue:180.0f])];
    // [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:320.0f]
    
    // Do any additional setup after loading the view.
    
    //create a player
    self.moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, [[self propertyContainer] getFloatPropertyValue:@"width" defaultValue:320.0f], [[self propertyContainer] getFloatPropertyValue:@"height" defaultValue:180.0f])];
    self.moviePlayer.view.alpha = 1.0f;
    self.moviePlayer.delegate = self; //IMPORTANT!
    
    // Set the controls style
    /*
     embedded
    fullscreen
    default
    none
    */
    
    NSString* controlsStyle = [[self propertyContainer] getStringPropertyValue:@"controls" defaultValue:@"default"];
    
    if([controlsStyle compare:@"embedded"] == NSOrderedSame)
    {
        _controls = ALMoviePlayerControlsStyleEmbedded;
    }
    else if([controlsStyle compare:@"fullscreen"] == NSOrderedSame)
    {
        _controls = ALMoviePlayerControlsStyleFullscreen;
    }
    else if([controlsStyle compare:@"none"] == NSOrderedSame)
    {
        _controls = ALMoviePlayerControlsStyleNone;
    }
    else
    {
        _controls = ALMoviePlayerControlsStyleDefault;
    }
    
    
    
    //create the controls
    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:_controls];
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[[self propertyContainer] getColorPropertyValue:@"bar.color" defaultValue:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]]];
    [movieControls setBarHeight:[[self propertyContainer] getFloatPropertyValue:@"bar.height" defaultValue:50.0f]];
    [movieControls setTimeRemainingDecrements:YES];
    
    //[movieControls setFadeDelay:2.0];
    //[movieControls setBarHeight:100.f];
    //[movieControls setSeekRate:2.f];
    
    //assign controls
    [self.moviePlayer setControls:movieControls];
    [[self contentView] addSubview:_moviePlayer.view];

    //THEN set contentURL
    
    
    //delay initial load so statusBarOrientation returns correct value
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            //            self.navigationItem.leftBarButtonItem.enabled = YES;
            //            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    });
    
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    
    if( _moviePlayer != nil )
    {
        if( [functionName compare:@"play"] == NSOrderedSame )
        {
            NSLog(@"play, bitches!");
            [self.moviePlayer setContentURL:[NSURL URLWithString:[[self propertyContainer] getStringPropertyValue:@"video" defaultValue:@""]]];
        }
        if( [functionName compare:@"pause"] == NSOrderedSame )
        {
            NSLog(@"pause, bitches!");
            [self.moviePlayer pause];
        }
        if( [functionName compare:@"stop"] == NSOrderedSame )
        {
            NSLog(@"stop, bitches!");
            [self.moviePlayer stop];
        }
        if( [functionName compare:@"goto"] == NSOrderedSame )
        {
            NSLog(@"goto, bitches!");
            NSInteger *seconds = [[self propertyContainer] getIntPropertyValue:@"seconds" defaultValue:@"0"];
            self.moviePlayer.currentPlaybackTime = 30;
            [self.moviePlayer setContentURL:[NSURL URLWithString:[[self propertyContainer] getStringPropertyValue:@"video" defaultValue:@""]]];
            [self.moviePlayer stop];
        }

    }
}

@end
