//
//  IXCustomNavPushPopTransition.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 5/2/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXCustomNavPushPopTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) BOOL isPushNavigation;
@property (nonatomic,assign) NSTimeInterval duration;

@end
