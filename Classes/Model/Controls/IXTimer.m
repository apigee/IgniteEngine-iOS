//
//  IXTimer.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/13/14.
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
    
    [self setEnabled:[[self attributeContainer] getBoolValueForAttribute:kIXEnabled defaultValue:YES]];
    [self setRepeat:[[self attributeContainer] getBoolValueForAttribute:kIXRepeats defaultValue:NO]];
    [self setTimeInterval:[[self attributeContainer] getFloatValueForAttribute:kIXTimeInterval defaultValue:0.5f]];
    
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
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
