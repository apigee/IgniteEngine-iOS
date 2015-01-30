//
//  IXTimer.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/13/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//


/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Brandon Shelley
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS NSTimer implementation.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name          | Type      | Description       | Default |
 |---------------|-----------|-------------------|---------|
 | enabled       | *(bool)*  | Enable control    | true    |
 | repeats       | *(bool)*  | Repeat the timer? | false   |
 | time_interval | *(float)* | Repeat frequency  |         |
 

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name  | Type     | Description       |
 |-------|----------|-------------------|
   
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name        | Description                                 |
 |-------------|---------------------------------------------|
 | timer_fired | Event that occurs each time the timer fires |

 ##  <a name="functions">Functions</a>
 
Start timer: *start*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "timerTest",
        "function_name": "start"
      }
    }

Stop timer: *stop*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "timerTest",
        "function_name": "stop"
      }
    }
 
 ##  <a name="example">Example JSON</a> 

 
    {
      "_id": "timerTest",
      "_type": "Timer",
      "actions": [
        {
          "_type": "Alert",
          "attributes": {
            "title": "Timer Fired!"
          },
          "on": "timer_fired"
        }
      ],
      "attributes": {
        "enabled": true,
        "repeats": true,
        "time_interval": 5
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */





#import "IXTimer.h"

#import "IXWeakTimerTarget.h"

// IXTimer Properties
static NSString* const kIXEnabled = @"enabled"; // Default YES
static NSString* const kIXRepeats = @"repeats"; // Default NO
static NSString* const kIXTimeInterval = @"time_interval"; // Default 0.5f. Note: Won't fire if not greater than 0.0f.

// IXTimer Events
static NSString* const kIXTimerFired = @"timer_fired";

// IXTimer Functions
static NSString* const kIXStart = @"start";
static NSString* const kIXStop = @"stop";

@interface IXTimer () <IXWeakTimerTargetDelegate>

@property (nonatomic,strong) IXWeakTimerTarget* weakTimerTarget;

@property (nonatomic,assign,getter = isEnabled) BOOL enabled;
@property (nonatomic,assign,getter = shouldRepeat) BOOL repeat;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,assign) NSTimeInterval timeInterval;

@end

@implementation IXTimer

-(void)dealloc
{
    [_timer invalidate];
}

-(void)buildView
{
    // The Timer control doesnt have a view.

    _weakTimerTarget = [[IXWeakTimerTarget alloc] initWithDelegate:self];
}

-(void)applySettings
{
    [super applySettings];
    
    [self setEnabled:[[self propertyContainer] getBoolPropertyValue:kIXEnabled defaultValue:YES]];
    [self setRepeat:[[self propertyContainer] getBoolPropertyValue:kIXRepeats defaultValue:NO]];
    [self setTimeInterval:[[self propertyContainer] getFloatPropertyValue:kIXTimeInterval defaultValue:0.5f]];
    
    [self startTimer];
}

-(void)startTimer
{
    if( [self isEnabled] && [self timeInterval] > 0.0f )
    {
        [self stopTimer];
        
        NSTimer* timer = [[self weakTimerTarget] createTimerWithInterval:[self timeInterval] repeats:[self shouldRepeat]];
        [self setTimer:timer];
    }
}

-(void)stopTimer
{
    [[self timer] invalidate];
    [self setTimer:nil];
}

-(void)timerFired:(IXWeakTimerTarget*)timerTarget;
{
    [[self actionContainer] performSelectorOnMainThread:@selector(executeActionsForEventNamed:)
                                             withObject:kIXTimerFired
                                          waitUntilDone:YES];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStart] )
    {
        [self startTimer];
    }
    else if( [functionName isEqualToString:kIXStop] )
    {
        [self stopTimer];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
