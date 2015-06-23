//
//  IXCellBasedControl.h
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

-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth;

@end

@interface IXCellBasedControl : IXBaseControl <IXCellBackgroundSwipeControllerDelegate>

@property (nonatomic,weak,readonly) IXDataRowDataProvider* dataProvider;
@property (nonatomic,assign,readonly) BOOL animateReload;
@property (nonatomic,assign,readonly) CGFloat animateReloadDuration;
@property (nonatomic,assign,readonly) BOOL scrollEnabled;
@property (nonatomic,assign,readonly) BOOL pagingEnabled;
@property (nonatomic,assign,readonly) BOOL showsVertScrollIndicators;
@property (nonatomic,assign,readonly) BOOL showsHorizScrollIndicators;
@property (nonatomic,assign,readonly) UIScrollViewIndicatorStyle scrollIndicatorStyle;
@property (nonatomic, assign) CGFloat backgroundViewSwipeWidth;

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
-(IXLayout*)headerViewForSection:(NSInteger)section;

@end
