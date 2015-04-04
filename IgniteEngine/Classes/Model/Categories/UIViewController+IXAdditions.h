//
//  UIViewController+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (IXAdditions)

+(BOOL)isOkToPresentViewController:(UIViewController*)viewController;
+(BOOL)isOkToDismissViewController:(UIViewController*)viewController;

@end
