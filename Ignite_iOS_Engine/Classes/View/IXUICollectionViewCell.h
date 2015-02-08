//
//  IXUICollectionViewCell.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IXCellBasedControl.h"

@class IXView;
@class IXSandbox;
@class IXCellBackgroundSwipeController;

@interface IXUICollectionViewCell : UICollectionViewCell <IXCellContainerDelegate>

@property (nonatomic,strong,readonly) IXCellBackgroundSwipeController* cellBackgroundSwipeController;
@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXView* layoutControl;
@property (nonatomic,strong) IXView* backgroundLayoutControl;
@property (nonatomic,assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;

-(IXPropertyContainer*)layoutPropertyContainerForCell;
-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth;

@end
