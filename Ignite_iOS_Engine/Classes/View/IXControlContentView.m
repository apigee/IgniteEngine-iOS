//
//  IXControlContentView.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/22/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXControlContentView.h"
#import "IXAppManager.h"
#import "IXLogger.h"

@interface IXControlContentView ()

@property (nonatomic,strong) NSArray* tapGestureRecognizers;
@property (nonatomic,strong) NSArray* swipeGestureRecognizers;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"TOUCHES BEGAN : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesBegan:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"TOUCHES MOVED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesMoved:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"TOUCHES CANCELLED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesCancelled:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesCancelled:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"TOUCHES ENDED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesEnded:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesEnded:touches withEvent:event];
    }
}

-(void)tapGestureRecognized:(UITapGestureRecognizer*)tapRecognizer
{
    DDLogVerbose(@"TAP RECOGNIZED WITH TAP COUNT %lu : %@", (unsigned long)[tapRecognizer numberOfTapsRequired], [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTapGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTapGestureRecognized:tapRecognizer];
    }
}

-(void)swipeGestureRecognized:(UISwipeGestureRecognizer*)swipeRecognizer
{
    DDLogVerbose(@"SWIPE RECOGNIZED WITH SWIPE DIRECTION %lu : %@", (unsigned long)[swipeRecognizer direction], [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewSwipeGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewSwipeGestureRecognized:swipeRecognizer];
    }
}

-(void)pinchGestureRecognized:(UIPinchGestureRecognizer*)pinchRecognizer
{
    DDLogVerbose(@"PINCH RECOGNIZED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewPinchGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewPinchGestureRecognized:pinchRecognizer];
    }
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)panRecognizer
{
    DDLogVerbose(@"PAN RECOGNIZED : %@", [[self controlContentViewTouchDelegate] description]);
    if( [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewPanGestureRecognized:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewPanGestureRecognized:panRecognizer];
    }
}

@end
