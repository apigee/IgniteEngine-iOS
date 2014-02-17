//
//  UIImage+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/5/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "UIImage+IXAdditions.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (IXAdditions)

-(UIImage*)tintedImageUsingColor:(UIColor*)tintColor
{
    UIImage *tintedImage = nil;
    
    UIGraphicsBeginImageContext(self.size);
    
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)ix_animatedGIFWithData:(NSData *)data withDuration:(NSUInteger)duration
{
    if (!data)
    {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1)
    {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else
    {
        NSMutableArray *images = [NSMutableArray array];
        
        for (size_t i = 0; i < count; i++)
        {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration)
        {
            duration = (1.0f/10.0f)*count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

@end
