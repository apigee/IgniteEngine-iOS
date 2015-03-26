//
//  IXCellBackgroundSwipeController.h
//  Ignite Engine
//
//  Created by Robert Walsh on 6/4/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXLayout;
@class IXSandbox;

@protocol IXCellBackgroundSwipeControllerDelegate <NSObject>
@optional
-(void)cellBackgroundWillBeginToOpen:(UIView*)cellView;
@end

@interface IXCellBackgroundSwipeController : NSObject

@property (nonatomic,weak) id<IXCellBackgroundSwipeControllerDelegate> delegate;
@property (nonatomic,weak) UIView* cellView;
@property (nonatomic,weak) IXLayout* layoutControl;
@property (nonatomic,weak) IXLayout* backgroundLayoutControl;

@property (nonatomic,assign) BOOL adjustsBackgroundAlphaWithSwipe;
@property (nonatomic,assign) NSInteger cellsStartingCenterXPosition;
@property (nonatomic,assign) NSInteger startXPosition;

@property (nonatomic,assign) CGFloat swipeWidth;

-(instancetype)initWithCellView:(UIView*)cellView;

-(void)resetCellPosition;
-(void)enablePanGesture:(BOOL)enableGesture;

@end
