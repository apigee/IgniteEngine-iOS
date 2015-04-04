//
//  IXLayoutControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//


#import "IXBaseControl.h"

@class IXClickableScrollView;

@interface IXView : IXBaseControl

@property (nonatomic,assign,getter = isTopLevelViewControllerLayout) BOOL topLevelViewControllerLayout;

@property (nonatomic,strong,readonly) IXClickableScrollView* scrollView;
@property (nonatomic,strong,readonly) UIView* scrollViewContentView;

@property (nonatomic,assign,readonly,getter = isZoomEnabled)             BOOL zoomEnabled;
@property (nonatomic,assign,readonly,getter = isLayoutFlowVertical)      BOOL layoutFlowVertical;
@property (nonatomic,assign,readonly,getter = isVerticalScrollEnabled)   BOOL verticalScrollEnabled;
@property (nonatomic,assign,readonly,getter = isHorizontalScrollEnabled) BOOL horizontalScrollEnabled;

@end
