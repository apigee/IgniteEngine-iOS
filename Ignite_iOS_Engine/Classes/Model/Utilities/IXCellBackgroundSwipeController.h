//
//  IXCellBackgroundSwipeController.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXLayout;
@class IXSandbox;

@interface IXCellBackgroundSwipeController : NSObject

@property (nonatomic,weak) UIView* cellView;
@property (nonatomic,weak) IXLayout* layoutControl;
@property (nonatomic,weak) IXLayout* backgroundLayoutControl;

@property (nonatomic,assign) NSInteger cellsStartingCenterXPosition;
@property (nonatomic,assign) NSInteger startXPosition;

@property (nonatomic,assign) CGFloat swipeWidth;

-(instancetype)initWithCellView:(UIView*)cellView;

-(void)resetCellPosition;
-(void)enablePanGesture:(BOOL)enableGesture;

@end
