//
//  UIViewController+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "UIViewController+IXAdditions.h"

@implementation UIViewController (IXAdditions)

+(BOOL)isOkToPresentViewController:(UIViewController*)viewController
{
    return  ( ![viewController presentingViewController] && ![viewController isBeingDismissed] && ![viewController isBeingPresented] );
}

+(BOOL)isOkToDismissViewController:(UIViewController*)viewController
{
    return  ( [viewController presentingViewController] && ![viewController isBeingDismissed] && ![viewController isBeingPresented] );
}

@end
