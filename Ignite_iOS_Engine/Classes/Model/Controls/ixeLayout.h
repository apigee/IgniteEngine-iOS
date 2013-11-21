//
//  ixeLayoutControl.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseControl.h"

@class ixeClickableScrollView;

@interface ixeLayout : ixeBaseControl

@property (nonatomic,strong,readonly) ixeClickableScrollView* scrollView;
@property (nonatomic,strong,readonly) UIView* scrollViewContentView;

@property (nonatomic,assign,getter = isZoomEnabled)             BOOL zoomEnabled;
@property (nonatomic,assign,getter = isLayoutFlowVertical)      BOOL layoutFlowVertical;
@property (nonatomic,assign,getter = isVerticalScrollEnabled)   BOOL verticalScrollEnabled;
@property (nonatomic,assign,getter = isHorizontalScrollEnabled) BOOL horizontalScrollEnabled;

@end
