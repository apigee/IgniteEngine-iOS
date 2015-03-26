//
//  IXTimer.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/13/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXTimer.h"
#import "IXWeakTimerTarget.h"

// IXTimer Properties
static NSString* const kIXEnabled = @"enabled"; // Default YES
static NSString* const kIXRepeats = @"repeat.enabled"; // Default NO
static NSString* const kIXTimeInterval = @"repeatInterval"; // Default 0.5f. Note: Won't fire if not greater than 0.0f.

// IXTimer Events
static NSString* const kIXTimerFired = @"timerFired";

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
