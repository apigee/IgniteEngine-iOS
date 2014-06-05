//
//  IXCellBackgroundSwipeController.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCellBackgroundSwipeController.h"

#import "IXLayout.h"

@interface IXCellBackgroundSwipeController () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer* tapGestureRecognizer;

@end

@implementation IXCellBackgroundSwipeController

-(void)dealloc
{
    [[_layoutControl contentView] removeGestureRecognizer:_panGestureRecognizer];
    [[_layoutControl contentView] removeGestureRecognizer:_tapGestureRecognizer];
    [_panGestureRecognizer setDelegate:nil];
    [_tapGestureRecognizer setDelegate:nil];
}

- (instancetype)initWithCellView:(UIView*)cellView
{
    self = [super init];
    if (self)
    {
        _cellView = cellView;        
        _swipeWidth = 100;
    }
    return self;
}

-(void)resetCellPosition
{
    if( [self backgroundLayoutControl] )
    {
        CGFloat centerX = [[[self layoutControl] contentView] center].x;
        if( centerX != [self cellsStartingCenterXPosition] )
        {
            UIView* layoutControlsView = [[self layoutControl] contentView];
            CGFloat halfOfCellsWidth = ([[self cellView] frame].size.width/2);
            
            CGFloat animationDuration = (ABS(halfOfCellsWidth)*0.0002f)+0.2f;
            
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 [[[self layoutControl] contentView] setCenter:CGPointMake([self cellsStartingCenterXPosition], [layoutControlsView center].y)];
                                 [self adjustBackgroundViewsAlpha];
                             }];
        }
        
        [[self tapGestureRecognizer] setEnabled:NO];
    }
}

-(void)enablePanGesture:(BOOL)enableGesture
{
    if (enableGesture)
    {
        if( _panGestureRecognizer == nil && _tapGestureRecognizer == nil )
        {
            _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
            [_panGestureRecognizer setMinimumNumberOfTouches:1];
            [_panGestureRecognizer setMaximumNumberOfTouches:1];
            [_panGestureRecognizer setDelegate:self];
            [[[self layoutControl] contentView] addGestureRecognizer:[self panGestureRecognizer]];
            
            _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
            [_tapGestureRecognizer setNumberOfTapsRequired:1];
            [_tapGestureRecognizer setEnabled:NO];
            [[[self layoutControl] contentView] addGestureRecognizer:[self tapGestureRecognizer]];
        }
    }
    else
    {
        [[[self layoutControl] contentView] removeGestureRecognizer:[self panGestureRecognizer]];
        [[[self layoutControl] contentView] removeGestureRecognizer:[self tapGestureRecognizer]];
        [self setPanGestureRecognizer:nil];
        [self setTapGestureRecognizer:nil];
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
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:[self cellView]];
        returnValue = ( fabsf(point.x) > fabsf(point.y) );
    }
    return returnValue;
}

-(void)adjustBackgroundViewsAlpha
{
    CGPoint origin = [[_layoutControl contentView] frame].origin;
    CGFloat originsXPosition = fabsf(origin.x);
    CGFloat percentage = originsXPosition/[self swipeWidth];
    
    [[[self backgroundLayoutControl] contentView] setAlpha:percentage];
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)panRecognizer
{
    UIView* layoutControlsView = [[self layoutControl] contentView];
    
    CGPoint translatedPoint = [panRecognizer translationInView:layoutControlsView];
    
    if ([panRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [self setStartXPosition:[[panRecognizer view] center].x];
    }
    
    CGFloat halfOfCellsWidth = ([[self cellView] frame].size.width/2);
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
    
    [self adjustBackgroundViewsAlpha];
    
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
                             [self adjustBackgroundViewsAlpha];
                         }];
        
    }
}

@end
