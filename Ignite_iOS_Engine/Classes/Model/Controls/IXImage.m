//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXImage.h"

#import "NSString+IXAdditions.h"
#import "UIImageView+IXAdditions.h"

#import "IXWeakTimerTarget.h"
#import "IXGIFImageView.h"

// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXGIFDuration = @"gif_duration";

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

@interface IXImage ()

@property (nonatomic,strong) IXGIFImageView* imageView;

@property (nonatomic,strong) UIImage* defaultImage;
@property (nonatomic,strong) UIImage* touchedImage;

@property (nonatomic,assign,getter = isAnimatedGIF) BOOL animatedGif;
@property (nonatomic,strong) NSURL* animatedGIFURL;

@end

@implementation IXImage

-(void)buildView
{
    [super buildView];
    
    _imageView = [[IXGIFImageView alloc] initWithFrame:CGRectZero];
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

-(void)applySettings
{
    [super applySettings];
    
    NSURL* imageURL = [[self propertyContainer] getURLPathPropertyValue:kIXImagesDefault basePath:nil defaultValue:nil];
    [self setAnimatedGif:[[imageURL pathExtension] isEqualToString:kIX_GIF_EXTENSION]];

    if( [self isAnimatedGIF] )
    {
        if( ![[self animatedGIFURL] isEqual:imageURL] )
        {
            [self setAnimatedGIFURL:imageURL];
            
            float gifDuration = [[self propertyContainer] getFloatPropertyValue:kIXGIFDuration defaultValue:0.0f];
            [[self imageView] setAnimatedGIFDuration:gifDuration];
            [[self imageView] setAnimatedGIFURL:[self animatedGIFURL]];
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
    if( ![self isAnimatedGIF] && [self touchedImage] )
    {
        [[self imageView] setImage:[self touchedImage]];
    }
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesCancelled:touches withEvent:event];
    if( ![self isAnimatedGIF] )
    {
        [[self imageView] setImage:[self defaultImage]];
    }
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesEnded:touches withEvent:event];
    if( ![self isAnimatedGIF] )
    {
        [[self imageView] setImage:[self defaultImage]];
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXIsAnimating] )
    {
        returnValue = [NSString stringFromBOOL:[[self imageView] isGIFAnimating]];
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
        [[self imageView] startGIFAnimation:NO];
    }
    else if( [functionName isEqualToString:kIXReStartAnimation] )
    {
        [[self imageView] startGIFAnimation:YES];
    }
    else if( [functionName isEqualToString:kIXStopAnimation] )
    {
        [[self imageView] stopGIFAnimation:NO];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
