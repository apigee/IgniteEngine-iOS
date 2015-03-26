//
//  IXUICollectionViewCell.h
//  Ignite Engine
//
//  Created by Robert Walsh on 1/21/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IXCellBasedControl.h"

@class IXLayout;
@class IXSandbox;
@class IXCellBackgroundSwipeController;

@interface IXUICollectionViewCell : UICollectionViewCell <IXCellContainerDelegate>

@property (nonatomic,strong,readonly) IXCellBackgroundSwipeController* cellBackgroundSwipeController;
@property (nonatomic,strong) IXSandbox* cellSandbox;
@property (nonatomic,strong) IXLayout* layoutControl;
@property (nonatomic,strong) IXLayout* backgroundLayoutControl;
@property (nonatomic,assign) BOOL backgroundSlidesInFromSide;
@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;

-(void)enableBackgroundSwipe:(BOOL)enableBackgroundSwipe swipeWidth:(CGFloat)swipeWidth;

@end
