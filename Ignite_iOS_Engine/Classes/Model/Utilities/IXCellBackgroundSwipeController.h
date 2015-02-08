//
//  IXCellBackgroundSwipeController.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXView;
@class IXSandbox;

@protocol IXCellBackgroundSwipeControllerDelegate <NSObject>
@optional
-(void)cellBackgroundWillBeginToOpen:(UIView*)cellView;
@end

@interface IXCellBackgroundSwipeController : NSObject

@property (nonatomic,weak) id<IXCellBackgroundSwipeControllerDelegate> delegate;
@property (nonatomic,weak) UIView* cellView;
@property (nonatomic,weak) IXView* layoutControl;
@property (nonatomic,weak) IXView* backgroundLayoutControl;

@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;
@property (nonatomic,assign) NSInteger cellsStartingCenterXPosition;
@property (nonatomic,assign) NSInteger startXPosition;

@property (nonatomic,assign) CGFloat swipeWidth;

-(instancetype)initWithCellView:(UIView*)cellView;

-(void)resetCellPosition;
-(void)enablePanGesture:(BOOL)enableGesture;

@end
