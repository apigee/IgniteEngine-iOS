//
//  IXCollection.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/31/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXCollection.h"

@interface IXCollection () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView* collectionView;

@end

@implementation IXCollection

- (void)buildView
{
    [super buildView];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"IXCollectionCell"];

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
    
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IXCollectionCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor greenColor]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select");
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect");
}

@end
