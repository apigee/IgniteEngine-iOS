//
//  IXTableViewControl.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/18.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXTableView.h"
#import "IXBaseDataprovider.h"
#import "IXSandbox.h"
#import <RestKit/CoreData.h>


@interface IXTableView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSString* dataSourceID;
@property (nonatomic, strong) IXBaseDataprovider* dataProvider;

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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [[self contentView] addSubview:_tableView];
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
    [self setDataProvider:[[self sandbox] getDataProviderWithID:[self dataSourceID]]];
    [[self dataProvider] setControlListener:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    RKTweet *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    CGSize size = [[status text] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 9000)];
    return 100;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
//    id<NSFetchedResultsSectionInfo> sectionInfo = [self.dataProvider.fetchedResultsController fetchedObjects];
//    int a = [sectionInfo numberOfObjects];
    int a=   [[self.dataProvider.fetchedResultsController fetchedObjects] count];

    return  [[self.dataProvider.fetchedResultsController fetchedObjects] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *lastUpdatedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdatedAt"];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:lastUpdatedAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    if (nil == dateString) {
        dateString = @"Never";
    }
    return [NSString stringWithFormat:@"Last Load: %@", dateString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"Tweet Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 4;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"listbg.png"]];
    }
    
    @try {
        NSString* key = [[self propertyContainer] getStringPropertyValue:@"data_row_text_path" defaultValue:nil];
        [cell.textLabel setText:[[self.dataProvider.fetchedResultsController objectAtIndexPath:indexPath] valueForKeyPath:key]];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
}

-(void)poop
{
    [[self dataProvider] applySettings];
    [[self dataProvider] loadData];
}

-(void)reloadTableView
{
    [self.tableView reloadData];
//    [self performSelector:@selector(poop) withObject:nil afterDelay:2.0f];
}

@end
