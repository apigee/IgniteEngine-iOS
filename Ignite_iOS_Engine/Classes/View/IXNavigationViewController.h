//
//  IXNavigationViewController.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXViewController;

@interface IXNavigationViewController : UINavigationController

@property (nonatomic,strong,readonly) UIScreenEdgePanGestureRecognizer* rightScreenPanGestureRecognizer;
@property (nonatomic,strong,readonly) UIScreenEdgePanGestureRecognizer* leftScreenPanGestureRecognizer;

-(IXViewController*)viewControllerWithID:(NSString*)viewControllerID;

@end
