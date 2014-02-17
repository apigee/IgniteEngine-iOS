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
static NSString* const kIXStopAnimation = @"stop_animation";

@interface IXImage ()

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
    [_imageView stopAnimating];
}

-(void)buildView
{
    [super buildView];
    
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

-(void)applySettings
{
    [super applySettings];

    if( [[self propertyContainer] propertyExistsForPropertyNamed:kIXAnimatedImages] )
    {
//        NSArray* imagesPaths = [[self propertyContainer] getCommaSeperatedArrayListValue:kIXAnimatedImages defaultValue:nil];
//        if( [imagesPaths count] )
//        {
//            NSMutableArray* imagesArray = [NSMutableArray arrayWithCapacity:[imagesPaths count]];
//            for( NSString* imagePath in imagesPaths )
//            {
//                UIImage* image = [UIImage imageNamed:imagePath];
//                if( image )
//                {
//                    [imagesArray addObject:image];
//                }
//            }
//            [[self imageView] setAnimationImages:imagesArray];
//            [[self imageView] setAnimationDuration:[[self propertyContainer] getFloatPropertyValue:kIXAnimationDuration defaultValue:0.2f]];
//            [[self imageView] setAnimationRepeatCount:[[self propertyContainer] getIntPropertyValue:kIXAnimationRepeatCount defaultValue:0]];
//            
//            BOOL autoAnimate = [[self propertyContainer] getBoolPropertyValue:kIXAutoAnimate defaultValue:YES];
//            if( autoAnimate )
//            {
//                [[self imageView] startAnimating];
//            }
//        }
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
        if( [self isAnimationPaused] )
        {
            [self setAnimationPaused:NO];
            [[self imageView] resumeAnimation];
        }
        else if( ![[self imageView] isAnimating] )
        {
            [[self imageView] startAnimating];
        }
    }
    else if( [functionName isEqualToString:kIXStopAnimation] )
    {
        if( [[self imageView] isAnimating] && ![self isAnimationPaused] )
        {
            [self setAnimationPaused:YES];
            [[self imageView] pauseAnimation];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
