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
#import "IXCoreDataDataProvider.h"

@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,IXCoreDataDataProviderDelegate>

@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSString* dataSourceID;
@property (nonatomic, strong) IXCoreDataDataProvider* dataProvider;

@end

@implementation IXCollection

- (void)buildView
{
    [super buildView];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView registerClass:[IXUICollectionViewCell class] forCellWithReuseIdentifier:@"IXCollectionCell"];

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
    
    [self setDataSourceID:[[self propertyContainer] getStringPropertyValue:@"dataprovider_id" defaultValue:nil]];
    
    [[self dataProvider] removeDelegate:self];
    [self setDataProvider:((IXCoreDataDataProvider*)[[self sandbox] getDataProviderWithID:[self dataSourceID]])];
    [[self dataProvider] addDelegate:self];
    
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return [[[[self dataProvider] fetchedResultsController] sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [[self dataProvider] getRowCount];
    return rowsInSection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

-(IXLayout*)layoutForCell:(IXUICollectionViewCell*)cell
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    [layoutControl setActionContainer:[[self actionContainer] copy]];

    IXPropertyContainer* layoutPropertyContainer = [[IXPropertyContainer alloc] init];
    [layoutControl setPropertyContainer:layoutPropertyContainer];
    [layoutPropertyContainer addProperties:@[[IXProperty propertyWithPropertyName:@"margin" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"padding" rawValue:@"0"],
                                             [IXProperty propertyWithPropertyName:@"layout_type" rawValue:@"absolute"],
                                             [IXProperty propertyWithPropertyName:@"vertical_scroll_enabled" rawValue:@"NO"],
                                             [IXProperty propertyWithPropertyName:@"horizontal_scroll_enabled" rawValue:@"NO"]]];
    
    IXSandbox* tableViewSandbox = [self sandbox];
    IXSandbox* rowSandbox = [[IXSandbox alloc] initWithBasePath:[tableViewSandbox basePath] rootPath:[tableViewSandbox rootPath]];
    [rowSandbox setViewController:[tableViewSandbox viewController]];
    [rowSandbox setContainerControl:[tableViewSandbox containerControl]];
    [rowSandbox setBasePath:[tableViewSandbox basePath]];
    [rowSandbox setRootPath:[tableViewSandbox rootPath]];
    
    // FIXME: NEED TO DO MEMORY CHECK ON THIS!!
    [cell setCellSandbox:rowSandbox];
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self childObjects] copyItems:YES]];
    
    return layoutControl;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IXUICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IXCollectionCell" forIndexPath:indexPath];
    if( cell )
    {
        // FIXME: Dont need to recreate the layout each time but something is up with the sandbox shit that needs to get fixed.
        [cell setClipsToBounds:YES];
        [cell setBackgroundColor:[UIColor clearColor]];
        [[cell contentView] removeAllSubviews];
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
            
        IXLayout *layoutControlForCellContentView = [self layoutForCell:cell];
        [cell setCellSandbox:[layoutControlForCellContentView sandbox]];
        [cell setLayoutControl:layoutControlForCellContentView];
        [[cell contentView] addSubview:[[cell layoutControl] contentView]];
    }
    
    IXLayout* cellLayout = [cell layoutControl];
    if( cellLayout )
    {
        @try {
            [[cellLayout sandbox] setIndexPathForRowData:indexPath];
            [[cellLayout sandbox] setDataProviderManagedObjectForRowData:[[[self dataProvider] fetchedResultsController] objectAtIndexPath:indexPath]];
            [[cellLayout sandbox] setDataProviderForRowData:[self dataProvider]];
        }
        @catch (NSException *exception) {
        }

        // Need to apply settings first on the layout to be able to get the size for the layout.  Then we can layout.
        [cellLayout applySettings];
        
        CGSize layoutSize = [IXLayoutEngine getControlSize:cellLayout forLayoutSize:[self getItemSize]];
        CGRect layoutRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, layoutSize.width, layoutSize.height));
        
        [[cellLayout contentView] setFrame:layoutRect];
        [[cellLayout contentView] setBackgroundColor:[UIColor whiteColor]];
        [cellLayout layoutControl];
    }
    
    return cell;
}

-(CGSize)getItemSize
{
    CGSize contentViewSize = [[self contentView] bounds].size;
    return CGSizeMake([[self propertyContainer] getSizeValue:@"item_width" maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                      [[self propertyContainer] getSizeValue:@"item_height" maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select");
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect");
}

-(void)coreDataProvider:(IXCoreDataDataProvider *)coreDataProvider didUpdateWithResultsController:(NSFetchedResultsController *)resultsController
{
//    [self setCurrentRowCount:[[self dataProvider] getRowCount]];
    [[self collectionView] reloadData];
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
