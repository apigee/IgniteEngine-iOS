//
//  ixeClickableScrollView.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class ixeBaseControl;

@interface ixeClickableScrollView : UIScrollView

@property (nonatomic,weak) ixeBaseControl* parentControl;

@end
