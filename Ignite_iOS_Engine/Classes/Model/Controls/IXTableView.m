//
//  IXTableViewControl.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/18/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXTableView.h"
#import "IXBaseDataProvider.h"
#import "IXCoreDataDataProvider.h"
#import "IXSandbox.h"
#import "IXUITableViewCell.h"
#import "UIView+IXAdditions.h"
#import "IXLayout.h"
#import "IXText.h"
#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXLayoutEngine.h"
#import <RestKit/CoreData.h>

@interface IXTableView () <UITableViewDataSource,UITableViewDelegate,IXCoreDataDataProviderDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSString* dataSourceID;
@property (nonatomic, strong) IXCoreDataDataProvider* dataProvider;
@property (nonatomic, strong) NSMutableDictionary* rowSandboxes;
@property (nonatomic, strong) NSMutableDictionary* sectionNumbersAndRowCount;

@property (nonatomic, assign) NSInteger currentRowCount;
@property (nonatomic, assign) BOOL keepRowHighlightedOnSelect;

@end

@implementation IXTableView

-(void)dealloc
{
    [_dataProvider removeDelegate:self];
    [_tableView setDataSource:nil];
    [_tableView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    _rowSandboxes = [[NSMutableDictionary alloc] init];
    _sectionNumbersAndRowCount = nil;
    
    [[self contentView] addSubview:_tableView];
}

-(NSString*)getValueForDataRowIndexPath:(NSIndexPath*)indexPath forKeyPath:(NSString*)keyPath
{
    IXCoreDataDataProvider* dp = [self dataProvider];
    id value = [[[dp fetchedResultsController] objectAtIndexPath:indexPath] valueForKeyPath:@"name"];
    return value;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self tableView] setFrame:rect];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)applySettings
{
    [super applySettings];
    
    [self setDataSourceID:[[self propertyContainer] getStringPropertyValue:@"dataprovider_id" defaultValue:nil]];
    
    [[self dataProvider] removeDelegate:self];
    [self setDataProvider:((IXCoreDataDataProvider*)[[self sandbox] getDataProviderWithID:[self dataSourceID]])];
    [[self dataProvider] addDelegate:self];
    
    [[self tableView] setAllowsSelection:[[self propertyContainer] getBoolPropertyValue:@"row_select_enabled" defaultValue:YES]];
    [self setKeepRowHighlightedOnSelect:[[self propertyContainer] getBoolPropertyValue:@"keep_row_highlighted_on_select" defaultValue:NO]];

    [[self tableView] reloadData];
}

-(CGSize)getItemSize
{
    CGSize contentViewSize = [[self contentView] bounds].size;
    return CGSizeMake([[self propertyContainer] getSizeValue:@"item_width" maximumSize:contentViewSize.width defaultValue:contentViewSize.width],
                      [[self propertyContainer] getSizeValue:@"item_height" maximumSize:contentViewSize.height defaultValue:contentViewSize.height]);
}

-(NSInteger)getColumCount
{
    NSInteger columnCount = 1;
    if( [self currentRowCount] > 0 )
    {
        CGFloat tableViewsWidth = [[self tableView] bounds].size.width;
        CGFloat itemsWidth = [self getItemSize].width;
        if( itemsWidth > 0 )
        {
            columnCount = floor(tableViewsWidth/itemsWidth);
            if( columnCount * itemsWidth > tableViewsWidth )
                columnCount = 1;
        }
    }
    return columnCount;
}

-(void)coreDataProvider:(IXCoreDataDataProvider *)coreDataProvider didUpdateWithResultsController:(NSFetchedResultsController *)resultsController
{
    [self setCurrentRowCount:[[self dataProvider] getRowCount]];
    [[self tableView] reloadData];
}

#pragma mark UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemHeight = 0.0f;
    IXUITableViewCell* cell = (IXUITableViewCell*) [self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    if( [cell layoutControl] )
    {
        itemHeight = [[[cell layoutControl] contentView] bounds].size.height;
    }
    return itemHeight;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [[self dataProvider] getRowCount];
    return rowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[[self dataProvider] fetchedResultsController] sections] count];
}

-(IXLayout*)layoutForCellContentView
{
    IXLayout* layoutControl = [[IXLayout alloc] init];
    [[layoutControl contentView] setClipsToBounds:NO];
    [layoutControl setParentObject:self];
    [layoutControl setNotifyParentOfLayoutUpdates:NO];
    
    IXPropertyContainer* layoutPropertyContainer = [layoutControl propertyContainer];
    [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"margin" rawValue:@"0"]];
    [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"padding" rawValue:@"0"]];
    [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"layout_type" rawValue:@"absolute"]];
    [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"vertical_scroll_enabled" rawValue:@"NO"]];
    [layoutPropertyContainer addProperty:[IXProperty propertyWithPropertyName:@"horizontal_scroll_enabled" rawValue:@"NO"]];
    
    IXSandbox* rowSandbox = [[IXSandbox alloc] init];
    [rowSandbox setViewController:[[self sandbox] viewController]];
    [rowSandbox setContainerControl:[[self sandbox] containerControl]];
    [rowSandbox setBasePath:[[self sandbox] basePath]];
    [rowSandbox setRootPath:[[self sandbox] rootPath]];
    
    [layoutControl setSandbox:rowSandbox];
    [layoutControl addChildObjects:[[NSArray alloc] initWithArray:[self childObjects] copyItems:YES]];
    
    return layoutControl;
}

-(IXLayout*)layoutForCellBackgroundView
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IXUITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"IXUITableViewCell"];
    if( cell == nil )
    {
        cell = [[IXUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IXUITableViewCell"];
        if( cell )
        {
            [cell setClipsToBounds:YES];
            [cell setBackgroundColor:[UIColor clearColor]];
            [[cell contentView] removeAllSubviews];
            [[cell contentView] setBackgroundColor:[UIColor clearColor]];
            
            IXLayout *layoutControlForCellContentView = [self layoutForCellContentView];
            [cell setLayoutControl:layoutControlForCellContentView];
            [[cell contentView] addSubview:[layoutControlForCellContentView contentView]];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

    IXLayout* layout = [cell layoutControl];
    if( layout )
    {
        [[layout sandbox] setDataProviderForRowData:[self dataProvider]];
        [[layout sandbox] setIndexPathForRowData:indexPath];
        [[layout sandbox] setDataProviderManagedObjectForRowData:[[[self dataProvider] fetchedResultsController]objectAtIndexPath:indexPath]];
        
        [layout applySettings];

        // Need to apply settings first on the layout to be able to get the size for the layout.  Then we can layout.
        CGSize layoutSize = [IXLayoutEngine getControlSize:layout forLayoutSize:[self getItemSize]];
        CGRect layoutRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, layoutSize.width, layoutSize.height));

        [[layout contentView] setFrame:layoutRect];
        [layout layoutControl];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( ![self keepRowHighlightedOnSelect] )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
