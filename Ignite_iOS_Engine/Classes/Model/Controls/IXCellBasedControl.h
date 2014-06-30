//
//  IXCellBasedControl.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControl.h"

#import "IXCellBackgroundSwipeController.h"

@class IXDataRowDataProvider;
@class IXLayout;
@class IXSandbox;

@protocol IXCellContainerDelegate <NSObject>

@property (nonatomic,strong,readonly) IXCellBackgroundSwipeController* cellBackgroundSwipeController;
@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXLayout* layoutControl;
@property (nonatomic,strong) IXLayout* backgroundLayoutControl;
@property (nonatomic,assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;

-(IXPropertyContainer*)layoutPropertyContainerForCell;
-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth;

@end

@interface IXCellBasedControl : IXBaseControl <IXCellBackgroundSwipeControllerDelegate>

@property (nonatomic,weak,readonly) IXDataRowDataProvider* dataProvider;
@property (nonatomic,assign,readonly) BOOL animateReload;
@property (nonatomic,assign,readonly) CGFloat animateReloadDuration;
@property (nonatomic,assign,readonly) CGFloat backgroundViewSwipeWidth;
@property (nonatomic,assign,readonly) BOOL scrollEnabled;
@property (nonatomic,assign,readonly) BOOL pagingEnabled;
@property (nonatomic,assign,readonly) BOOL showsScrollIndicators;
@property (nonatomic,assign,readonly) UIScrollViewIndicatorStyle scrollIndicatorStyle;

@property (nonatomic,assign,readonly) BOOL pullToRefreshEnabled;
@property (nonatomic,strong,readonly) UIRefreshControl* refreshControl;

-(CGSize)itemSize;
-(NSInteger)numberOfSections;
-(NSUInteger)rowCountForSection:(NSInteger)section;

-(void)reload;
-(void)dataProviderDidUpdate:(NSNotification*)notification;
-(void)refreshControlActivated;

-(CGSize)sizeForCellAtIndexPath:(NSIndexPath*)indexPath;
-(void)configureCell:(id<IXCellContainerDelegate>)cell withIndexPath:(NSIndexPath*)indexPath;

@end
