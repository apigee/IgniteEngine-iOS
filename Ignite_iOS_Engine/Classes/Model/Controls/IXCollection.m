//
//  IXCollection.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/31/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

/*
 *      Docs
 *
 *      Author:     Jeremy Anticouni
 *      Date:     	1/28/2015
 *
 *
 *      Copyright (c) 2015 Apigee. All rights reserved.
*/

/** Have some data? Toss it in a Collection View!
*/

#import "IXCollection.h"

#import "IXUICollectionViewCell.h"
#import "IXCellBackgroundSwipeController.h"

// IXCollection Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
IX_STATIC_CONST_STRING kIXMinimumLineSpacing = @"minimum_line_spacing";
IX_STATIC_CONST_STRING kIXMinimumInteritemSpacing = @"minimum_interitem_spacing";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"background_swipe_width";

IX_STATIC_CONST_STRING kIXLayoutFlow = @"layout_flow";
IX_STATIC_CONST_STRING kIXLayoutFlowVertical = @"vertical";
IX_STATIC_CONST_STRING kIXLayoutFlowHorizontal = @"horizontal";

// IXCollection Events
IX_STATIC_CONST_STRING kIXStartedScrolling = @"started_scrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"ended_scrolling";

// IXCollection Functions
IX_STATIC_CONST_STRING kIXResetAllBackgroundControls = @"reset_all_background_controls";
IX_STATIC_CONST_STRING kIXSetBackgroundSwipeWidth = @"set_background_swipe_width";

IX_STATIC_CONST_STRING kIXCellIdentifier = @"IXUICollectionViewCell";

@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout* collectionViewLayout;

@end

@implementation IXCollection

/*
* Docs
*
*/

/***************************************************************/

/** This control has the following attributes:

    @param minimum_line_spacing ?<br>*(string)*
    @param minimum_interitem_spacing ?<br>*(string)*
    @param background_swipe_width Background swipe width<br>*(string)*
    @param layout_flow Layout Flow<br>*horizontal,vertical*
    @param animate_reload Reload rows animation *(default: FALSE)*<br>*(bool)*
    @param animate_reload.duration Reload rows animation duration<br>*(float)*
    @param background.color <br>*(color)*
    @param background_swipe_width <br>*(integer)*
    @param background_slides_in_from_side <br>*(bool)*
    @param background_swipe_adjusts_background_alpha <br>*(float)*
    @param background_controls <br>*[array]*
    @param section_header_xpath <br>*(string)*
    @param section_header_controls <br>*[array]*
    @param section_header_height <br>*(integer)*
    @param section_header_width <br>*(integer)*
    @param dataprovider_id <br>*(string)*
    @param item_width <br>*(color)*
    @param item_height <br>*(integer)*
    @param paging.enabled <br>*(bool)*
    @param scrollable <br>*(bool)*
    @param pull_to_refresh.enabled <br>*(bool)*
    @param pull_to_refresh.text <br>*(string)*
    @param pull_to_refresh.text.color <br>*(color)*
    @param pull_to_refresh.text.font <br>*()*
    @param pull_to_refresh.tint.color <br>*(color)*
"    @param scroll_indicator_style <br>*default
black
white**"
    @param shows_scroll_indicators <br>*(bool)*
    @param datarow.basepath <br>*(string)*

*/

-(void)Attributes
{
}
/***************************************************************/
/***************************************************************/

/** This control has the following attributes:
*/

-(void)Returns
{
}

/***************************************************************/
/***************************************************************/

/** This control fires the following events:


    @param started_scrolling The ‘cancel’ button was pressed.
    @param ended_scrolling The ‘%@’ button was pressed.

*/

-(void)Events
{
}

/***************************************************************/
/***************************************************************/

/** This control supports the following functions:


    @param reset_all_background_controls Reset all background controls

 <pre class="brush: js; toolbar: false;">
 
 </pre>


    @param set_background_swipe_width Change the swipe width of the background controls

 <pre class="brush: js; toolbar: false;">
 
 </pre>


*/

-(void)Functions
{
}

/***************************************************************/
/***************************************************************/

/** Go on, try it out!

 
 <pre class="brush: js; toolbar: false;">
 
 </pre>

*/

-(void)Example
{
}

/***************************************************************/

/*
* /Docs
*
*/

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
    else if( [functionName isEqualToString:kIXSetBackgroundSwipeWidth] )
    {
        [self setBackgroundViewSwipeWidth:[parameterContainer getFloatPropertyValue:kIXBackgroundSwipeWidth defaultValue:0.0f]];
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
