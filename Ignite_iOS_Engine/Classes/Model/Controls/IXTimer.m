//
//  IXTimer.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/13/14.
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
 
 Native iOS NSTimer implementation
 

 <div id="container">
 <a href="../images/IXTimer.png" data-imagelightbox="c"><img src="../images/IXTimer.png" alt=""></a>
 
</div>
 
 */

/*
 *      /Docs
 *
 */

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

    @param enabled Enable control *(default: TRUE)*<br>*(bool)*
    @param repeats Repeat the timer? *(default: FALSE)*<br>*(bool)*
    @param time_interval Repeat frequency<br>*(float)*

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


    @param timer_fired Event that occurs each time the timer fires

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


    @param start 
 <pre class="brush: js; toolbar: false;">
 
 </pre>


    @param stop 
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
