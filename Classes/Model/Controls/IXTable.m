//
//  IXTableViewControl.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/18/13.
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

#import "IXTable.h"

#import "IXLayout.h"
#import "IXUITableViewCell.h"
#import "UIImage+ResizeMagick.h"
#import "IXCellBackgroundSwipeController.h"

#import "UIScrollView+APParallaxHeader.h"

// IXTableView Attributes (Note: See IXCellBasedControl for the super classes properties as well.)
IX_STATIC_CONST_STRING kIXRowSelectEnabled = @"rowSelect.enabled";
IX_STATIC_CONST_STRING kIXKeepRowHighlightedOnSelect = @"rowStaysHighlighted.enabled";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"swipe.w";

IX_STATIC_CONST_STRING kIXImageParallax = @"parallaxImage";
IX_STATIC_CONST_STRING kIXImageParallaxHeight = @"parallaxImage.h";
IX_STATIC_CONST_STRING kIXImageParallaxWidth = @"parallaxImage.w";

// IXImage Manipulation -- use a resizedImageByMagick mask for these
IX_STATIC_CONST_STRING kIXParallaxImageResizeMask = @"parallaxImage.resizeMask";

IX_STATIC_CONST_STRING kIXLayoutFlow = @"layoutFlow";
IX_STATIC_CONST_STRING kIXLayoutFlowVertical = @"vertical";
IX_STATIC_CONST_STRING kIXLayoutFlowHorizontal = @"horizontal";

IX_STATIC_CONST_STRING kIXSeperatorColor = @"separator.color";
IX_STATIC_CONST_STRING kIXSeperatorStyle = @"separator.style";
IX_STATIC_CONST_STRING kIXSeperatorStyleNone = @"none";
IX_STATIC_CONST_STRING kIXSeperatorStyleDefault = @"default";

// IXTableView Events
IX_STATIC_CONST_STRING kIXStartedScrolling = @"didBeginScrolling";
IX_STATIC_CONST_STRING kIXEndedScrolling = @"didEndScrolling";

// These Events fired on the actual cells. (aka dataRow will work)
IX_STATIC_CONST_STRING kIXWillDisplayCell = @"willDisplayCell";
IX_STATIC_CONST_STRING kIXDidHideCell = @"didHideCell";
IX_STATIC_CONST_STRING kIXDidSelectCell = @"didSelectCell";

// IXTableView Functions
IX_STATIC_CONST_STRING kIXResetAllBackgroundControls = @"resetSwipeControls";
IX_STATIC_CONST_STRING kIXSetBackgroundSwipeWidth = @"setSwipeSize";

// Non property constants
IX_STATIC_CONST_STRING kIXCellIdentifier = @"IXUITableViewCell";

@interface IXTable () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) BOOL keepRowHighlightedOnSelect;

@end

@implementation IXTable

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
    
    if( [[self attributeContainer] attributeExistsForName:kIXImageParallax] )
    {
        
        CGSize contentViewSize = [[self contentView] bounds].size;
        CGFloat parallaxHeight = [[self attributeContainer] getSizeValueForAttribute:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
        CGFloat parallaxWidth = [[self attributeContainer] getSizeValueForAttribute:kIXImageParallaxWidth maximumSize:contentViewSize.width defaultValue:0.0f];
        [[self tableView] addParallaxWithImage:_tableView.parallaxView.imageView.image withWidth:parallaxWidth andHeight:parallaxHeight];
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
    [[self attributeContainer] getImageAttribute:kIXImageParallax
                                  successBlock:^(UIImage *image) {
                                      
                                      NSString* resizeDefault = [self.attributeContainer getStringValueForAttribute:kIXParallaxImageResizeMask defaultValue:nil];
                                      
                                      if (resizeDefault)
                                          image = [image resizedImageByMagick:resizeDefault];
                                      
                                      CGSize contentViewSize = [[self contentView] bounds].size;
                                      CGFloat parallaxHeight = [[self attributeContainer] getSizeValueForAttribute:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
                                      CGFloat parallaxWidth = [[self attributeContainer] getSizeValueForAttribute:kIXImageParallaxWidth maximumSize:contentViewSize.width defaultValue:0.0f];
                                      
                                      [[weakSelf tableView] addParallaxWithImage:image withWidth:parallaxWidth andHeight:parallaxHeight];
                                      [[[weakSelf tableView] parallaxView] layoutIfNeeded];
                                      
                                  } failBlock:^(NSError *error) {
                                  } shouldRefreshCachedImage:true];
    
    [[self tableView] setBackgroundColor:[[self contentView] backgroundColor]];
    [[self tableView] setScrollEnabled:[self scrollEnabled]];
    [[self tableView] setPagingEnabled:[self pagingEnabled]];
    [[self tableView] setShowsHorizontalScrollIndicator:[self showsHorizScrollIndicators]];
    [[self tableView] setShowsVerticalScrollIndicator:[self showsVertScrollIndicators]];
    [[self tableView] setIndicatorStyle:[self scrollIndicatorStyle]];
    [[self tableView] setAllowsSelection:[[self attributeContainer] getBoolValueForAttribute:kIXRowSelectEnabled defaultValue:YES]];
    [self setKeepRowHighlightedOnSelect:[[self attributeContainer] getBoolValueForAttribute:kIXKeepRowHighlightedOnSelect defaultValue:NO]];

    NSString* seperatorStyle = [[self attributeContainer] getStringValueForAttribute:kIXSeperatorStyle defaultValue:kIXSeperatorStyleDefault];
    if( [seperatorStyle isEqualToString:kIXSeperatorStyleNone] ) {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [[self tableView] setSeparatorColor:[[self attributeContainer] getColorValueForAttribute:kIXSeperatorColor defaultValue:[UIColor grayColor]]];
    }
    
    NSString* layoutFlow = [[self attributeContainer] getStringValueForAttribute:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
    if ([layoutFlow isEqualToString:kIXLayoutFlowHorizontal])
    {
        [[self tableView] setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self reload];
    });
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
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
        [self setBackgroundViewSwipeWidth:[parameterContainer getFloatValueForAttribute:kIXBackgroundSwipeWidth defaultValue:0.0f]];
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
    
    NSString* layoutFlow = [[self attributeContainer] getStringValueForAttribute:kIXLayoutFlow defaultValue:kIXLayoutFlowVertical];
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

@implementation IXTableView

@end
