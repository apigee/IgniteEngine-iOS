//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXImage.h"

#import "UIImageView+WebCache.h"

// IXImage Properties
static NSString* const kIXImagesDefault = @"images.default";
static NSString* const kIXImagesTouch = @"images.touch";
static NSString* const kIXAnimatedImages = @"animated_images";
static NSString* const kIXAnimationDuration = @"animated_images";
static NSString* const kIXAutoAnimate = @"auto_animate";

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

@end

@implementation IXImage

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
        NSArray* imagesPaths = [[self propertyContainer] getCommaSeperatedArrayListValue:kIXAnimatedImages defaultValue:nil];
        if( [imagesPaths count] )
        {
            NSMutableArray* imagesArray = [NSMutableArray arrayWithCapacity:[imagesPaths count]];
            for( NSString* imagePath in imagesPaths )
            {
                UIImage* image = [UIImage imageNamed:imagePath];
                if( image )
                {
                    [imagesArray addObject:image];
                }
            }
            [[self imageView] setAnimationImages:imagesArray];
            [[self imageView] setAnimationDuration:[[self propertyContainer] getFloatPropertyValue:kIXAnimationDuration defaultValue:0.2f]];
            
            BOOL autoAnimate = [[self propertyContainer] getBoolPropertyValue:kIXAutoAnimate defaultValue:YES];
            if( autoAnimate )
            {
                [[self imageView] startAnimating];
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
                                      } failBlock:^(NSError *error) {
                                      }];
        
        [[self propertyContainer] getImageProperty:kIXImagesTouch
                                      successBlock:^(UIImage *image) {
                                          [weakSelf setTouchedImage:image];
                                      } failBlock:^(NSError *error) {
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

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartAnimation] )
    {
        [[self imageView] startAnimating];
    }
    else if( [functionName isEqualToString:kIXStopAnimation] )
    {
        [[self imageView] stopAnimating];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
