//
//  IXCollection.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/31/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXCollection.h"

#import "IXUICollectionViewCell.h"
#import "IXCellBackgroundSwipeController.h"

// IXTableView Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
static NSString* const kIXStartedScrolling = @"started_scrolling";
static NSString* const kIXEndedScrolling = @"ended_scrolling";

static NSString* const kIXCellIdentifier = @"IXUICollectionViewCell";

@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout* collectionViewLayout;

@end

@implementation IXCollection

-(void)dealloc
{
    [_collectionView setDelegate:nil];
}

- (void)buildView
{
    [super buildView];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [_collectionViewLayout setMinimumLineSpacing:1.0f];
    [_collectionViewLayout setMinimumInteritemSpacing:1.0f];
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
    
    [[self collectionView] setBackgroundColor:[[self contentView] backgroundColor]];
    [[self collectionView] setScrollEnabled:[self scrollEnabled]];
    [[self collectionView] setShowsHorizontalScrollIndicator:[self showsScrollIndicators]];
    [[self collectionView] setShowsVerticalScrollIndicator:[self showsScrollIndicators]];
    [[self collectionView] setIndicatorStyle:[self scrollIndicatorStyle]];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self reload];
    });
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
