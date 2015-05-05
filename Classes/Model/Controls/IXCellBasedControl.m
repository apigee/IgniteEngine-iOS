//
//  IXCellBasedControl.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/4/14.
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

#import "IXCellBasedControl.h"

#import "IXDataRowDataProvider.h"
#import "IXCollection.h"
#import "IXCustom.h"
#import "IXAttribute.h"
#import "IXTable.h"

#import "IXUICollectionViewCell.h"
#import "IXUITableViewCell.h"
#import "IXCellBackgroundSwipeController.h"

#import "IXLayoutEngine.h"
#import "NSString+IXAdditions.h"

// Attributes
IX_STATIC_CONST_STRING kIXAnimateReload = @"reloadAnimation.enabled";
IX_STATIC_CONST_STRING kIXAnimateReloadDuration = @"reloadAnimation.duration";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"bg.color";
IX_STATIC_CONST_STRING kIXBackgroundSwipeWidth = @"swipe.w";
IX_STATIC_CONST_STRING kIXBackgroundSlidesInFromSide = @"swipe.slideIn.enabled";
IX_STATIC_CONST_STRING kIXBackgroundSwipeAdjustsBackgroundAlpha = @"swipe.alpha.enabled";
IX_STATIC_CONST_STRING kIXBackgroundControls = @"swipe.controls";
IX_STATIC_CONST_STRING kIXSectionHeaderXPath = @"sectionHeader.xpath";
IX_STATIC_CONST_STRING kIXSectionHeaderControls = @"sectionHeader.controls";
IX_STATIC_CONST_STRING kIXSectionHeaderHeight = @"sectionHeader.size.h";
IX_STATIC_CONST_STRING kIXSectionHeaderWidth = @"sectionHeader.size.w";
IX_STATIC_CONST_STRING kIXDataproviderID = @"datasource.id";
//IX_STATIC_CONST_STRING kIXItemWidth = @"cell.size.w";
//IX_STATIC_CONST_STRING kIXItemHeight = @"cell.size.h";
IX_STATIC_CONST_STRING kIXPagingEnabled = @"paging.enabled";
IX_STATIC_CONST_STRING kIXScrollable = @"scrolling.enabled";
IX_STATIC_CONST_STRING kIXPullToRefreshEnabled = @"pullToRefresh.enabled";
IX_STATIC_CONST_STRING kIXPullToRefreshText = @"pullToRefresh.text";
IX_STATIC_CONST_STRING kIXPullToRefreshTextColor = @"pullToRefresh.color";
IX_STATIC_CONST_STRING kIXPullToRefreshTextFont = @"pullToRefresh.font";
IX_STATIC_CONST_STRING kIXPullToRefreshTintColor = @"pullToRefresh.tint";
IX_STATIC_CONST_STRING kIXScrollIndicatorStyle = @"scrollBars.style";
IX_STATIC_CONST_STRING kIXDataRowBasePath = @"data.basepath";
IX_STATIC_CONST_STRING kIXShowsScrollIndicators = @"scrollBars.enabled";
IX_STATIC_CONST_STRING kIXShowsVScrollIndicators = @"scrollBars.v.enabled";
IX_STATIC_CONST_STRING kIXShowsHScrollIndicators = @"scrollBars.h.enabled";

// Attribute Accepted Values
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleBlack = @"black"; // scrollBars.style
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleWhite = @"white"; // scrollBars.style
IX_STATIC_CONST_STRING kIXScrollIndicatorStyleDefault = @"default"; // scrollBars.style

// Returns
// TODO: Need to enhance this and include total item count, visible item count, number of items per section
IX_STATIC_CONST_STRING kIXRowCount = @"data.count";

// Functions
IX_STATIC_CONST_STRING kIXPullToRefreshBegin = @"pullToRefresh.start";
IX_STATIC_CONST_STRING kIXPullToRefreshEnd = @"pullToRefresh.end";

// Events
// TODO: Need pull to refresh start and end events
IX_STATIC_CONST_STRING kIXPullToRefreshActivated = @"pullToRefresh";

@interface IXSandbox ()

@property (nonatomic, strong) NSMutableDictionary* dataProviders;

@end

// The following properties MUST match their equivalent names specified in IXBaseControl
IX_STATIC_CONST_STRING kIXCell = @"cell"; // used as a prefix for cell size
IX_STATIC_CONST_STRING kIXCellSize = @"cell.size";
IX_STATIC_CONST_STRING kIXCellSizeHeight = @"cell.size.height";
IX_STATIC_CONST_STRING kIXSizeH = @"size.h";
IX_STATIC_CONST_STRING kIXSizeW = @"size.w";
IX_STATIC_CONST_STRING kIXMargin = @"margin";
IX_STATIC_CONST_STRING kIXPadding = @"padding";
IX_STATIC_CONST_STRING kIXLayoutType = @"layoutType";
IX_STATIC_CONST_STRING kIXLayoutTypeDefault = @"absolute";
IX_STATIC_CONST_STRING kIXVerticalScrollEnabled = @"scrolling.v.enabled";
IX_STATIC_CONST_STRING kIXHorizontalScrollEnabled = @"scrolling.h.enabled";

@interface IXCellBasedControl ()

@property (nonatomic, weak) IXDataRowDataProvider* dataProvider;
@property (nonatomic, copy) NSString* dataRowBasePathForDataProvider;
@property (nonatomic, assign) BOOL animateReload;
@property (nonatomic, assign) CGFloat animateReloadDuration;
@property (nonatomic, assign) CGFloat backgroundSwipeAdjustsBackgroundAlpha;
@property (nonatomic, assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL showsVertScrollIndicators;
@property (nonatomic, assign) BOOL showsHorizScrollIndicators;
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
    
    NSString* dataProviderID = [[self attributeContainer] getStringValueForAttribute:kIXDataproviderID defaultValue:nil];
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

    [self setDataRowBasePathForDataProvider:[[self attributeContainer] getStringValueForAttribute:kIXDataRowBasePath defaultValue:nil]];
    [self setBackgroundViewSwipeWidth:[[self attributeContainer] getFloatValueForAttribute:kIXBackgroundSwipeWidth defaultValue:100.0f]];
    [self setBackgroundSwipeAdjustsBackgroundAlpha:[[self attributeContainer] getBoolValueForAttribute:kIXBackgroundSwipeAdjustsBackgroundAlpha defaultValue:NO]];
    [self setBackgroundSlidesInFromSide:[[self attributeContainer] getBoolValueForAttribute:kIXBackgroundSlidesInFromSide defaultValue:NO]];
    [self setAnimateReload:[[self attributeContainer] getBoolValueForAttribute:kIXAnimateReload defaultValue:NO]];
    [self setAnimateReloadDuration:[[self attributeContainer] getFloatValueForAttribute:kIXAnimateReloadDuration defaultValue:0.2f]];
    [self setScrollEnabled:[[self attributeContainer] getBoolValueForAttribute:kIXScrollable defaultValue:YES]];
    [self setPagingEnabled:[[self attributeContainer] getBoolValueForAttribute:kIXPagingEnabled defaultValue:NO]];
    [self setPullToRefreshEnabled:[[self attributeContainer] getBoolValueForAttribute:kIXPullToRefreshEnabled defaultValue:NO]];

    BOOL showsScrollIndicators = [[self attributeContainer] getBoolValueForAttribute:kIXShowsScrollIndicators defaultValue:YES];
    [self setShowsHorizScrollIndicators:[[self attributeContainer] getBoolValueForAttribute:kIXShowsHScrollIndicators defaultValue:showsScrollIndicators]];
    [self setShowsVertScrollIndicators:[[self attributeContainer] getBoolValueForAttribute:kIXShowsVScrollIndicators defaultValue:showsScrollIndicators]];

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

        [[self refreshControl] setTintColor:[[self attributeContainer] getColorValueForAttribute:kIXPullToRefreshTintColor defaultValue:nil]];
        
        NSString* refreshText = [[self attributeContainer] getStringValueForAttribute:kIXPullToRefreshText defaultValue:nil];
        if( [refreshText length] > 0 )
        {
            UIFont* defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
            UIColor* refreshTextColor = [[self attributeContainer] getColorValueForAttribute:kIXPullToRefreshTextColor defaultValue:[UIColor darkGrayColor]];
            UIFont* refreshTextFont = [[self attributeContainer] getFontValueForAttribute:kIXPullToRefreshTextFont defaultValue:defaultFont];
            
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
    
    NSString* scrollIndicatorStyle = [[self attributeContainer] getStringValueForAttribute:kIXScrollIndicatorStyle defaultValue:kIXScrollIndicatorStyleDefault];
    if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleBlack] ) {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    } else if( [scrollIndicatorStyle isEqualToString:kIXScrollIndicatorStyleWhite] ) {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    } else {
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleDefault];
    }

    [self setSectionHeaderXPath:[[self attributeContainer] getStringValueForAttribute:kIXSectionHeaderXPath defaultValue:nil]];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
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
    IXSize* size = [[self attributeContainer] getSizeValueForAttributeWithPrefix:kIXCell];
    CGSize contentViewSize = [[self contentView] bounds].size;
    CGSize returnSize = CGSizeMake([[self attributeContainer] getSizeValueForAttribute:size.width maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                                   [[self attributeContainer] getSizeValueForAttribute:size.height maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
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
        } else if( [self isKindOfClass:[IXTable class]] ) {
            [self setCellToCalculateSize:[[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]];
        }
        
        [[self cellToCalculateSize] setLayoutControl:[self layoutForCell:[self cellToCalculateSize]]];
    }
    
    [self configureCell:[self cellToCalculateSize] withIndexPath:indexPath isDummy:YES];
    
    return [[[[self cellToCalculateSize] layoutControl] contentView] bounds].size;
}

+(IXAttributeContainer*)layoutPropertyContainerForCells
{
    IXAttributeContainer* layoutPropertyContainer = [[IXAttributeContainer alloc] init];
    [layoutPropertyContainer addAttributes:@[[IXAttribute attributeWithAttributeName:kIXMargin rawValue:@"0"],
                                             [IXAttribute attributeWithAttributeName:kIXPadding rawValue:@"0"],
                                             [IXAttribute attributeWithAttributeName:kIXSizeW rawValue:@"100%"],
                                             [IXAttribute attributeWithAttributeName:kIXLayoutType rawValue:kIXLayoutTypeDefault],
                                             [IXAttribute attributeWithAttributeName:kIXVerticalScrollEnabled rawValue:@"NO"],
                                             [IXAttribute attributeWithAttributeName:kIXHorizontalScrollEnabled rawValue:@"NO"]]];
    return layoutPropertyContainer;
}

-(IXLayout*)layoutForCell:(id<IXCellContainerDelegate>)cell
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    [layoutControl setActionContainer:[[self actionContainer] copy]];
    
    IXAttributeContainer* layoutPropertyContainer = [IXCellBasedControl layoutPropertyContainerForCells];
    [layoutControl setAttributeContainer:layoutPropertyContainer];

    if( [[self attributeContainer] hasLayoutAttributes] )
    {
        IXSize* size = [[self attributeContainer] getSizeValueForAttributeWithPrefix:kIXCell];
        if( [size.height length] > 0 )
        {
            [layoutPropertyContainer addAttribute:[IXAttribute attributeWithAttributeName:kIXSizeH rawValue:size.height]];
        }
    }

    if( [[self attributeContainer] attributeExistsForName:kIXBackgroundColor] )
    {
        NSString* backgroundColor = [[self attributeContainer] getStringValueForAttribute:kIXBackgroundColor defaultValue:kIX_EMPTY_STRING];
        [layoutPropertyContainer addAttribute:[IXAttribute attributeWithAttributeName:kIXBackgroundColor rawValue:backgroundColor]];
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
    
    IXAttributeContainer* layoutPropertyContainer = [IXCellBasedControl layoutPropertyContainerForCells];
    [layoutControl setAttributeContainer:layoutPropertyContainer];
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

        IXAttributeContainer* layoutPropertyContainer = [IXCellBasedControl layoutPropertyContainerForCells];
        [layoutControl setAttributeContainer:layoutPropertyContainer];
        [layoutControl setActionContainer:[[self actionContainer] copy]];
        [layoutControl setSandbox:sectionHeaderSandbox];
        [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self subControlsDictionary][kIXSectionHeaderControls] copyItems:YES]];

        float height = [[self attributeContainer] getSizeValueForAttribute:kIXSectionHeaderHeight
                                                  maximumSize:self.contentView.frame.size.height
                                                 defaultValue:[self itemSize].height];

        float width = [[self attributeContainer] getSizeValueForAttribute:kIXSectionHeaderWidth
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
