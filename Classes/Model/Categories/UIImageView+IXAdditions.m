//
//  UIImageView+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/12/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
