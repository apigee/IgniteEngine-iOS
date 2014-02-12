//
//  UIImageView+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/12/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "UIImageView+IXAdditions.h"

@implementation UIImageView (IXAdditions)

-(void)pauseAnimation
{
    CALayer* imageViewLayer = [self layer];
    CFTimeInterval pausedTime = [imageViewLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    imageViewLayer.speed = 0.0f;
    imageViewLayer.timeOffset = pausedTime;
}

-(void)resumeAnimation
{
    CALayer* imageViewLayer = [self layer];
    CFTimeInterval pausedTime = [imageViewLayer timeOffset];
    imageViewLayer.speed = 1.0f;
    imageViewLayer.timeOffset = 0.0f;
    imageViewLayer.beginTime = 0.0f;
    CFTimeInterval timeSincePause = [imageViewLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    imageViewLayer.beginTime = timeSincePause;
}

@end
