//
//  IXCollection.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/31/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXCollection.h"
#import "IXLayout.h"
#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "UIView+IXAdditions.h"
#import "IXLayoutEngine.h"
#import "IXUICollectionViewCell.h"
#import "IXSandbox.h"
#import "IXCoreDataDataProvider.h"
#import "IXCustom.h"

static NSString* const kIXDataproviderID = @"dataprovider_id";
static NSString* const kIXBackgroundColor = @"background.color";
static NSString* const kIXBackgroundControls = @"background_controls";

static NSString* const kIXStartedScrolling = @"started_scrolling";
static NSString* const kIXEndedScrolling = @"ended_scrolling";

static NSString* const kIXCellIdentifier = @"IXUICollectionViewCell";

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout* collectionViewLayout;
@property (nonatomic,strong) NSString* dataSourceID;

@property (nonatomic,weak) IXBaseDataProvider* dataProvider;
@property (nonatomic, assign) CGFloat backgroundViewSwipeWidth;

@property (nonatomic, strong) IXUICollectionViewCell *cellToCalculateSize;
@property (nonatomic, strong) IXLayout *cellLayoutToCalculateSize;

@end

@implementation IXCollection

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
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

- (CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

- (void)layoutControlContentsInRect:(CGRect)rect
{
    [_collectionView setFrame:rect];
}

- (void)applySettings
{
    [super applySettings];
    
    [self setDataSourceID:[[self propertyContainer] getStringPropertyValue:kIXDataproviderID defaultValue:nil]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    
    [self setDataProvider:[[self sandbox] getDataProviderWithID:[self dataSourceID]]];
    
    if( [self dataProvider] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataProviderNotification:)
                                                     name:IXBaseDataProviderDidUpdateNotification
                                                   object:[self dataProvider]];
    }
    
    [[self collectionView] setScrollEnabled:[[self propertyContainer] getBoolPropertyValue:@"scrollable" defaultValue:YES]];
    [[self collectionView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
    [self setBackgroundViewSwipeWidth:[[self propertyContainer] getFloatPropertyValue:@"background_swipe_width" defaultValue:100.0f]];

    [[self collectionView] reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [[self dataProvider] rowCount];
    return rowsInSection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self sizeForCellAtIndexPath:indexPath];
}

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath*)indexPath
{
    if( [self cellToCalculateSize] == nil )
    {
        [self setCellToCalculateSize:[[IXUICollectionViewCell alloc] initWithFrame:CGRectZero]];
        [self setCellLayoutToCalculateSize:[self layoutForCell:[self cellToCalculateSize]]];
    }
    
    IXLayout *cellLayout = [self cellLayoutToCalculateSize];
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
    return [[cellLayout contentView] bounds].size;
}

-(IXLayout*)layoutForCell:(IXUICollectionViewCell*)cell
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
    
    if( [[self propertyContainer] propertyExistsForPropertyNamed:@"item_height"] )
    {
        IXProperty* heightProperty = [IXProperty propertyWithPropertyName:@"height" rawValue:[NSString stringWithFormat:@"%f",[self itemSize].height]];
        [layoutPropertyContainer addProperty:heightProperty];
    }

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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IXUICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIXCellIdentifier
                                                                             forIndexPath:indexPath];
    if( cell && [cell layoutControl] == nil )
    {
        // FIXME: Dont need to recreate the layout each time but something is up with the sandbox shit that needs to get fixed.
        [cell setClipsToBounds:YES];
        [cell setBackgroundColor:[UIColor clearColor]];
        [[cell contentView] removeAllSubviews];
        
        IXLayout *layoutControlForCellContentView = [self layoutForCell:cell];
        [cell setLayoutControl:layoutControlForCellContentView];
        [[cell contentView] addSubview:[[cell layoutControl] contentView]];
    }
    
    [[cell contentView] setBackgroundColor:[[self collectionView] backgroundColor]];
    
    IXLayout* cellLayout = [cell layoutControl];
    if( cellLayout )
    {
        [[cellLayout sandbox] setIndexPathForRowData:indexPath];
        [[cellLayout sandbox] setDataProviderForRowData:[self dataProvider]];
        
        NSArray* childrenThatAreCustomControls = [cellLayout childrenThatAreKindOfClass:[IXCustom class]];
        for( IXCustom* customControl in childrenThatAreCustomControls )
        {
            [[customControl sandbox] setDataProviderForRowData:[self dataProvider]];
            [[customControl sandbox] setIndexPathForRowData:indexPath];
        }

        // Need to apply settings first on the layout to be able to get the size for the layout.  Then we can layout.
        [cellLayout applySettings];
        
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

-(CGSize)itemSize
{
    CGSize contentViewSize = [[self contentView] bounds].size;
    CGSize returnSize = CGSizeMake([[self propertyContainer] getSizeValue:@"item_width" maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                                   [[self propertyContainer] getSizeValue:@"item_height" maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
    return returnSize;
}

-(void)dataProviderNotification:(NSNotification*)notification
{
    [[self collectionView] reloadData];
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    // Collection doesn't need to fire any touch actions.
}
-(void)processBeginTouch:(BOOL)fireTouchActions
{
    // Collection doesn't need to fire any touch actions.
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for( IXUICollectionViewCell* cell in [[self collectionView] visibleCells] )
    {
        [cell resetCellPosition];
    }
    
    [[self actionContainer] executeActionsForEventNamed:kIXStartedScrolling];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[self actionContainer] executeActionsForEventNamed:kIXEndedScrolling];
}


@end
