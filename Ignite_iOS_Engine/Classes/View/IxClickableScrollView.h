//
//  IxClickableScrollView.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import <UIKit/UIKit.h>

@class IxBaseControl;

@interface IxClickableScrollView : UIScrollView

@property (nonatomic,weak) IxBaseControl* parentControl;

@end
