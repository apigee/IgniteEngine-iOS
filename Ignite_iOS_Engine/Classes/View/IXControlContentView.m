//
//  IXControlContentView.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/22/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXControlContentView.h"

@implementation IXControlContentView

-(id)initWithFrame:(CGRect)frame viewTouchDelegate:(id<IXControlContentViewTouchDelegate>)touchDelegate
{
    self = [super initWithFrame:frame];
    if( self != nil )
    {
        _controlContentViewTouchDelegate = touchDelegate;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame viewTouchDelegate:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES BEGAN");
    if( [self controlContentViewTouchDelegate] && [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesBegan:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES MOVED");
    if( [self controlContentViewTouchDelegate] && [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesMoved:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES CANCELLED");
    if( [self controlContentViewTouchDelegate] && [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesCancelled:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesCancelled:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCHES ENDED");
    if( [self controlContentViewTouchDelegate] && [[self controlContentViewTouchDelegate] respondsToSelector:@selector(controlViewTouchesEnded:withEvent:)] )
    {
        [[self controlContentViewTouchDelegate] controlViewTouchesEnded:touches withEvent:event];
    }
}

@end
