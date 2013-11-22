//
//  IXClickableScrollView.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXBaseControl;

@interface IXClickableScrollView : UIScrollView

@property (nonatomic,weak) IXBaseControl* parentControl;

@end
