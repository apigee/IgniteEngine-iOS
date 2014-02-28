//
//  IXGIFImageView.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/24/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
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
                    [weakSelf setNextFrame:0];
                    [weakSelf setTimer:[[weakSelf weakTimerTarget] createTimerWithInterval:[weakSelf timerTimeInterval] repeats:YES]];
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
