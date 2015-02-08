//
//  IXUITableViewCell.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IXCellBasedControl.h"

@class IXLayout;
@class IXSandbox;

@interface IXUITableViewCell : UITableViewCell <IXCellContainerDelegate>

@property (nonatomic,assign) BOOL forceSize;
@property (nonatomic,assign) CGSize forcedSize;

@property (nonatomic,strong,readonly) IXCellBackgroundSwipeController* cellBackgroundSwipeController;
@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXLayout* layoutControl;
@property (nonatomic,strong) IXLayout* backgroundLayoutControl;
@property (nonatomic,assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;

-(IXPropertyContainer*)layoutPropertyContainerForCell;
-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth;

@end
