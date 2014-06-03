//
//  IXTableViewControl.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/18/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXTableView.h"
#import "IXBaseDataProvider.h"
#import "IXSandbox.h"
#import "IXUITableViewCell.h"
#import "UIView+IXAdditions.h"
#import "IXLayout.h"
#import "IXText.h"
#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXLayoutEngine.h"
#import "IXCustom.h"
#import "UIScrollView+APParallaxHeader.h"
#import <RestKit/CoreData.h>

static NSString* const kIXDataproviderID = @"dataprovider_id";
static NSString* const kIXLayoutFlow = @"layout_flow";
static NSString* const kIXEnableScrollIndicators = @"enable_scroll_indicators";
static NSString* const kIXImageParallax = @"image.parallax";
static NSString* const kIXImageParallaxHeight = @"image.parallax.height";

static NSString* const kIXWillDisplayCell = @"will_display_cell";
static NSString* const kIXDidHideCell = @"did_hide_cell";
static NSString* const kIXStartedScrolling = @"started_scrolling";
static NSString* const kIXEndedScrolling = @"ended_scrolling";
static NSString* const kIXBackgroundControls = @"background_controls";

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@interface IXTableView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSString* dataSourceID;
@property (nonatomic, weak) IXBaseDataProvider* dataProvider;
@property (nonatomic, strong) NSMutableDictionary* sectionNumbersAndRowCount;

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) NSInteger currentRowCount;
@property (nonatomic, assign) BOOL keepRowHighlightedOnSelect;
@property (nonatomic, assign) BOOL animateReload;
@property (nonatomic, assign) CGFloat animateReloadDuration;
@property (nonatomic, assign) CGFloat backgroundViewSwipeWidth;

@property (nonatomic, strong) IXUITableViewCell *cellToCalculateHeight;
@property (nonatomic, strong) IXLayout *cellLayoutToCalculateHeight;


@end

@implementation IXTableView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
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

    _sectionNumbersAndRowCount = nil;
    
    [[self contentView] addSubview:_tableView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self tableView] setFrame:rect];
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXImageParallax] )
    {
        CGSize contentViewSize = [[self contentView] bounds].size;
        CGFloat parallaxHeight = [[self propertyContainer] getSizeValue:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
        [[self tableView] addParallaxWithImage:[[[[self tableView] parallaxView] imageView] image] andHeight:parallaxHeight];
    }
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    [self setDataSourceID:[[self propertyContainer] getStringPropertyValue:kIXDataproviderID defaultValue:nil]];
    
    __weak typeof(self) weakSelf = self;
    [[self propertyContainer] getImageProperty:kIXImageParallax
                                  successBlock:^(UIImage *image) {
                                      
                                      CGSize contentViewSize = [[self contentView] bounds].size;
                                      CGFloat parallaxHeight = [[self propertyContainer] getSizeValue:kIXImageParallaxHeight maximumSize:contentViewSize.height defaultValue:0.0f];
                                      
                                      [[weakSelf tableView] addParallaxWithImage:image andHeight:parallaxHeight];
                                      [[[weakSelf tableView] parallaxView] layoutIfNeeded];
                                      
                                  } failBlock:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IXBaseDataProviderDidUpdateNotification object:[self dataProvider]];

    [self setDataProvider:[[self sandbox] getDataProviderWithID:[self dataSourceID]]];
    
    if( [self dataProvider] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataProviderNotification:)
                                                     name:IXBaseDataProviderDidUpdateNotification
                                                   object:[self dataProvider]];
    }
    
    NSString* seperatorStyle = [[self propertyContainer] getStringPropertyValue:@"separator.style" defaultValue:kIX_DEFAULT];
    if( [seperatorStyle isEqualToString:@"none"] ) {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [[self tableView] setSeparatorColor:[[self propertyContainer] getColorPropertyValue:@"seperator.color" defaultValue:[UIColor grayColor]]];
    }
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:@"vertical"];
    if ([layoutFlow isEqualToString:@"horizontal"])
    {
        [[self tableView] setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    }
    if (![[self propertyContainer] getBoolPropertyValue:kIXEnableScrollIndicators defaultValue:true])
    {
        [[self tableView] setShowsHorizontalScrollIndicator:false];
        [[self tableView] setShowsVerticalScrollIndicator:false];
    }
    
    [[self tableView] setScrollEnabled:[[self propertyContainer] getBoolPropertyValue:@"scrollable" defaultValue:YES]];
    [[self tableView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:@"background.color" defaultValue:[UIColor clearColor]]];
    
    [[self tableView] setAllowsSelection:[[self propertyContainer] getBoolPropertyValue:@"row_select_enabled" defaultValue:YES]];
    [self setKeepRowHighlightedOnSelect:[[self propertyContainer] getBoolPropertyValue:@"keep_row_highlighted_on_select" defaultValue:NO]];
    [self setAnimateReload:[[self propertyContainer] getBoolPropertyValue:@"animate_reload" defaultValue:NO]];
    [self setAnimateReloadDuration:[[self propertyContainer] getFloatPropertyValue:@"animate_reload.duration" defaultValue:0.2f]];

    [self setBackgroundViewSwipeWidth:[[self propertyContainer] getFloatPropertyValue:@"background_swipe_width" defaultValue:100.0f]];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self startTableViewReload];
    });
}

-(void)startTableViewReload
{
    [self setItemSize:[self getItemSize]];
    
    if( [self animateReload] && [self animateReloadDuration] > 0.0f )
    {
        [UIView transitionWithView:[self tableView]
                          duration:[self animateReloadDuration]
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseOut
                        animations: ^(void) {
                            [self.tableView reloadData];
                        } completion: ^(BOOL isFinished) {
                        }];
    }
    else
    {
        [[self tableView] reloadData];
    }
}

-(CGSize)getItemSize
{
    CGSize contentViewSize = [[self contentView] bounds].size;
    return CGSizeMake([[self propertyContainer] getSizeValue:@"item_width" maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                      [[self propertyContainer] getSizeValue:@"item_height" maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
}

-(void)dataProviderNotification:(NSNotification*)notification
{
    [self setCurrentRowCount:[[self dataProvider] rowCount]];
    [self startTableViewReload];
}

#pragma mark UITableViewDataSource methods

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemHeight = [self heightForCellAtIndexPath:indexPath];
    return itemHeight;
}

- (float)heightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    if( [self cellToCalculateHeight] == nil )
    {
        [self setCellToCalculateHeight:[[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]];
        [self setCellLayoutToCalculateHeight:[self layoutForCell:[self cellToCalculateHeight]]];
    }
    
    IXLayout *cellLayout = [self cellLayoutToCalculateHeight];
    if( cellLayout )
    {
        [[cellLayout sandbox] setDataProviderForRowData:[self dataProvider]];
        [[cellLayout sandbox] setIndexPathForRowData:indexPath];
        
        NSArray* childrenThatAreCustomControls = [cellLayout childrenThatAreKindOfClass:[IXCustom class]];
        for( IXCustom* customControl in childrenThatAreCustomControls )
        {
            [[customControl sandbox] setDataProviderForRowData:[self dataProvider]];
            [[customControl sandbox] setIndexPathForRowData:indexPath];
        }
        [cellLayout applySettings];
        
        // Need to apply settings first on the layout to be able to get the size for the layout.  Then we can layout.
        CGSize layoutSize = [IXLayoutEngine getControlSize:cellLayout forLayoutSize:[self itemSize]];
        CGRect layoutRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, layoutSize.width, layoutSize.height));
        
        [[cellLayout contentView] setFrame:layoutRect];
        [cellLayout layoutControl];
    }
    return [[cellLayout contentView] bounds].size.height;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [[self dataProvider] rowCount];
    return rowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(IXLayout*)layoutForCell:(IXUITableViewCell*)cell
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    [layoutControl setActionContainer:[[self actionContainer] copy]];
    
    NSString* backgroundColor = [[self propertyContainer] getStringPropertyValue:@"background.color" defaultValue:@""];
    IXPropertyContainer* layoutPropertyContainer = [[IXPropertyContainer alloc] init];
    [layoutControl setPropertyContainer:layoutPropertyContainer];
    [layoutPropertyContainer addProperties:@[[IXProperty propertyWithPropertyName:@"margin" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"padding" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"width" rawValue:@"100%"],
                                             [IXProperty propertyWithPropertyName:@"layout_type" rawValue:@"absolute"],
                                             [IXProperty propertyWithPropertyName:@"vertical_scroll_enabled" rawValue:@"NO"],
                                             [IXProperty propertyWithPropertyName:@"horizontal_scroll_enabled" rawValue:@"NO"],
                                             [IXProperty propertyWithPropertyName:@"background.color" rawValue:backgroundColor]]];
    
    IXSandbox* tableViewSandbox = [self sandbox];
    IXSandbox* rowSandbox = [[IXSandbox alloc] initWithBasePath:[tableViewSandbox basePath] rootPath:[tableViewSandbox rootPath]];
    [rowSandbox setViewController:[tableViewSandbox viewController]];
    [rowSandbox setContainerControl:[tableViewSandbox containerControl]];
    [rowSandbox setBasePath:[tableViewSandbox basePath]];
    [rowSandbox setRootPath:[tableViewSandbox rootPath]];
    [rowSandbox setDataProviders:[tableViewSandbox dataProviders]];
    
    // FIXME: NEED TO DO MEMORY CHECK ON THIS!!
    [cell setCellSandbox:rowSandbox];
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self childObjects] copyItems:YES]];
    
    return layoutControl;
}

-(IXLayout*)backgroundViewForCellWithRowSandbox:(IXSandbox*)rowSandbox
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    
    IXPropertyContainer* layoutPropertyContainer = [[IXPropertyContainer alloc] init];
    [layoutControl setPropertyContainer:layoutPropertyContainer];
    [layoutControl setActionContainer:[[self actionContainer] copy]];

    [layoutPropertyContainer addProperties:@[[IXProperty propertyWithPropertyName:@"margin" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"padding" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"width" rawValue:@"100%"],
                                             [IXProperty propertyWithPropertyName:@"layout_type" rawValue:@"absolute"],
                                             [IXProperty propertyWithPropertyName:@"vertical_scroll_enabled" rawValue:@"NO"],
                                             [IXProperty propertyWithPropertyName:@"horizontal_scroll_enabled" rawValue:@"NO"]]];
    
    // FIXME: NEED TO DO MEMORY CHECK ON THIS!!
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self subControlsDictionary][kIXBackgroundControls] copyItems:YES]];
    
    return layoutControl;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kIXCellIdentifier = @"IXUITableViewCell";
    IXUITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kIXCellIdentifier];
    if( cell == nil )
    {
        cell = [[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIXCellIdentifier];
        if( cell )
        {
            [cell setClipsToBounds:YES];
            [cell setBackgroundColor:[UIColor clearColor]];
            [[cell contentView] removeAllSubviews];
            [[cell contentView] setBackgroundColor:[[self tableView] backgroundColor]];
            
            IXLayout *layoutControlForCellContentView = [self layoutForCell:cell];
            [cell setLayoutControl:layoutControlForCellContentView];
        }
    }
    
    NSString* layoutFlow = [[self propertyContainer] getStringPropertyValue:kIXLayoutFlow defaultValue:@"vertical"];
    if ([layoutFlow isEqualToString:@"horizontal"])
    {
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

    IXLayout* cellLayout = [cell layoutControl];
    if( cellLayout )
    {
        [[cellLayout sandbox] setDataProviderForRowData:[self dataProvider]];
        [[cellLayout sandbox] setIndexPathForRowData:indexPath];
        
        NSArray* childrenThatAreCustomControls = [cellLayout childrenThatAreKindOfClass:[IXCustom class]];
        for( IXCustom* customControl in childrenThatAreCustomControls )
        {
            [[customControl sandbox] setDataProviderForRowData:[self dataProvider]];
            [[customControl sandbox] setIndexPathForRowData:indexPath];
        }
        [cellLayout applySettings];

        // Need to apply settings first on the layout to be able to get the size for the layout.  Then we can layout.
        CGSize layoutSize = [IXLayoutEngine getControlSize:cellLayout forLayoutSize:[self itemSize]];
        CGRect layoutRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, layoutSize.width, layoutSize.height));

        [[cellLayout contentView] setFrame:layoutRect];
        [cellLayout layoutControl];
        
        IXLayout* backgroundLayoutControl = [cell backgroundLayoutControl];
        if( backgroundLayoutControl != nil )
        {
            [backgroundLayoutControl setSandbox:[cellLayout sandbox]];
            [backgroundLayoutControl applySettings];
            [[backgroundLayoutControl contentView] setFrame:layoutRect];
            [backgroundLayoutControl layoutControl];
        }
        else if( [[self subControlsDictionary][kIXBackgroundControls] count] > 0 )
        {
            IXLayout* backgroundLayoutControl = [self backgroundViewForCellWithRowSandbox:[cellLayout sandbox]];
            [cell setBackgroundLayoutControl:backgroundLayoutControl];
            
            [backgroundLayoutControl applySettings];
            [[backgroundLayoutControl contentView] setFrame:layoutRect];
            [backgroundLayoutControl layoutControl];
        }
        
        [cell setSwipeWidth:[self backgroundViewSwipeWidth]];
        [cell enablePanGesture:( [cell backgroundLayoutControl] != nil )];
    }
    
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for( IXUITableViewCell* cell in [[self tableView] visibleCells] )
    {
        [cell resetCellPosition];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXStartedScrolling];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[self actionContainer] executeActionsForEventNamed:kIXEndedScrolling];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( ![self keepRowHighlightedOnSelect] )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    // TableView doesnt need to fire any touch actions.
}
-(void)processBeginTouch:(BOOL)fireTouchActions
{
    // TableView doesnt need to fire any touch actions.
}

@end
