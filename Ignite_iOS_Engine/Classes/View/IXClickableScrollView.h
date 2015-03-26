//
//  IXClickableScrollView.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/21/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXBaseControl;

@interface IXClickableScrollView : UIScrollView

@property (nonatomic,weak) IXBaseControl* parentControl;

@end
