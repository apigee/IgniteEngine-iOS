//
//  UIImage+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/5/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IXAdditions)

-(UIImage*)tintedImageUsingColor:(UIColor*)tintColor;
+(UIImage *)ix_animatedGIFWithData:(NSData *)data withDuration:(NSUInteger)duration;

//all 4 of these are broken? possibly need self.contentView.autoresizesSubviews = NO; as workaround
-(UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
-(UIImage *)imageRotatedByRadians:(CGFloat)radians;
+(CGFloat)degreesToRadians:(CGFloat)degrees;
+(CGFloat)radiansToDegrees:(CGFloat)radians;
+(NSString *)contentTypeForImageData:(NSData *)data;
+(UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha;

@end
