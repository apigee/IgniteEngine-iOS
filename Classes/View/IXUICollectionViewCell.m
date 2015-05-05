//
//  IXUICollectionViewCell.m
//  Ignite Engine
//
//  Created by Robert Walsh on 1/21/14.
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

#import "IXUICollectionViewCell.h"

#import "IXCellBackgroundSwipeController.h"

#import "IXLayout.h"
#import "IXAttribute.h"
#import "UIView+IXAdditions.h"

@interface IXUICollectionViewCell ()

@property (nonatomic,strong) IXCellBackgroundSwipeController* cellBackgroundSwipeController;

@end

@implementation IXUICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [[self contentView] removeAllSubviews];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [[self cellBackgroundSwipeController] setCellsStartingCenterXPosition:[self center].x];
}

-(void)setLayoutControl:(IXLayout *)layoutControl
{
    [[_layoutControl contentView] removeFromSuperview];
    _layoutControl = layoutControl;
    
    UIView* layoutView = [_layoutControl contentView];
    if( layoutView != nil )
    {
        [[self contentView] addSubview:layoutView];
    }
    
    [[self cellBackgroundSwipeController] setLayoutControl:_layoutControl];
}

-(void)setBackgroundLayoutControl:(IXLayout *)backgroundLayoutControl
{
    [[_backgroundLayoutControl contentView] removeFromSuperview];
    _backgroundLayoutControl = backgroundLayoutControl;
    
    UIView* backgroundView = [_backgroundLayoutControl contentView];
    if( backgroundView != nil )
    {
        if( [self backgroundSlidesInFromSide] )
        {
            backgroundView.frame = CGRectMake([[_layoutControl contentView] frame].size.width, 0, backgroundView.frame.size.width, backgroundView.frame.size.height);
            [[[self layoutControl] contentView] addSubview:backgroundView];
        }
        else
        {
            [[self contentView] addSubview:backgroundView];
            [[self contentView] sendSubviewToBack:backgroundView];
        }
    }
    
    [[self cellBackgroundSwipeController] setBackgroundLayoutControl:_backgroundLayoutControl];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if( [self backgroundSlidesInFromSide] )
    {
        IXBaseControl* touchedControl = [[self backgroundLayoutControl] getTouchedControl:[[event allTouches] anyObject]];
        [[touchedControl contentView] touchesBegan:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if( [self backgroundSlidesInFromSide] )
    {
        IXBaseControl* touchedControl = [[self backgroundLayoutControl] getTouchedControl:[[event allTouches] anyObject]];
        [[touchedControl contentView] touchesCancelled:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if( [self backgroundSlidesInFromSide] )
    {
        IXBaseControl* touchedControl = [[self backgroundLayoutControl] getTouchedControl:[[event allTouches] anyObject]];
        [[touchedControl contentView] touchesMoved:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if( [self backgroundSlidesInFromSide] )
    {
        IXBaseControl* touchedControl = [[self backgroundLayoutControl] getTouchedControl:[[event allTouches] anyObject]];
        [[touchedControl contentView] touchesEnded:touches withEvent:event];
    }
}

-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth
{
    if( enableBackgroundSwipe )
    {
        [self setCellBackgroundSwipeController:[[IXCellBackgroundSwipeController alloc] initWithCellView:self]];
        [[self cellBackgroundSwipeController] setCellsStartingCenterXPosition:[self center].x];
        [[self cellBackgroundSwipeController] setSwipeWidth:swipeWidth];
        [[self cellBackgroundSwipeController] setLayoutControl:[self layoutControl]];
        [[self cellBackgroundSwipeController] setBackgroundLayoutControl:[self backgroundLayoutControl]];
        [[self cellBackgroundSwipeController] setAdjustsBackgroundAlphaWithSwipe:[self adjustsBackgroundAlphaWithSwipe]];
        [[self cellBackgroundSwipeController] enablePanGesture:YES];
    }
    else
    {
        [self setCellBackgroundSwipeController:nil];
    }
}

@end
