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
IX_STATIC_CONST_STRING kIXSectionHeaderXPath = @"section_header_xpath";
IX_STATIC_CONST_STRING kIXSectionHeaderControls = @"section_header_controls";
IX_STATIC_CONST_STRING kIXSectionHeaderHeight = @"section_header_height";
IX_STATIC_CONST_STRING kIXSectionHeaderWidth = @"section_header_width";
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
IX_STATIC_CONST_STRING kIXDataRowBasePath = @"datarow.basepath";

// IXCellBasedControl Readonly Attributes
IX_STATIC_CONST_STRING kIXRowCount = @"row.count";

// IXCellBasedControl Functions
IX_STATIC_CONST_STRING kIXPullToRefreshBegin = @"pull_to_refresh.begin";
IX_STATIC_CONST_STRING kIXPullToRefreshEnd = @"pull_to_refresh.end";

// IXCellBasedControl Events
IX_STATIC_CONST_STRING kIXPullToRefreshActivated = @"pull_to_refresh.activated";

@interface IXSandbox ()

@property (nonatomic, strong) NSMutableDictionary* dataProviders;

@end

@interface IXCellBasedControl ()

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
 
 ###    Layout container -- use me everywhere.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name                              | Type                            | Description                         | Default |
 |-----------------------------------|---------------------------------|-------------------------------------|---------|
 | layout_flow                       | *horizontal<br>vertical*        | Orientation of relative layout flow |         |
 | vertical_scroll_enabled           | *(bool)*                        | Minimum value allowed               |         |
 | horizontal_scroll_enabled         | *(bool)*                        | Minimum value allowed               |         |
 | enable_scrolls_to_top             | *(bool)*                        | Image to overlay                    |         |
 | scroll_indicator_style            | *black<br>white*                | Image to underlay                   |         |
 | background.blur                   | *extra_light<br> light<br>dark* | Image pointer                       |         |
 | background.blur.tintColor         | *(float)*                       | Maximum angle                       |         |
 | background.blur.tint.alpha        | *(float)*                       | Animation duration                  |         |
 | shows_scroll_indicators           | *(bool)*                        | Display scroll indicators?          |         |
 | shows_horizontal_scroll_indicator | *(bool)*                        | Display horizontal scroll indicator |         |
 | shows_vertical_scroll_indicator   | *(bool)*                        | Display vertical scroll indicator   |         |
 | max_zoom_scale                    | *(bool)*                        | Maximum zoom scale                  |         |
 | min_zoom_scale                    | *(float)*                       | Minimum zoom scale                  |         |
 | enable_zoom                       | *(bool)*                        | Enable zoom                         |         |
 | zoom_scale                        | *(float)*                       | Zoom scale                          |         |
 | color.gradient_top                | *(color)*                       | Gradient color top                  |         |
 | color.gradient_bottom             | *(color)*                       |                                     |         |
 
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>
>   None
 

 ##  <a name="functions">Functions</a>
>   None

 
 ##  <a name="example">Example JSON</a> 
 
    {
      "_id": "imageTest",
      "_type": "Image",
      "attributes": {
        "height": 100,
        "width": 100,
        "horizontal_alignment": "center",
        "vertical_alignment": "middle",
        "images.default": "/images/btn_notifications_25x25.png",
        "images.default.tintColor": "#a9d5c7"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

@property (nonatomic, weak) IXDataRowDataProvider* dataProvider;
@property (nonatomic, copy) NSString* dataRowBasePathForDataProvider;
@property (nonatomic, assign) BOOL animateReload;
@property (nonatomic, assign) CGFloat animateReloadDuration;
@property (nonatomic, assign) CGFloat backgroundSwipeAdjustsBackgroundAlpha;
@property (nonatomic, assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL showsScrollIndicators;
@property (nonatomic, assign) UIScrollViewIndicatorStyle scrollIndicatorStyle;
@property (nonatomic, strong) id<IXCellContainerDelegate> cellToCalculateSize;
@property (nonatomic, assign) BOOL pullToRefreshEnabled;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, strong) NSString* sectionHeaderXPath;
@property (nonatomic, strong) NSDictionary* sectionRowCounts;
@property (nonatomic, strong) NSMutableDictionary* sectionHeaderSandboxes;

@end

@implementation IXCellBasedControl

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
}

-(void)buildView
{
    [super buildView];

    [self setSectionHeaderSandboxes:[NSMutableDictionary dictionary]];
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

    [self setDataRowBasePathForDataProvider:[[self propertyContainer] getStringPropertyValue:kIXDataRowBasePath defaultValue:nil]];
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

    [self setSectionHeaderXPath:[[self propertyContainer] getStringPropertyValue:kIXSectionHeaderXPath defaultValue:nil]];
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
    NSUInteger rowsInSection = [[[self sectionRowCounts] objectForKey:[NSNumber numberWithInt:(int)section]] unsignedIntegerValue];
    return rowsInSection;
}

-(NSInteger)numberOfSections
{
    return [[self sectionRowCounts] count];
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXRowCount] )
    {
        NSUInteger rowCount = 0;
        for( NSNumber* sectionRowCount in [[self sectionRowCounts] allValues] )
        {
            rowCount += [sectionRowCount intValue];
        }
        returnValue = [NSString stringWithFormat:@"%lu",rowCount];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)reload
{
    NSMutableDictionary* sectionNumbersAndRowCount = [NSMutableDictionary dictionary];

    int rowCount = (int)[[self dataProvider] rowCount:[self dataRowBasePathForDataProvider]];
    if( [[self sectionHeaderXPath] length] <= 0 )
    {
        [sectionNumbersAndRowCount setObject:[NSNumber numberWithInt:rowCount]
                                      forKey:[NSNumber numberWithInt:0]];
    }
    else
    {
        NSUInteger numberOfRowsInSection = 0;
        NSString* lastSectionHeaderValue = nil;
        int sectionNumber = -1;
        for( int i = 0; i < rowCount; i++ )
        {
            NSString* rowHeaderValue = [[self dataProvider] rowDataForIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                                                        keyPath:[self sectionHeaderXPath]
                                                                dataRowBasePath:[self dataRowBasePathForDataProvider]];
            if( i == rowCount - 1 ) {
                if( [rowHeaderValue isEqualToString:lastSectionHeaderValue] ) {
                    numberOfRowsInSection++;
                    [sectionNumbersAndRowCount setObject:[NSNumber numberWithInt:(int)numberOfRowsInSection]
                                                  forKey:[NSNumber numberWithInt:sectionNumber]];
                } else {

                    if( sectionNumber != -1 ) {
                        [sectionNumbersAndRowCount setObject:[NSNumber numberWithInt:(int)numberOfRowsInSection]
                                                      forKey:[NSNumber numberWithInt:sectionNumber]];
                    }
                    sectionNumber++;
                    [sectionNumbersAndRowCount setObject:[NSNumber numberWithInt:1]
                                                  forKey:[NSNumber numberWithInt:sectionNumber]];

                }
            } else if( ![lastSectionHeaderValue isEqualToString:rowHeaderValue] ) {
                if( sectionNumber != -1 ) {
                    [sectionNumbersAndRowCount setObject:[NSNumber numberWithInt:(int)numberOfRowsInSection]
                                                  forKey:[NSNumber numberWithInt:sectionNumber]];
                }
                sectionNumber++;
                numberOfRowsInSection = 1;
                lastSectionHeaderValue = rowHeaderValue;
            } else {
                numberOfRowsInSection++;
            }
        }
    }

    [self setSectionRowCounts:sectionNumbersAndRowCount];
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
    [rowSandbox setCustomControlContainer:layoutControl];

    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self subControlsDictionary][kIXBackgroundControls] copyItems:YES]];
    
    return layoutControl;
}

-(IXLayout*)headerViewForSection:(NSInteger)section
{
    int row = (int)section;
    if( [self sectionRowCounts] && [[self sectionRowCounts] objectForKey:[NSNumber numberWithInt:(int)section]] != nil)
    {
        if( section > 0 )
        {
            int previousSection = (int)section - 1;
            while (previousSection >= 0) {
                @try{
                    int rowsInPreviousSection = [[[self sectionRowCounts] objectForKey:[NSNumber numberWithInt:previousSection]] intValue];
                    row += rowsInPreviousSection - 1;
                } @catch (NSException *exception) {
                }
                previousSection--;
            }
        }
    }

    IXLayout* layoutControl = nil;
    if([[self sectionHeaderXPath] length] > 0 && [self subControlsDictionary][kIXSectionHeaderControls] != nil )
    {
        IXSandbox* tableViewSandbox = [self sandbox];
        IXSandbox* sectionHeaderSandbox = [[IXSandbox alloc] initWithBasePath:[tableViewSandbox basePath]
                                                                     rootPath:[tableViewSandbox rootPath]];
        [sectionHeaderSandbox setViewController:[tableViewSandbox viewController]];
        [sectionHeaderSandbox setContainerControl:[tableViewSandbox containerControl]];
        [sectionHeaderSandbox setBasePath:[tableViewSandbox basePath]];
        [sectionHeaderSandbox setRootPath:[tableViewSandbox rootPath]];
        [sectionHeaderSandbox setDataProviders:[tableViewSandbox dataProviders]];
        [sectionHeaderSandbox setDataProviderForRowData:[self dataProvider]];
        [sectionHeaderSandbox setDataRowBasePathForRowData:[self dataRowBasePathForDataProvider]];
        [sectionHeaderSandbox setIndexPathForRowData:[NSIndexPath indexPathForRow:row inSection:0]];

        [[self sectionHeaderSandboxes] setObject:sectionHeaderSandbox forKey:[NSNumber numberWithInt:row]];

        layoutControl = [[IXLayout alloc] init];
        [[layoutControl contentView] setClipsToBounds:NO];
        [layoutControl setParentObject:self];
        [layoutControl setNotifyParentOfLayoutUpdates:NO];

        IXPropertyContainer* layoutPropertyContainer = [[IXPropertyContainer alloc] init];

        [layoutPropertyContainer addProperties:@[[IXProperty propertyWithPropertyName:@"margin" rawValue:@"0"],
                                                 [IXProperty propertyWithPropertyName:@"padding" rawValue:@"0"],
                                                 [IXProperty propertyWithPropertyName:@"width" rawValue:@"100%"],
                                                 [IXProperty propertyWithPropertyName:@"layout_type" rawValue:@"absolute"],
                                                 [IXProperty propertyWithPropertyName:@"vertical_scroll_enabled" rawValue:@"NO"],
                                                 [IXProperty propertyWithPropertyName:@"horizontal_scroll_enabled" rawValue:@"NO"]]];

        [layoutControl setPropertyContainer:layoutPropertyContainer];
        [layoutControl setActionContainer:[[self actionContainer] copy]];
        [layoutControl setSandbox:sectionHeaderSandbox];
        [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self subControlsDictionary][kIXSectionHeaderControls] copyItems:YES]];

        float height = [[self propertyContainer] getSizeValue:kIXSectionHeaderHeight
                                                  maximumSize:self.contentView.frame.size.height
                                                 defaultValue:[self itemSize].height];

        float width = [[self propertyContainer] getSizeValue:kIXSectionHeaderWidth
                                                 maximumSize:self.contentView.frame.size.width
                                                defaultValue:[self itemSize].width];

        [[layoutControl contentView] setFrame:CGRectMake(0.0f, 0.0f, width, height)];
        [layoutControl applySettings];
        [layoutControl layoutControl];
    }

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
        int indexPathSection = (int)indexPath.section;
        int indexPathRow = (int)indexPath.row;
        int row = indexPathSection;

        if( [self sectionRowCounts] && [[self sectionRowCounts] objectForKey:[NSNumber numberWithInt:indexPathSection]] != nil)
        {
            row += indexPathRow;
            if( indexPathSection > 0 )
            {
                int previousSection = indexPathSection - 1;
                while (previousSection >= 0) {
                    @try{
                        int rowsInPreviousSection = [[[self sectionRowCounts] objectForKey:[NSNumber numberWithInt:previousSection]] intValue];
                        row += rowsInPreviousSection - 1;
                    } @catch (NSException *exception) {
                    }
                    previousSection--;
                }
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            }
        }

        [[cellLayout sandbox] setDataProviderForRowData:[self dataProvider]];
        [[cellLayout sandbox] setDataRowBasePathForRowData:[self dataRowBasePathForDataProvider]];
        [[cellLayout sandbox] setIndexPathForRowData:indexPath];
        
        NSArray* childrenThatAreCustomControls = [cellLayout childrenThatAreKindOfClass:[IXCustom class]];
        for( IXCustom* customControl in childrenThatAreCustomControls )
        {
            [[customControl sandbox] setDataProviderForRowData:[self dataProvider]];
            [[customControl sandbox] setDataRowBasePathForRowData:[self dataRowBasePathForDataProvider]];
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
