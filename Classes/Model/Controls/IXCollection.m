//
//  IXCollection.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/31/13.
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

#import "IXCollection.h"

#import "IXUICollectionViewCell.h"
#import "IXCellBackgroundSwipeController.h"

// IXCollection Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
IX_STATIC_CONST_STRING kIXMinimumLineSpacing = @"lineSpacing.min";
IX_STATIC_CONST_STRING kIXMinimumInteritemSpacing = @"itemSpacing.min";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"swipe.w";
IX_STATIC_CONST_STRING kIXLayoutFlow = @"layoutFlow";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXLayoutFlowVertical = @"vertical"; // layoutFlow
IX_STATIC_CONST_STRING kIXLayoutFlowHorizontal = @"horizontal"; // layoutFlow

// IXCollection Events
IX_STATIC_CONST_STRING kIXStartedScrolling = @"didBeginScrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"didEndScrolling";

// IXCollection Functions
IX_STATIC_CONST_STRING kIXResetAllBackgroundControls = @"resetSwipeControls";
IX_STATIC_CONST_STRING kIXSetBackgroundSwipeWidth = @"setSwipeWidth";


@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout* collectionViewLayout;

@end

// Internal properties
IX_STATIC_CONST_STRING kIXCellIdentifier = @"IXUICollectionViewCell";

@implementation IXCollection

-(void)dealloc
{
    [_collectionView setDelegate:nil];
}

- (void)buildView
{
    [super buildView];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [_collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView registerClass:[IXUICollectionViewCell class] forCellWithReuseIdentifier:kIXCellIdentifier];

    [[self contentView] addSubview:_collectionView];
}

- (void)layoutControlContentsInRect:(CGRect)rect
{
    [super layoutControlContentsInRect:rect];
    
    [[self collectionView] setFrame:rect];
}

- (void)applySettings
{
    [super applySettings];
    
    if( [self refreshControl] != nil && [[self refreshControl] superview] != [self collectionView] )
    {
        [[self collectionView] addSubview:[self refreshControl]];
    }
    
    [[self collectionView] sendSubviewToBack:[self refreshControl]];

    [[self collectionView] setBackgroundColor:[[self contentView] backgroundColor]];
    [[self collectionView] setScrollEnabled:[self scrollEnabled]];
    [[self collectionView] setShowsHorizontalScrollIndicator:[self showsHorizScrollIndicators]];
    [[self collectionView] setShowsVerticalScrollIndicator:[self showsVertScrollIndicators]];
    [[self collectionView] setIndicatorStyle:[self scrollIndicatorStyle]];
    [[self collectionView] setPagingEnabled:[self pagingEnabled]];

    [[self collectionViewLayout] setMinimumLineSpacing:[[self attributeContainer] getFloatValueForAttribute:kIXMinimumLineSpacing defaultValue:0.0f]];
    [[self collectionViewLayout] setMinimumInteritemSpacing:[[self attributeContainer] getFloatValueForAttribute:kIXMinimumInteritemSpacing defaultValue:0.0f]];

    NSString* layoutFlow = [[self attributeContainer] getStringValueForAttribute:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
    if( [layoutFlow isEqualToString:kIXLayoutFlowHorizontal] )
    {
        [[self collectionViewLayout] setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    else
    {
        [[self collectionViewLayout] setScrollDirection:UICollectionViewScrollDirectionVertical];
    }

    dispatch_async(dispatch_get_main_queue(),^{
        [self reload];
    });
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXResetAllBackgroundControls] )
    {
        for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
        {
            [[cell cellBackgroundSwipeController] resetCellPosition];
        }
    }
    else if( [functionName isEqualToString:kIXSetBackgroundSwipeWidth] )
    {
        [self setBackgroundViewSwipeWidth:[parameterContainer getFloatValueForAttribute:kIXBackgroundSwipeWidth defaultValue:0.0f]];
        for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
        {
            [[cell cellBackgroundSwipeController] setSwipeWidth:[self backgroundViewSwipeWidth]];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)reload
{
    [super reload];
    
    if( [self animateReload] && [self animateReloadDuration] > 0.0f )
    {
        [UIView transitionWithView:[self collectionView]
                          duration:[self animateReloadDuration]
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseOut
                        animations: ^(void) {
                            [[self collectionView] reloadData];
                        } completion:nil];
    }
    else
    {
        [[self collectionView] reloadData];
    }
}

-(void)cellBackgroundWillBeginToOpen:(UIView *)cellView
{
    for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
    {
        if( cell != cellView )
        {
            [[cell cellBackgroundSwipeController] resetCellPosition];
        }
    }
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [self rowCountForSection:section];
    return rowsInSection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self sizeForCellAtIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IXUICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIXCellIdentifier
                                                                             forIndexPath:indexPath];
    
    [[cell contentView] setBackgroundColor:[[self collectionView] backgroundColor]];
    [self configureCell:cell withIndexPath:indexPath];
    
    return cell;
}

#pragma mark UIScrollViewDelegate methods

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
    {
        [[cell cellBackgroundSwipeController] resetCellPosition];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXStartedScrolling];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[self actionContainer] executeActionsForEventNamed:kIXEndedScrolling];
}

@end
