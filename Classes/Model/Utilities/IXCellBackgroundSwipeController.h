//
//  IXCellBackgroundSwipeController.h
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
