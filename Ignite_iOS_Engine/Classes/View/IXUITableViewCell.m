//
//  IXUITableViewCell.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXUITableViewCell.h"

#import "IXLayout.h"

@interface IXUITableViewCell ()

@property (nonatomic,assign) NSInteger startXPosition;
@property (nonatomic,strong) UIPanGestureRecognizer* panGestureRecognizer;

@end

@implementation IXUITableViewCell

-(void)dealloc
{
    [[_layoutControl contentView] removeGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _swipeWidth = 100;
        _forceSize = NO;
        _forcedSize = CGSizeZero;
        _layoutControl = nil;
        _backgroundLayoutControl = nil;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [_panGestureRecognizer setMinimumNumberOfTouches:1];
        [_panGestureRecognizer setMaximumNumberOfTouches:1];
        _panGestureRecognizer.delegate = self;
    }
    return self;
}

-(void)setLayoutControl:(IXLayout *)layoutControl
{
    _layoutControl = layoutControl;
    
    if( [layoutControl contentView] != nil )
    {
        [[self contentView] addSubview:[layoutControl contentView]];
        [[[self layoutControl] contentView] addGestureRecognizer:[self panGestureRecognizer]];
    }
}

-(void)setBackgroundLayoutControl:(IXLayout *)backgroundLayoutControl
{
    _backgroundLayoutControl = backgroundLayoutControl;
    
    if( [backgroundLayoutControl contentView] != nil )
    {
        [[self contentView] addSubview:[backgroundLayoutControl contentView]];
        [[self contentView] sendSubviewToBack:[backgroundLayoutControl contentView]];
    }
}

-(CGRect)frame
{
    CGRect returnFrame = [super frame];
    if( [self forceSize] )
    {
        returnFrame.size = [self forcedSize];
    }
    return returnFrame;
}

-(void)setFrame:(CGRect)frame
{
    if( [self forceSize] )
    {
        frame.size = [self forcedSize];
    }
    [super setFrame:frame];
}

-(void)enablePanGesture:(BOOL)enableGesture
{
    if (enableGesture)
    {
        [[[self layoutControl] contentView] addGestureRecognizer:[self panGestureRecognizer]];
    }
    else
    {
        [[[self layoutControl] contentView] removeGestureRecognizer:[self panGestureRecognizer]];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class])
    {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [panRecognizer velocityInView:self];
        
        if (fabsf(point.x) > fabsf(point.y) )
        {
            return YES;
        }
    }
    return NO;
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)panRecognizer
{
    UIView* layoutControlsView = [[self layoutControl] contentView];
    
    CGPoint translatedPoint = [panRecognizer translationInView:layoutControlsView];
    
    if ([panRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [self setStartXPosition:[[panRecognizer view] center].x];
    }
    
    CGFloat halfOfCellsWidth = ([self frame].size.width/2);
    CGFloat centerXOffsetByStartX = [self startXPosition] + translatedPoint.x;
    
    translatedPoint.y = [layoutControlsView center].y;
    
    if ( centerXOffsetByStartX > halfOfCellsWidth )
    {
        translatedPoint.x = halfOfCellsWidth;
    }
    else if ( centerXOffsetByStartX < (halfOfCellsWidth - [self swipeWidth]) )
    {
        translatedPoint.x = halfOfCellsWidth - [self swipeWidth];
    }
    else
    {
        translatedPoint.x = centerXOffsetByStartX;
    }
    
    [[panRecognizer view] setCenter:translatedPoint];
    
    if ([panRecognizer state] == UIGestureRecognizerStateEnded || [panRecognizer state] == UIGestureRecognizerStateCancelled)
    {
        CGFloat velocityX = (0.2 * [panRecognizer velocityInView:layoutControlsView].x );
        
        CGFloat finalX = translatedPoint.x + velocityX;
        
        if (finalX < halfOfCellsWidth - ([self swipeWidth]/2) )
        {
            finalX = halfOfCellsWidth - [self swipeWidth];
        }
        else
        {
            finalX = halfOfCellsWidth;
        }
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [[panRecognizer view] setCenter:CGPointMake(finalX, [layoutControlsView center].y)];
                         }];

    }
    
}

@end
