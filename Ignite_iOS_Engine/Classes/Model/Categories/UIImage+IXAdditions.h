//
//  UIImage+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/5/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IXAdditions)

-(UIImage*)tintedImageUsingColor:(UIColor*)tintColor;
+(UIImage *)ix_animatedGIFWithData:(NSData *)data withDuration:(NSUInteger)duration;

@end
