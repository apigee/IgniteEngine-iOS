//
//  IXCellBasedControl.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCellBasedControl.h"

#import "IXDataRowDataProvider.h"
#import "IXCollection.h"
#import "IXCustom.h"
#import "IXLayoutEngine.h"
#import "IXProperty.h"
#import "IXTableView.h"

#import "IXUICollectionViewCell.h"
#import "IXUITableViewCell.h"
#import "IXCellBackgroundSwipeController.h"

#import "NSString+IXAdditions.h"

// IXCellBasedControl Attributes
IX_STATIC_CONST_STRING kIXAnimateReload = @"animate_reload";
IX_STATIC_CONST_STRING kIXAnimateReloadDuration = @"animate_reload.duration";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"background.color";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"background_swipe_width";
IX_STATIC_CONST_STRING kIXBackgroundSlidesInFromSide = @"background_slides_in_from_side";
IX_STATIC_CONST_STRING kIXBackgroundSwipeAdjustsBackgroundAlpha = @"background_swipe_adjusts_background_alpha";
IX_STATIC_CONST_STRING kIXBackgroundControls = @"background_controls";
IX_STATIC_CONST_STRING kIXDataproviderID = @"dataprovider_id";
IX_STATIC_CONST_STRING kIXItemWidth = @"item_width";
IX_STATIC_CONST_STRING kIXItemHeight = @"item_height";
IX_STATIC_CONST_STRING kIXPagingEnabled = @"paging.enabled";
IX_STATIC_CONST_STRING kIXScrollable = @"scrollable";
IX_STATIC_CONST_STRING kIXPullToRefreshEnabled = @"pull_to_refresh.enabled";
IX_STATIC_CONST_STRING kIXPullToRefreshText = @"pull_to_refresh.text";
IX_STATIC_CONST_STRING kIXPullToRefreshTextColor = @"pull_to_refresh.text.color";
IX_STATIC_CONST_STRING kIXPullToRefreshTextFont = @"pull_to_refresh.text.font";
IX_STATIC_CONST_STRING kIXPullToRefreshTintColor = @"pull_to_refresh.tint.color";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyle = @"scroll_indicator_style";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleBlack = @"black";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleWhite = @"white";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleDefault = @"default";
IX_STATIC_CONST_STRING kIXShowsScrollIndicators = @"shows_scroll_indicators";

// IXCellBasedControl Functions
IX_STATIC_CONST_STRING kIXPullToRefreshBegin = @"pull_to_refresh.begin";
IX_STATIC_CONST_STRING kIXPullToRefreshEnd = @"pull_to_refresh.end";

// IXCellBasedControl Events
IX_STATIC_CONST_STRING kIXPullToRefreshActivated = @"pull_to_refresh.activated";

@interface IXSandbox ()

@property (nonatomic, strong) NSMutableDictionary* dataProviders;

@end

@interface IXCellBasedControl ()

@property (nonatomic, weak) IXDataRowDataProvider* dataProvider;
@property (nonatomic, assign) BOOL animateReload;
@property (nonatomic, assign) CGFloat animateReloadDuration;
@property (nonatomic, assign) CGFloat backgroundViewSwipeWidth;
@property (nonatomic, assign) CGFloat backgroundSwipeAdjustsBackgroundAlpha;
@property (nonatomic, assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL showsScrollIndicators;
@property (nonatomic, assign) UIScrollViewIndicatorStyle scrollIndicatorStyle;
@property (nonatomic, strong) id<IXCellContainerDelegate> cellToCalculateSize;
@property (nonatomic, assign) BOOL pullToRefreshEnabled;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation IXCellBasedControl

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* dataProviderID = [[self propertyContainer] getStringPropertyValue:kIXDataproviderID defaultValue:nil];
    IXDataRowDataProvider* dataProvider = [[self sandbox] getDataRowDataProviderWithID:dataProviderID];
    
    if( [self dataProvider] != dataProvider )
    {
        if( [self dataProvider] != nil )
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:IXBaseDataProviderDidUpdateNotification
                                                          object:[self dataProvider]];
        }
        
        [self setDataProvider:dataProvider];
        if( [self dataProvider] != nil )
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dataProviderDidUpdate:)
                                                         name:IXBaseDataProviderDidUpdateNotification
                                                       object:[self dataProvider]];
        }
    }
    
    [self setBackgroundViewSwipeWidth:[[self propertyContainer] getFloatPropertyValue:kIXBackgroundSwipeWidth defaultValue:100.0f]];
    [self setBackgroundSwipeAdjustsBackgroundAlpha:[[self propertyContainer] getBoolPropertyValue:kIXBackgroundSwipeAdjustsBackgroundAlpha defaultValue:NO]];
    [self setBackgroundSlidesInFromSide:[[self propertyContainer] getBoolPropertyValue:kIXBackgroundSlidesInFromSide defaultValue:NO]];
    [self setAnimateReload:[[self propertyContainer] getBoolPropertyValue:kIXAnimateReload defaultValue:NO]];
    [self setAnimateReloadDuration:[[self propertyContainer] getFloatPropertyValue:kIXAnimateReloadDuration defaultValue:0.2f]];
    [self setScrollEnabled:[[self propertyContainer] getBoolPropertyValue:kIXScrollable defaultValue:YES]];
    [self setShowsScrollIndicators:[[self propertyContainer] getBoolPropertyValue:kIXShowsScrollIndicators defaultValue:YES]];
    [self setPagingEnabled:[[self propertyContainer] getBoolPropertyValue:kIXPagingEnabled defaultValue:NO]];
    [self setPullToRefreshEnabled:[[self propertyContainer] getBoolPropertyValue:kIXPullToRefreshEnabled defaultValue:NO]];
    
    if( [self pullToRefreshEnabled] )
    {
        if( [self refreshControl] == nil )
        {
            [self setRefreshControl:[[UIRefreshControl alloc] init]];
            [[self refreshControl] addTarget:self action:@selector(refreshControlActivated) forControlEvents:UIControlEventValueChanged];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self refreshControl] beginRefreshing];
                [[self refreshControl] endRefreshing];
            });
        }

        [[self refreshControl] setTintColor:[[self propertyContainer] getColorPropertyValue:kIXPullToRefreshTintColor defaultValue:nil]];
        
        NSString* refreshText = [[self propertyContainer] getStringPropertyValue:kIXPullToRefreshText defaultValue:nil];
        if( [refreshText length] > 0 )
        {
            UIFont* defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
            UIColor* refreshTextColor = [[self propertyContainer] getColorPropertyValue:kIXPullToRefreshTextColor defaultValue:[UIColor darkGrayColor]];
            UIFont* refreshTextFont = [[self propertyContainer] getFontPropertyValue:kIXPullToRefreshTextFont defaultValue:defaultFont];
            
            NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:refreshText
                                                                                  attributes:@{NSForegroundColorAttributeName: refreshTextColor,
                                                                                               NSFontAttributeName:refreshTextFont}];
            [[self refreshControl] setAttributedTitle:attributedTitle];
        }
        else
        {
            [[self refreshControl] setAttributedTitle:nil];
        }
    }
    else
    {
        [[self refreshControl] removeFromSuperview];
        [self setRefreshControl:nil];
    }
    
    NSString* scrollIndicatorStyle = [[self propertyContainer] getStringPropertyValue:kIXScrollIndicatorStyle defaultValue:kIXScrollIndicatorStyleDefault];
    if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleBlack] ) {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    } else if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleWhite] ) {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    } else {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleDefault];
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXPullToRefreshEnd] )
    {
        [[self refreshControl] endRefreshing];
    }
    else if( [functionName isEqualToString:kIXPullToRefreshBegin] )
    {
        [[self refreshControl] beginRefreshing];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(CGSize)itemSize
{
    CGSize contentViewSize = [[self contentView] bounds].size;
    CGSize returnSize = CGSizeMake([[self propertyContainer] getSizeValue:kIXItemWidth maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                                   [[self propertyContainer] getSizeValue:kIXItemHeight maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
    return returnSize;
}

-(NSUInteger)rowCountForSection:(NSInteger)section
{
    NSUInteger rowsInSection = [[self dataProvider] rowCount];
    return rowsInSection;
}

-(NSInteger)numberOfSections
{
    return 1;
}

-(void)reload
{
    // The base implementation of this does nothing.
}

-(void)dataProviderDidUpdate:(NSNotification*)notification
{
    [self reload];
}

-(void)refreshControlActivated
{
    [[self actionContainer] executeActionsForEventNamed:kIXPullToRefreshActivated];
}

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath*)indexPath
{
    if( [self cellToCalculateSize] == nil )
    {
        if( [self isKindOfClass:[IXCollection class]] ) {
            [self setCellToCalculateSize:[[IXUICollectionViewCell alloc] initWithFrame:CGRectZero]];
        } else if( [self isKindOfClass:[IXTableView class]] ) {
            [self setCellToCalculateSize:[[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]];
        }
        
        [[self cellToCalculateSize] setLayoutControl:[self layoutForCell:[self cellToCalculateSize]]];
    }
    
    [self configureCell:[self cellToCalculateSize] withIndexPath:indexPath isDummy:YES];
    
    return [[[[self cellToCalculateSize] layoutControl] contentView] bounds].size;
}

-(IXLayout*)layoutForCell:(id<IXCellContainerDelegate>)cell
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    [layoutControl setActionContainer:[[self actionContainer] copy]];
    
    IXPropertyContainer* layoutPropertyContainer = [cell layoutPropertyContainerForCell];
    [layoutControl setPropertyContainer:layoutPropertyContainer];

    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXItemHeight] )
    {
        NSString* itemHeight = [[self propertyContainer] getStringPropertyValue:kIXItemHeight defaultValue:nil];
        if( [itemHeight length] > 0 )
        {
            [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"height" rawValue:itemHeight]];
        }
    }

    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXBackgroundColor] )
    {
        NSString* backgroundColor = [[self propertyContainer] getStringPropertyValue:kIXBackgroundColor defaultValue:kIX_EMPTY_STRING];
        [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:kIXBackgroundColor rawValue:backgroundColor]];
    }
    
    IXSandbox* tableViewSandbox = [self sandbox];
    IXSandbox* rowSandbox = [[IXSandbox alloc] initWithBasePath:[tableViewSandbox basePath] rootPath:[tableViewSandbox rootPath]];
    [rowSandbox setViewController:[tableViewSandbox viewController]];
    [rowSandbox setContainerControl:[tableViewSandbox containerControl]];
    [rowSandbox setBasePath:[tableViewSandbox basePath]];
    [rowSandbox setRootPath:[tableViewSandbox rootPath]];
    [rowSandbox setDataProviders:[tableViewSandbox dataProviders]];
    
    [cell setCellSandbox:rowSandbox];
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self childObjects] copyItems:YES]];
    
    return layoutControl;
}

-(IXLayout*)backgroundViewForCell:(id<IXCellContainerDelegate>)cell withRowSandbox:(IXSandbox*)rowSandbox
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    
    IXPropertyContainer* layoutPropertyContainer = [cell layoutPropertyContainerForCell];
    [layoutControl setPropertyContainer:layoutPropertyContainer];
    [layoutControl setActionContainer:[[self actionContainer] copy]];
    
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self subControlsDictionary][kIXBackgroundControls] copyItems:YES]];
    
    return layoutControl;
}

-(void)configureCell:(id<IXCellContainerDelegate>)cell withIndexPath:(NSIndexPath*)indexPath
{
    [self configureCell:cell withIndexPath:indexPath isDummy:NO];
}

-(void)configureCell:(id<IXCellContainerDelegate>)cell withIndexPath:(NSIndexPath*)indexPath isDummy:(BOOL)isDummy
{
    IXLayout* cellLayout = [cell layoutControl];
    if( cellLayout == nil )
    {
        [cell setLayoutControl:[self layoutForCell:cell]];
        cellLayout = [cell layoutControl];
    }
    
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
        
        if( !isDummy )
        {
            [cell setBackgroundSlidesInFromSide:[self backgroundSlidesInFromSide]];
            
            IXLayout* backgroundLayoutControl = [cell backgroundLayoutControl];
            if( backgroundLayoutControl != nil )
            {
                [backgroundLayoutControl setSandbox:[cellLayout sandbox]];
                [backgroundLayoutControl applySettings];
                [[backgroundLayoutControl contentView] setFrame:layoutRect];
                [backgroundLayoutControl layoutControl];
                
                [cell setBackgroundLayoutControl:backgroundLayoutControl];
            }
            else if( [[self subControlsDictionary][kIXBackgroundControls] count] > 0 )
            {
                IXLayout* backgroundLayoutControl = [self backgroundViewForCell:cell withRowSandbox:[cellLayout sandbox]];
                
                [backgroundLayoutControl applySettings];
                [[backgroundLayoutControl contentView] setFrame:layoutRect];
                [backgroundLayoutControl layoutControl];
                
                [cell setBackgroundLayoutControl:backgroundLayoutControl];
            }
            [cell setAdjustsBackgroundAlphaWithSwipe:[self backgroundSwipeAdjustsBackgroundAlpha]];
            [cell enableBackgroundSwipe:( [cell backgroundLayoutControl] != nil ) swipeWidth:[self backgroundViewSwipeWidth]];
            [[cell cellBackgroundSwipeController] setDelegate:self];
        }
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    // Cell based controls doesn't need to fire any touch actions.
}

-(void)processBeginTouch:(BOOL)fireTouchActions
{
    // Cell based controls doesn't need to fire any touch actions.
}

@end
