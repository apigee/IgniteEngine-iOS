//
//  IXControlContentView.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/22/13.
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

#import "IXControlContentView.h"
#import "IXAppManager.h"
#import "IXLogger.h"

@interface IXControlContentView ()

@property (nonatomic,strong) NSArray* tapGestureRecognizers;
@property (nonatomic,strong) NSArray* swipeGestureRecognizers;
@property (nonatomic,strong) UILongPressGestureRecognizer* longPressRecognizer;
@property (nonatomic,strong) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property (nonatomic,strong) UIPanGestureRecognizer* panGestureRecognizer;

@end

@implementation IXControlContentView

-(id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame viewTouchDelegate:nil];
}

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<IXControlContentViewTouchDelegate>)touchDelegate
{
    self = [super initWithFrame:frame];
    if( self != nil )
    {
        _controlContentViewTouchDelegate = touchDelegate;
    }
    return self;
}

-(void)beginListeningForTapGestures
{
    if( ![[self tapGestureRecognizers] count] )
    {
        NSMutableArray* tapRecognizers = [NSMutableArray array];
        UITapGestureRecognizer* previousTapRecognizer = nil;
        for( int i = 5; i > 0; i-- )
        {
            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
            [tapRecognizer setNumberOfTapsRequired:i];
            [tapRecognizer setDelaysTouchesEnded:NO];
            [tapRecognizer setCancelsTouchesInView:NO];
            if( previousTapRecognizer )
            {
                [tapRecognizer requireGestureRecognizerToFail:previousTapRecognizer];
            }
            [self addGestureRecognizer:tapRecognizer];
            [tapRecognizers addObject:tapRecognizer];
            previousTapRecognizer = tapRecognizer;
        }
        [self setTapGestureRecognizers:tapRecognizers];
    }
}

-(void)beginListeningForSwipeGestures
{
    if( ![[self swipeGestureRecognizers] count] )
    {
        NSMutableArray* swipeRecognizers = [NSMutableArray array];
        for( int i = 0; i < 4; i++ )
        {
            UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
            [swipeRecognizer setDelaysTouchesEnded:NO];
            [swipeRecognizer setCancelsTouchesInView:NO];
            
            UISwipeGestureRecognizerDirection swipeDirection = 1 << i;
            [swipeRecognizer setDirection:swipeDirection];
            
            [self addGestureRecognizer:swipeRecognizer];
            [swipeRecognizers addObject:swipeRecognizer];
        }
        [self setSwipeGestureRecognizers:swipeRecognizers];
    }
}

-(void)beginListeningForPinchGestures
{
    if( ![self pinchGestureRecognizer] )
    {
        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognized:)];
        pinchRecognizer.delaysTouchesEnded = NO;
        pinchRecognizer.cancelsTouchesInView = NO;
        
        [self addGestureRecognizer:pinchRecognizer];
        [self setPinchGestureRecognizer:pinchRecognizer];
    }
}

-(void)beginListeningForPanGestures
{
    if( ![self panGestureRecognizer] )
    {
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panRecognizer.delaysTouchesEnded = NO;
        panRecognizer.cancelsTouchesInView = NO;
        
        [self addGestureRecognizer:panRecognizer];
        [self setPanGestureRecognizer:panRecognizer];
    }
}

-(void)beginListeningForLongPress
{
    if( ![self longPressRecognizer] )
    {
        UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self addGestureRecognizer:longPressRecognizer];
        [self setLongPressRecognizer:longPressRecognizer];
    }
}

-(void)stopListeningForTapGestures
{
    for( UITapGestureRecognizer* tapRecognizer in [self tapGestureRecognizers] )
    {
        [tapRecognizer removeTarget:self action:@selector(tapGestureRecognized:)];
        [self removeGestureRecognizer:tapRecognizer];
    }
    [self setTapGestureRecognizers:nil];
}

-(void)stopListeningForSwipeGestures
{
    for( UISwipeGestureRecognizer* swipeRecognizer in [self swipeGestureRecognizers] )
    {
        [swipeRecognizer removeTarget:self action:@selector(swipeGestureRecognized:)];
        [self removeGestureRecognizer:swipeRecognizer];
    }
    [self setSwipeGestureRecognizers:nil];
}

-(void)stopListeningForPinchGestures
{
    if( [self pinchGestureRecognizer] )
    {
        [[self pinchGestureRecognizer] removeTarget:self action:@selector(pinchGestureRecognized:)];
        [self removeGestureRecognizer:[self pinchGestureRecognizer]];
        [self setPinchGestureRecognizer:nil];
    }
}

-(void)stopListeningForPanGestures
{
    if( [self panGestureRecognizer] )
    {
        [[self panGestureRecognizer] removeTarget:self action:@selector(panGestureRecognized:)];
        [self removeGestureRecognizer:[self panGestureRecognizer]];
        [self setPanGestureRecognizer:nil];
    }
}

-(void)stopListeningForLongPress
{
    if( [self longPressRecognizer] )
    {
        [[self longPressRecognizer] removeTarget:self action:@selector(longPressGestureRecognized:)];
        [self removeGestureRecognizer:[self longPressRecognizer]];
        [self setLongPressRecognizer:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    IX_LOG_VERBOSE(@"TOUCHES BEGAN : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesBegan:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    IX_LOG_VERBOSE(@"TOUCHES MOVED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesMoved:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    IX_LOG_VERBOSE(@"TOUCHES CANCELLED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesCancelled:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesCancelled:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    IX_LOG_VERBOSE(@"TOUCHES ENDED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesEnded:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesEnded:touches withEvent:event];
    }
}

-(void)tapGestureRecognized:(UITapGestureRecognizer*)tapRecognizer
{
    IX_LOG_VERBOSE(@"TAP RECOGNIZED WITH TAP COUNT %lu : %@", (unsigned long)[tapRecognizer numberOfTapsRequired], [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTapGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTapGestureRecognized:tapRecognizer];
    }
}

-(void)swipeGestureRecognized:(UISwipeGestureRecognizer*)swipeRecognizer
{
    IX_LOG_VERBOSE(@"SWIPE RECOGNIZED WITH SWIPE DIRECTION %lu : %@", (unsigned long)[swipeRecognizer direction], [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewSwipeGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewSwipeGestureRecognized:swipeRecognizer];
    }
}

-(void)pinchGestureRecognized:(UIPinchGestureRecognizer*)pinchRecognizer
{
    IX_LOG_VERBOSE(@"PINCH RECOGNIZED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewPinchGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewPinchGestureRecognized:pinchRecognizer];
    }
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)panRecognizer
{
    IX_LOG_VERBOSE(@"PAN RECOGNIZED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewPanGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewPanGestureRecognized:panRecognizer];
    }
}

-(void)longPressGestureRecognized:(UILongPressGestureRecognizer*)longPressRecognizer
{
    IX_LOG_VERBOSE(@"LONG PRESS RECOGNIZED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewLongPressRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewLongPressRecognized:longPressRecognizer];
    }
}

@end
