//
//  UIImage+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/5/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "UIImage+IXAdditions.h"

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

@end
