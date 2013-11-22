//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXImage.h"

#import "UIImageView+WebCache.h"

@interface IXImage ()

@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) NSString* imagePath;
@property (nonatomic,strong) NSString* touchedImagePath;

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
    
    [self setImagePath:[[self propertyContainer] getStringPropertyValue:@"images.default" defaultValue:nil]];
    [self setTouchedImagePath:[[self propertyContainer] getStringPropertyValue:@"images.touch" defaultValue:nil]];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:[self imagePath] withExtension:nil];
    [[self imageView] setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) { }];
}

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesBegan:touches withEvent:event];
    
    if( [self touchedImagePath] )
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[self touchedImagePath] withExtension:nil];
        if( url != nil )
        {
            [[self imageView] setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) { }];
        }
    }
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesEnded:touches withEvent:event];
    
    if( [self imagePath] )
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[self imagePath] withExtension:nil];
        if( url != nil )
        {
            [[self imageView] setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) { }];
        }
    }
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super controlViewTouchesEnded:touches withEvent:event];
    
    if( [self imagePath] )
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[self imagePath] withExtension:nil];
        if( url != nil )
        {
            [[self imageView] setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) { }];
        }
    }
}

@end
