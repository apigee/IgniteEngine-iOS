//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXImage.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+IXAdditions.h"
#import "NSString+IXAdditions.h"
#import <ImageIO/ImageIO.h>

// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXAnimatedImages = @"animated_images";
static NSString* const kIXAnimationDuration = @"animation_duration";
static NSString* const kIXAutoAnimate = @"auto_animate";
static NSString* const kIXAnimationRepeatCount = @"animation_repeat_count";

// IXImage Read-Only Properties
static NSString* const kIXIsAnimating = @"is_animating";

// IXImage Events
static NSString* const kIXImagesDefaultLoaded = @"images_default_loaded";
static NSString* const kIXImagesTouchLoaded = @"images_touch_loaded";
static NSString* const kIXImagesDefaultFailed = @"images_default_failed";
static NSString* const kIXImagesTouchFailed = @"images_touch_failed";

// IXImage Functions
static NSString* const kIXStartAnimation = @"start_animation";
static NSString* const kIXReStartAnimation = @"restart_animation";
static NSString* const kIXStopAnimation = @"stop_animation";

@interface IXWeakTimerImageTarget : NSObject

@property (nonatomic,weak) IXImage* imageControl;
@property (nonatomic,assign) NSString* selectorName;

@end

@implementation IXWeakTimerImageTarget

-(instancetype)initWithTarget:(IXImage*)image selectorName:(NSString*)selectorName
{
    self = [super init];
    if( self )
    {
        _imageControl = image;
        _selectorName = selectorName;
    }
    return self;
}

-(void)timerDidFire:(NSTimer*)timer
{
    if([self imageControl] && [self selectorName])
    {
        SEL selector = NSSelectorFromString([self selectorName]);
        IMP imp = [[self imageControl] methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func([self imageControl], selector);
    }
    else
    {
        [timer invalidate];
    }
}

@end

@interface IXImage ()
{
    CGImageSourceRef _gifImageRef;
}

@property (nonatomic,strong) IXWeakTimerImageTarget* weakTimerTarget;

@property (nonatomic,assign) BOOL shouldStopAnimation;
@property (nonatomic,strong) NSTimer* gifTimer;
@property (nonatomic,assign) NSUInteger gifNumberOfFrames;
@property (nonatomic,assign) NSUInteger gifNextFrame;
@property (nonatomic,assign) NSTimeInterval gifTimerTimeInterval;

@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) NSString* defaultImagePath;
@property (nonatomic,strong) UIImage* defaultImage;
@property (nonatomic,strong) NSString* touchedImagePath;
@property (nonatomic,strong) UIImage* touchedImage;
@property (nonatomic,strong) NSArray* animatedImages;
@property (nonatomic,assign,getter = isAnimationPaused) BOOL animationPaused;

@end

@implementation IXImage

-(void)dealloc
{
    _shouldStopAnimation = YES;
    if( _gifImageRef != nil )
    {
        CFRelease(_gifImageRef);
    }
    [_gifTimer invalidate];
}

-(void)buildView
{
    [super buildView];
    
    _weakTimerTarget = [[IXWeakTimerImageTarget alloc] initWithTarget:self selectorName:@"performTransition"];
    _gifImageRef = nil;
    
    _shouldStopAnimation = NO;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:_imageView];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self imageView] setFrame:rect];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(UIImage*)getImageAtCurrentIndex
{
    if( [self gifNextFrame] >= [self gifNumberOfFrames] || _gifImageRef == nil )
    {
        return nil;
    }
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_gifImageRef, [self gifNextFrame], NULL);
    
    UIImage* image = [[UIImage alloc] initWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    
    return image;
}

-(void)performTransition
{
    if(![self shouldStopAnimation])
    {
        [[self imageView] setImage:[self getImageAtCurrentIndex]];
        [self setGifNextFrame:[self gifNextFrame]+1];
        if([self gifNextFrame] == [self gifNumberOfFrames]){
            [self setGifNextFrame:0];
        }
    }
    else
    {
        if([[self gifTimer] isValid])
        {
            [[self gifTimer] invalidate];
            [self setGifTimer:nil];
        }
    }
}

-(void)applySettings
{
    [super applySettings];
    
    NSString* imagePath = [[self propertyContainer] getPathPropertyValue:kIXImagesDefault basePath:nil defaultValue:nil];
    if( [[imagePath pathExtension] isEqualToString:@"gif"])
    {
        if( ![[self defaultImagePath] isEqualToString:imagePath] )
        {
            [self setDefaultImagePath:imagePath];
            float gifDuration = [[self propertyContainer] getFloatPropertyValue:@"gif_duration" defaultValue:1.0f];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* data = [[NSData alloc] initWithContentsOfFile:imagePath];
                
                [[self gifTimer] invalidate];
                [self setGifTimer:nil];

                if( _gifImageRef != nil )
                {
                    CFRelease(_gifImageRef);
                    _gifImageRef = nil;
                }
                _gifImageRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                _gifNumberOfFrames = CGImageSourceGetCount(_gifImageRef);
                _gifTimerTimeInterval = gifDuration/_gifNumberOfFrames;
                
                dispatch_main_sync_safe(^{
                    
                    [self setGifNextFrame:0];
                    [self setGifTimer:[NSTimer scheduledTimerWithTimeInterval:_gifTimerTimeInterval target:[self weakTimerTarget] selector:@selector(timerDidFire:) userInfo:nil repeats:YES]];
                    
                });
            });
        }
        
        if( _gifImageRef )
        {
            BOOL previousShouldStop = [self shouldStopAnimation];
            [self setShouldStopAnimation:[[self contentView] isHidden]];
            
            if( [self shouldStopAnimation] )
            {
                [[self imageView] setImage:nil];
                [[self gifTimer] invalidate];
                [self setGifTimer:nil];
            }
            else
            {
                if( previousShouldStop != [self shouldStopAnimation] )
                {
                    [self setGifNextFrame:0];
                    [self setGifTimer:[NSTimer scheduledTimerWithTimeInterval:_gifTimerTimeInterval target:[self weakTimerTarget] selector:@selector(timerDidFire:) userInfo:nil repeats:YES]];
                }
            }
        }
    }
    else
    {
        __weak IXImage* weakSelf = self;
        [[self propertyContainer] getImageProperty:kIXImagesDefault
                                      successBlock:^(UIImage *image) {
                                          [weakSelf setDefaultImage:image];
                                          [[weakSelf imageView] setImage:image];
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesDefaultLoaded];
                                      } failBlock:^(NSError *error) {
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesDefaultFailed];
                                      }];
        
        [[self propertyContainer] getImageProperty:kIXImagesTouch
                                      successBlock:^(UIImage *image) {
                                          [weakSelf setTouchedImage:image];
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesTouchLoaded];
                                      } failBlock:^(NSError *error) {
                                          [[weakSelf actionContainer] executeActionsForEventNamed:kIXImagesTouchFailed];
                                      }];

    }
}

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesBegan:touches withEvent:event];
    if( [self touchedImage] )
    {
        [[self imageView] setImage:[self touchedImage]];
    }
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesCancelled:touches withEvent:event];
    [[self imageView] setImage:[self defaultImage]];
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesEnded:touches withEvent:event];
    [[self imageView] setImage:[self defaultImage]];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXIsAnimating] )
    {
        returnValue = [NSString stringFromBOOL:[[self imageView] isAnimating]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartAnimation] )
    {
        if( [self gifTimer] == nil || ![[self gifTimer] isValid] )
        {
            [[self gifTimer] invalidate];
            [self setGifTimer:nil];            
            if( _gifImageRef != nil )
            {
                [self setGifTimer:[NSTimer scheduledTimerWithTimeInterval:_gifTimerTimeInterval target:[self weakTimerTarget] selector:@selector(timerDidFire:) userInfo:nil repeats:YES]];
            }
        }
    }
    else if( [functionName isEqualToString:kIXReStartAnimation] )
    {
        if( [self gifTimer] == nil || ![[self gifTimer] isValid] )
        {
            [[self gifTimer] invalidate];
            [self setGifTimer:nil];
            if( _gifImageRef != nil )
            {
                [self setShouldStopAnimation:NO];
                [self setGifNextFrame:0];
                [self setGifTimer:[NSTimer scheduledTimerWithTimeInterval:_gifTimerTimeInterval target:[self weakTimerTarget] selector:@selector(timerDidFire:) userInfo:nil repeats:YES]];
            }
        }
    }
    else if( [functionName isEqualToString:kIXStopAnimation] )
    {
        if( [[self gifTimer] isValid] )
        {
            [self setShouldStopAnimation:YES];
            [[self imageView] setImage:nil];
            [[self gifTimer] invalidate];
            [self setGifTimer:nil];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
