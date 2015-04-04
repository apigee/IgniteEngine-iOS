//
//  IXWeakTimerTarget.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/24/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXWeakTimerTarget.h"

@implementation IXWeakTimerTarget

-(instancetype)initWithDelegate:(id<IXWeakTimerTargetDelegate>)delegate
{
    self = [super init];
    if( self )
    {
        _delegate = delegate;
    }
    return self;
}

-(void)timerDidFire:(NSTimer*)timer
{
    id<IXWeakTimerTargetDelegate> timerDelegate = [self delegate];
    if( timerDelegate && [timerDelegate respondsToSelector:@selector(timerFired:)] )
    {
        [timerDelegate timerFired:self];
    }
    else
    {
        [timer invalidate];
    }
}

-(NSTimer*)createTimerWithInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval
                                             target:self
                                           selector:@selector(timerDidFire:)
                                           userInfo:nil
                                            repeats:repeats];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    return timer;
}

@end
