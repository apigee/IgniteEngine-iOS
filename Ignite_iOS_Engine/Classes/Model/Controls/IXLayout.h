//
//  IXLayoutControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseControl.h"

@class IXClickableScrollView;

@interface IXLayout : IXBaseControl

@property (nonatomic,strong,readonly) IXClickableScrollView* scrollView;
@property (nonatomic,strong,readonly) UIView* scrollViewContentView;

@property (nonatomic,assign,getter = isZoomEnabled)             BOOL zoomEnabled;
@property (nonatomic,assign,getter = isLayoutFlowVertical)      BOOL layoutFlowVertical;
@property (nonatomic,assign,getter = isVerticalScrollEnabled)   BOOL verticalScrollEnabled;
@property (nonatomic,assign,getter = isHorizontalScrollEnabled) BOOL horizontalScrollEnabled;

@end
