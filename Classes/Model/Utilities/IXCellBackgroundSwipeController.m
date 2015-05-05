//
//  IXCellBackgroundSwipeController.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/4/14.
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
        _adjustsBackgroundAlphaWithSwipe = NO;
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

-(void)setSwipeWidth:(CGFloat)swipeWidth
{
    _swipeWidth = swipeWidth;

    UIView* layoutControlsView = [[self layoutControl] contentView];
    if( [self backgroundLayoutControl] && [layoutControlsView center].x != [self cellsStartingCenterXPosition] ) {

        CGFloat halfOfCellsWidth = ([[self cellView] frame].size.width/2);
        CGFloat finalX = halfOfCellsWidth - [self swipeWidth];

        [self adjustBackgroundViewsAlpha];

        CGFloat animationDuration = (ABS(halfOfCellsWidth)*0.0002f)+0.2f;

        [[self tapGestureRecognizer] setEnabled:( finalX != [self cellsStartingCenterXPosition] )];

        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [layoutControlsView setCenter:CGPointMake(finalX, [layoutControlsView center].y)];
                             [self adjustBackgroundViewsAlpha];
                         }];
    }
}

-(void)setAdjustsBackgroundAlphaWithSwipe:(BOOL)adjustsBackgroundAlphaWithSwipe
{
    _adjustsBackgroundAlphaWithSwipe = adjustsBackgroundAlphaWithSwipe;
    
    if( _adjustsBackgroundAlphaWithSwipe )
    {
        [[_backgroundLayoutControl contentView] setAlpha:0];
    }
    else
    {
        [[_backgroundLayoutControl contentView] setAlpha:1];
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
        returnValue = ( fabs(point.x) > fabs(point.y) );
    }
    return returnValue;
}

-(void)adjustBackgroundViewsAlpha
{
    if( [self adjustsBackgroundAlphaWithSwipe] )
    {
        CGPoint origin = [[_layoutControl contentView] frame].origin;
        CGFloat originsXPosition = fabs(origin.x);
        CGFloat percentage = originsXPosition/[self swipeWidth];
        
        [[[self backgroundLayoutControl] contentView] setAlpha:percentage];
    }
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)panRecognizer
{
    UIView* layoutControlsView = [[self layoutControl] contentView];
    
    CGPoint translatedPoint = [panRecognizer translationInView:layoutControlsView];
    
    if ([panRecognizer state] == UIGestureRecognizerStateBegan)
    {
        if( [[self delegate] respondsToSelector:@selector(cellBackgroundWillBeginToOpen:)] )
        {
            [[self delegate] cellBackgroundWillBeginToOpen:[self cellView]];
        }
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
