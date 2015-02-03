//
//  IXTableViewControl.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/18/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXTableView.h"

#import "IXLayout.h"
#import "IXUITableViewCell.h"
#import "IXCellBackgroundSwipeController.h"

#import "UIScrollView+APParallaxHeader.h"

// IXTableView Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
IX_STATIC_CONST_STRING kIXRowSelectEnabled = @"row_select_enabled";
IX_STATIC_CONST_STRING kIXKeepRowHighlightedOnSelect = @"keep_row_highlighted_on_select";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"background_swipe_width";

IX_STATIC_CONST_STRING kIXImageParallax = @"image.parallax";
IX_STATIC_CONST_STRING kIXImageParallaxHeight = @"image.parallax.height";

IX_STATIC_CONST_STRING kIXLayoutFlow = @"layout_flow";
IX_STATIC_CONST_STRING kIXLayoutFlowVertical = @"vertical";
IX_STATIC_CONST_STRING kIXLayoutFlowHorizontal = @"horizontal";

IX_STATIC_CONST_STRING kIXSeperatorColor = @"separator.color";
IX_STATIC_CONST_STRING kIXSeperatorStyle = @"separator.style";
IX_STATIC_CONST_STRING kIXSeperatorStyleNone = @"none";
IX_STATIC_CONST_STRING kIXSeperatorStyleDefault = @"default";

// IXTableView Events
IX_STATIC_CONST_STRING kIXStartedScrolling = @"started_scrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"ended_scrolling";

// These Events fired on the actual cells. (aka dataRow will work)
IX_STATIC_CONST_STRING kIXWillDisplayCell = @"will_display_cell";
IX_STATIC_CONST_STRING kIXDidHideCell = @"did_hide_cell";
IX_STATIC_CONST_STRING kIXDidSelectCell = @"did_select_cell";

// IXTableView Functions
IX_STATIC_CONST_STRING kIXResetAllBackgroundControls = @"reset_all_background_controls";
IX_STATIC_CONST_STRING kIXSetBackgroundSwipeWidth = @"set_background_swipe_width";

// Non property constants
IX_STATIC_CONST_STRING kIXCellIdentifier = @"IXUITableViewCell";

@interface IXTableView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) BOOL keepRowHighlightedOnSelect;

@end

@implementation IXTableView

-(void)dealloc
{
    [_tableView setDataSource:nil];
    [_tableView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    
    [[self contentView] addSubview:_tableView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [super layoutControlContentsInRect:rect];
    
    [[self tableView] setFrame:rect];
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXImageParallax] )
    {
        CGSize contentViewSize = [[self contentView] bounds].size;
        CGFloat parallaxHeight = [[self propertyContainer] getSizeValue:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
        [[self tableView] addParallaxWithImage:[[[[self tableView] parallaxView] imageView] image] andHeight:parallaxHeight];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    if( [self refreshControl] != nil && [[self refreshControl] superview] != [self tableView] )
    {
        [[self tableView] addSubview:[self refreshControl]];
    }
    
    [[self tableView] sendSubviewToBack:[self refreshControl]];
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImageParallax
                                  successBlock:^(UIImage *image) {
                                      
                                      CGSize contentViewSize = [[self contentView] bounds].size;
                                      CGFloat parallaxHeight = [[self propertyContainer] getSizeValue:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
                                      
                                      [[weakSelf tableView] addParallaxWithImage:image andHeight:parallaxHeight];
                                      [[[weakSelf tableView] parallaxView] layoutIfNeeded];
                                      
                                  } failBlock:^(NSError *error) {
                                  } shouldRefreshCachedImage:true];
    
    [[self tableView] setBackgroundColor:[[self contentView] backgroundColor]];
    [[self tableView] setScrollEnabled:[self scrollEnabled]];
    [[self tableView] setPagingEnabled:[self pagingEnabled]];
    [[self tableView] setShowsHorizontalScrollIndicator:[self showsScrollIndicators]];
    [[self tableView] setShowsVerticalScrollIndicator:[self showsScrollIndicators]];
    [[self tableView] setIndicatorStyle:[self scrollIndicatorStyle]];
    [[self tableView] setAllowsSelection:[[self propertyContainer] getBoolPropertyValue:kIXRowSelectEnabled defaultValue:YES]];
    [self setKeepRowHighlightedOnSelect:[[self propertyContainer] getBoolPropertyValue:kIXKeepRowHighlightedOnSelect defaultValue:NO]];

    NSString* seperatorStyle = [[self propertyContainer] getStringPropertyValue:kIXSeperatorStyle defaultValue:kIXSeperatorStyleDefault];
    if( [seperatorStyle isEqualToString:kIXSeperatorStyleNone] ) {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [[self tableView] setSeparatorColor:[[self propertyContainer] getColorPropertyValue:kIXSeperatorColor defaultValue:[UIColor grayColor]]];
    }
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
    if ([layoutFlow isEqualToString:kIXLayoutFlowHorizontal])
    {
        [[self tableView] setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self reload];
    });
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXResetAllBackgroundControls] )
    {
        for( IXUITableViewCell* cell in [[self tableView] visibleCells] )
        {
            [[cell cellBackgroundSwipeController] resetCellPosition];
        }
    }
    else if( [functionName isEqualToString:kIXSetBackgroundSwipeWidth] )
    {
        [self setBackgroundViewSwipeWidth:[parameterContainer getFloatPropertyValue:kIXBackgroundSwipeWidth defaultValue:0.0f]];
        for( IXUITableViewCell* cell in [[self tableView] visibleCells] )
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
        [UIView transitionWithView:[self tableView]
                          duration:[self animateReloadDuration]
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseOut
                        animations: ^(void) {
                            [[self tableView] reloadData];
                        } completion:nil];
    }
    else
    {
        [[self tableView] reloadData];
    }
}

-(void)cellBackgroundWillBeginToOpen:(UIView *)cellView
{
    for( IXUITableViewCell* cell in [[self tableView] visibleCells] )
    {
        if( cell != cellView )
        {
            [[cell cellBackgroundSwipeController] resetCellPosition];
        }
    }
}

#pragma mark UITableViewDataSource and UITableViewDelegate  methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* visibleIndexPaths = [tableView indexPathsForVisibleRows];
    if( [cell isKindOfClass:[IXUITableViewCell class]] && [visibleIndexPaths indexOfObject:indexPath] != NSNotFound )
    {
        IXLayout* layout = [(IXUITableViewCell*)cell layoutControl];
        [[layout actionContainer] executeActionsForEventNamed:kIXWillDisplayCell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* visibleIndexPaths = [tableView indexPathsForVisibleRows];
    if( [cell isKindOfClass:[IXUITableViewCell class]] && [visibleIndexPaths indexOfObject:indexPath] == NSNotFound )
    {
        IXLayout* layout = [(IXUITableViewCell*)cell layoutControl];
        [[layout actionContainer] executeActionsForEventNamed:kIXDidHideCell];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[self headerViewForSection:section] contentView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = [self sizeForCellAtIndexPath:indexPath];
    return itemSize.height;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [self rowCountForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IXUITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kIXCellIdentifier];
    if( cell == nil )
    {
        cell = [[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIXCellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    [[cell contentView] setBackgroundColor:[[self tableView] backgroundColor]];
    [self configureCell:cell withIndexPath:indexPath];
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
    if ([layoutFlow isEqualToString:kIXLayoutFlowHorizontal])
    {
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( ![self keepRowHighlightedOnSelect] )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [[self actionContainer] executeActionsForEventNamed:kIXDidSelectCell];
}

#pragma mark UIScrollViewDelegate methods

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for( IXUITableViewCell* cell in [[self tableView] visibleCells] )
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
