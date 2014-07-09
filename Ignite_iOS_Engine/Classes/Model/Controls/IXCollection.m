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

// IXCollection Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
IX_STATIC_CONST_STRING kIXMinimumLineSpacing = @"minimum_line_spacing";
IX_STATIC_CONST_STRING kIXMinimumInteritemSpacing = @"minimum_interitem_spacing";

IX_STATIC_CONST_STRING kIXLayoutFlow = @"layout_flow";
IX_STATIC_CONST_STRING kIXLayoutFlowVertical = @"vertical";
IX_STATIC_CONST_STRING kIXLayoutFlowHorizontal = @"horizontal";

// IXCollection Events
IX_STATIC_CONST_STRING kIXStartedScrolling = @"started_scrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"ended_scrolling";

// IXCollection Functions
IX_STATIC_CONST_STRING kIXResetAllBackgroundControls = @"reset_all_background_controls";

IX_STATIC_CONST_STRING kIXCellIdentifier = @"IXUICollectionViewCell";

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
    [[self collectionView] setShowsHorizontalScrollIndicator:[self showsScrollIndicators]];
    [[self collectionView] setShowsVerticalScrollIndicator:[self showsScrollIndicators]];
    [[self collectionView] setIndicatorStyle:[self scrollIndicatorStyle]];
    [[self collectionView] setPagingEnabled:[self pagingEnabled]];

    [[self collectionViewLayout] setMinimumLineSpacing:[[self propertyContainer] getFloatPropertyValue:kIXMinimumLineSpacing defaultValue:0.0f]];
    [[self collectionViewLayout] setMinimumInteritemSpacing:[[self propertyContainer] getFloatPropertyValue:kIXMinimumInteritemSpacing defaultValue:0.0f]];

    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXResetAllBackgroundControls] )
    {
        for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
        {
            [[cell cellBackgroundSwipeController] resetCellPosition];
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
