//
//  IXCustomNavPushPopTransition.h
//  Ignite Engine
//
//  Created by Robert Walsh on 5/2/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXCustomNavPushPopTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) BOOL isPushNavigation;
@property (nonatomic,assign) NSTimeInterval duration;

@end
