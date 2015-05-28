//
//  IXGIFImageView.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/24/14.
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

#import "IXGIFImageView.h"

#import <ImageIO/ImageIO.h>

#import "IXWeakTimerTarget.h"

@interface IXGIFImageView () <IXWeakTimerTargetDelegate>
{
    CGImageSourceRef _animatedGIFImageRef;
}

@property (nonatomic,assign) NSUInteger nextFrame;
@property (nonatomic,assign) NSUInteger numberOfFrames;
@property (nonatomic,assign) NSTimeInterval timerTimeInterval;

@property (nonatomic,strong) IXWeakTimerTarget* weakTimerTarget;
@property (nonatomic,strong) NSTimer* timer;

@property (nonatomic,assign) BOOL shouldStopAnimation;

@end

@implementation IXGIFImageView

-(void)dealloc
{
    if( [_timer isValid] )
    {
        [_timer invalidate];
    }
    if( _animatedGIFImageRef != nil )
    {
        CFRelease(_animatedGIFImageRef);
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _animatedGIFImageRef = nil;
        _animatedGIFDuration = 1.0f;
        _weakTimerTarget = [[IXWeakTimerTarget alloc] initWithDelegate:self];
    }
    return self;
}

-(void)setAnimatedGIFURL:(NSURL *)animatedGIFURL
{
    if( ![[self animatedGIFURL] isEqual:animatedGIFURL] )
    {
        _animatedGIFURL = [animatedGIFURL copy];
        [self loadGIF];
    }
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if( hidden )
    {
        [self stopGIFAnimation:YES];
    }
    else
    {
        if( ![self isGIFAnimating] && _animatedGIFImageRef )
        {
            [self startGIFAnimation:YES];
        }
    }
}

-(void)loadGIF
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[weakSelf timer] invalidate];
        [weakSelf setTimer:nil];
        
        if( _animatedGIFImageRef != nil )
        {
            CFRelease(_animatedGIFImageRef);
            _animatedGIFImageRef = nil;
        }
        
        if( [[weakSelf animatedGIFURL] absoluteString].length > 0.0f )
        {
            NSData* data = [[NSData alloc] initWithContentsOfURL:[weakSelf animatedGIFURL]];
            if( data.length > 0.0f )
            {
                _animatedGIFImageRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                
                [weakSelf setNumberOfFrames:CGImageSourceGetCount(_animatedGIFImageRef)];
                [weakSelf setTimerTimeInterval:[self calculateGIFTimeInterval]];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if( ![weakSelf isHidden] )
                        [weakSelf startGIFAnimation:YES];
                });
            }
        }
    });
}

-(NSTimeInterval)calculateGIFTimeInterval
{
    NSTimeInterval gifDuration = [self animatedGIFDuration];
    if( gifDuration <= 0.0f )
    {
        if( _animatedGIFImageRef != nil )
        {
            size_t numberOfFrames = [self numberOfFrames];
            
            for (size_t frameIndex = 0; frameIndex < numberOfFrames; frameIndex++)
            {
                CGImageRef image = CGImageSourceCreateImageAtIndex(_animatedGIFImageRef, frameIndex, NULL);
                NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(_animatedGIFImageRef, frameIndex, NULL));
                
                gifDuration += [frameProperties[(NSString*)kCGImagePropertyGIFDictionary][(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
                
                CGImageRelease(image);
            }
            
            if( !gifDuration )
            {
                gifDuration = (1.0f/10.0f)*numberOfFrames;
            }
        }
    }
    
    NSTimeInterval gifTimeInterval = gifDuration/[self numberOfFrames];
    return gifTimeInterval;
}

-(UIImage*)getImageAtIndex:(NSUInteger)frameIndex
{
    if( _animatedGIFImageRef == nil || frameIndex >= [self numberOfFrames] )
    {
        return nil;
    }
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_animatedGIFImageRef, frameIndex, NULL);
    UIImage* image = [[UIImage alloc] initWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return image;
}

-(void)timerFired:(IXWeakTimerTarget *)timerTarget
{
    if(![self shouldStopAnimation])
    {
        [self setImage:[self getImageAtIndex:[self nextFrame]]];
        [self setNextFrame:[self nextFrame]+1];
        
        if([self nextFrame] == [self numberOfFrames])
        {
            [self setNextFrame:0];
        }
    }
    else
    {
        if([[self timer] isValid])
        {
            [[self timer] invalidate];
            [self setTimer:nil];
        }
    }
}

-(void)startGIFAnimation:(BOOL)restartFromFirstFrame
{
    if( restartFromFirstFrame )
    {
        [self setNextFrame:0];
    }
    
    [self setShouldStopAnimation:NO];
    if( [self timer] == nil || ![[self timer] isValid] )
    {
        [[self timer] invalidate];
        [self setTimer:nil];
        
        if( _animatedGIFImageRef != nil )
        {
            [self setTimer:[[self weakTimerTarget] createTimerWithInterval:[self timerTimeInterval] repeats:YES]];
        }
    }
}

-(void)stopGIFAnimation:(BOOL)removeImageFromView
{
    if( [[self timer] isValid] )
    {
        [self setShouldStopAnimation:YES];
        [[self timer] invalidate];
        [self setTimer:nil];
    }
    
    if( removeImageFromView )
    {
        [self setImage:nil];
    }
}

-(BOOL)isGIFAnimating
{
    return ( [[self timer] isValid] && ![self shouldStopAnimation] );
}

@end
