//
//  IXCollection.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/31/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//


/*
 
 
 
 
 */

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###
 ###    Native collectionView view controller.
 
 <a href="#attributes">Attributes</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ####
 #### Attributes
 
 <a name="attributes"></a>
 
 |  Name                                |   Type                     |   Description                                         |   Default
 |:-------------------------------------|:--------------------------:|:------------------------------------------------------|:-------------:|
 | *minimum_line_spacing*               |   *(string)*               |   The sheet title                                   |   #ffffff
 | *minimum_interitem_spacing*          |   *(string)*               |   Cancel button text                                   |   #ffffff
 | *background_swipe_width*             |   *(string)*               |   Destructive button text                                   |   #ffffff
 | *layout_flow*                        |   *horizontal<br>vertical* |   Other button(s) text                                   |   #ffffff
 
 ####
 #### Inherits
 
 <a name="inherits"></a>
 
 >  IXBaseControl, IXCellBasedControl
 
 ####
 #### Events
 
  <a name="events"></a>
 
 |  Name                                |   Description                                         |
 |:-------------------------------------|:------------------------------------------------------|
 | *started_scrolling*                  |   The 'cancel' button was pressed.
 | *ended_scrolling*                    |   The '%@' button was pressed.
 
 ####
 #### Functions

 <a name="functions"></a>

 *reset_all_background_controls*
    
    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "actionSheetTest",
        "function_name": "show_sheet"
      }
    }
 
 *set_background_swipe_width*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "actionSheetTest",
        "function_name": "dismiss_sheet"
      }
    }


 ####
 #### Example JSON
 
 <a name="example"></a>
 
    {
      "_type": "ActionSheet",
      "_id": "actionSheetTest",
      "attributes": {
        "sheet.style": "black.opaque",
        "sheet.title": "sheetTitle",
        "sheet.button.title.cancel": "cancelButtonTitle",
        "sheet.button.title.destructive": "destructiveButtonTitle",
        "sheet.button.title.others": "other,someOther2"
      },
      "actions": [
        {
          "on": "cancel_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "Cancel Pressed"
          }
        },
        {
          "on": "other_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "other pressed [[app.bundle.version]]"
          }
        },
        {
          "on": "someOther2_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "someOther2 pressed"
          }
        },
        {
          "on": "destructiveButtonTitle_pressed",
          "_type": "Alert",
          "attributes": {
            "title": "destructiveButtonTitle pressed"
          }
        }
      ]
    }
 
 
 | Name                                      | Type                         | Description                    | Default |
 |-------------------------------------------|------------------------------|--------------------------------|---------|
 | animate_reload                            | *(bool)*                     | Reload rows animation          | false   |
 | animate_reload.duration                   | *(float)*                    | Reload rows animation duration |         |
 | background.color                          | *(color)*                    |                                |         |
 | background_swipe_width                    | *(integer)*                  |                                |         |
 | background_slides_in_from_side            | *(bool)*                     |                                |         |
 | background_swipe_adjusts_background_alpha | *(float)*                    |                                |         |
 | background_controls                       | [array]                      |                                |         |
 | section_header_xpath                      | *(string)*                   |                                |         |
 | section_header_controls                   | [array]                      |                                |         |
 | section_header_height                     | *(integer)*                  |                                |         |
 | section_header_width                      | *(integer)*                  |                                |         |
 | dataprovider_id                           | *(string)*                   |                                |         |
 | item_width                                | *(color)*                    |                                |         |
 | item_height                               | *(integer)*                  |                                |         |
 | paging.enabled                            | *(bool)*                     |                                |         |
 | scrollable                                | *(bool)*                     |                                |         |
 | pull_to_refresh.enabled                   | *(bool)*                     |                                |         |
 | pull_to_refresh.text                      | *(string)*                   |                                |         |
 | pull_to_refresh.text.color                | *(color)*                    |                                |         |
 | pull_to_refresh.text.font                 | *()*                         |                                |         |
 | pull_to_refresh.tint.color                | *(color)*                    |                                |         |
 | scroll_indicator_style                    | *default*<br>black<br>white* |                                |         |
 | shows_scroll_indicators                   | *(bool)*                     |                                |         |
 | datarow.basepath                          | *(string)*                   |                                |         |
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

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
