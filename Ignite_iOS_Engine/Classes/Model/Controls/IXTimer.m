//
//  IXTimer.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/13/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXTimer.h"

// IXTimer Properties
static NSString* const kIXEnabled = @"enabled"; // Default YES
static NSString* const kIXRepeats = @"repeats"; // Default NO
static NSString* const kIXTimeInterval = @"time_interval"; // Default 0.5f. Note: Won't fire if not greater than 0.0f.

// IXTimer Events
static NSString* const kIXTimerFired = @"timer_fired";

// IXTimer Functions
static NSString* const kIXStart = @"start";
static NSString* const kIXStop = @"stop";

@interface IXWeakTimerTarget : NSObject

@property (nonatomic,weak) IXTimer* timerControl;
@property (nonatomic,assign) NSString* selectorName;

@end

@implementation IXWeakTimerTarget

-(instancetype)initWithTarget:(IXTimer*)timer selectorName:(NSString*)selectorName
{
    self = [super init];
    if( self )
    {
        _timerControl = timer;
        _selectorName = selectorName;
    }
    return self;
}

-(void)timerDidFire:(NSTimer*)timer
{
    if([self timerControl] && [self selectorName])
    {
        SEL selector = NSSelectorFromString([self selectorName]);
        IMP imp = [[self timerControl] methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func([self timerControl], selector);
    }
    else
    {
        [timer invalidate];
    }
}

@end

@interface IXTimer ()

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

    _weakTimerTarget = [[IXWeakTimerTarget alloc] initWithTarget:self selectorName:@"handleTimer"];
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
        
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:[self timeInterval]
                                                        target:[self weakTimerTarget]
                                                      selector:@selector(timerDidFire:)
                                                      userInfo:nil
                                                       repeats:[self shouldRepeat]]];
    }
}

-(void)stopTimer
{
    [[self timer] invalidate];
    [self setTimer:nil];
}

-(void)handleTimer
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
