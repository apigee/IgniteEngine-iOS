//
//  IXUICollectionViewCell.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXUICollectionViewCell.h"

#import "IXLayout.h"

@interface IXUICollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic,assign) NSInteger cellsStartingCenterXPosition;
@property (nonatomic,assign) NSInteger startXPosition;
@property (nonatomic,strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer* tapGestureRecognizer;

@end

@implementation IXUICollectionViewCell

-(void)dealloc
{
    [[_layoutControl contentView] removeGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:nil];
    [_tapGestureRecognizer setDelegate:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _swipeWidth = 100;
        _layoutControl = nil;
        _backgroundLayoutControl = nil;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [_panGestureRecognizer setMinimumNumberOfTouches:1];
        [_panGestureRecognizer setMaximumNumberOfTouches:1];
        [_panGestureRecognizer setDelegate:self];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [_tapGestureRecognizer setNumberOfTapsRequired:1];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setCellsStartingCenterXPosition:[self center].x];
}

-(void)setLayoutControl:(IXLayout *)layoutControl
{
    _layoutControl = layoutControl;
    
    if( [layoutControl contentView] != nil )
    {
        [[self contentView] addSubview:[layoutControl contentView]];
        [[[self layoutControl] contentView] addGestureRecognizer:[self panGestureRecognizer]];
        [[[self layoutControl] contentView] addGestureRecognizer:[self tapGestureRecognizer]];
        [[self tapGestureRecognizer] setEnabled:NO];
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

-(void)resetCellPosition
{
    if( [self backgroundLayoutControl] )
    {
        CGFloat centerX = [[[self layoutControl] contentView] center].x;
        if( centerX != [self cellsStartingCenterXPosition] )
        {
            UIView* layoutControlsView = [[self layoutControl] contentView];
            CGFloat halfOfCellsWidth = ([self frame].size.width/2);
            
            CGFloat animationDuration = (ABS(halfOfCellsWidth)*0.0002f)+0.2f;
            
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 [[[self layoutControl] contentView] setCenter:CGPointMake([self cellsStartingCenterXPosition], [layoutControlsView center].y)];
                             }];
        }
        
        [[self tapGestureRecognizer] setEnabled:NO];
    }
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

-(void)tapGestureRecognized:(UITapGestureRecognizer*)tapGesture
{
    [self resetCellPosition];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL returnValue = NO;
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class])
    {
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        returnValue = ( fabsf(point.x) > fabsf(point.y) );
    }
    return returnValue;
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
        CGFloat velocityX = (0.2f * [panRecognizer velocityInView:layoutControlsView].x );
        
        CGFloat finalX = translatedPoint.x + velocityX;
        
        if (finalX < halfOfCellsWidth - ([self swipeWidth]/2) )
        {
            finalX = halfOfCellsWidth - [self swipeWidth];
        }
        else
        {
            finalX = halfOfCellsWidth;
        }
        
        CGFloat animationDuration = (ABS(velocityX)*0.0002f)+0.2f;
        
        [[self tapGestureRecognizer] setEnabled:( finalX != [self cellsStartingCenterXPosition] )];
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [[panRecognizer view] setCenter:CGPointMake(finalX, [layoutControlsView center].y)];
                         }];
        
    }
}

@end
