//
//  IxLayoutControl.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseControl.h"

@class IxClickableScrollView;

@interface IxLayout : IxBaseControl

@property (nonatomic,strong,readonly) IxClickableScrollView* scrollView;
@property (nonatomic,strong,readonly) UIView* scrollViewContentView;

@property (nonatomic,assign,getter = isZoomEnabled)             BOOL zoomEnabled;
@property (nonatomic,assign,getter = isLayoutFlowVertical)      BOOL layoutFlowVertical;
@property (nonatomic,assign,getter = isVerticalScrollEnabled)   BOOL verticalScrollEnabled;
@property (nonatomic,assign,getter = isHorizontalScrollEnabled) BOOL horizontalScrollEnabled;

@end
