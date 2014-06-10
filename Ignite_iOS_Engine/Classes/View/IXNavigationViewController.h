//
//  IXNavigationViewController.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IXViewController;

@interface IXNavigationViewController : UINavigationController

@property (nonatomic,strong,readonly) UIScreenEdgePanGestureRecognizer* rightScreenPanGestureRecognizer;
@property (nonatomic,strong,readonly) UIScreenEdgePanGestureRecognizer* leftScreenPanGestureRecognizer;

-(IXViewController*)viewControllerWithID:(NSString*)viewControllerID;

@end
