//
//  UILabel+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/19/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "UILabel+IXAdditions.h"

static NSString* const kIXTextAlignmentCenter = @"center";
static NSString* const kIXTextAlignmentLeft = @"left";
static NSString* const kIXTextAlignmentRight = @"right";
static NSString* const kIXTextAlignmentJustified = @"justified";
static NSString* const kIXTextAlignmentNatural = @"natural";

@implementation UILabel (IXAdditions)

-(CGSize)sizeForFixedWidth:(float)fixedWidth
{
    CGSize returnSize = CGSizeZero;
    
    float lineHeight = ([[self font] ascender] - [[self font] descender] ) + 1;
    
    CGRect textRect = [[self text] boundingRectWithSize:CGSizeMake(fixedWidth,CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[self font]}
                                                context:nil];

    returnSize = textRect.size;
    
    if( [self numberOfLines] != 0 && lineHeight * [self numberOfLines] < returnSize.height )
        returnSize.height = lineHeight * [self numberOfLines];
    
    return returnSize;
}

+(NSTextAlignment)ix_textAlignmentFromString:(NSString*)textAlignmentString
{
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    if( [textAlignmentString isEqualToString:kIXTextAlignmentCenter] ) {
        textAlignment = NSTextAlignmentCenter;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentRight] ) {
        textAlignment = NSTextAlignmentRight;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentJustified] ) {
        textAlignment = NSTextAlignmentJustified;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentNatural] ) {
        textAlignment = NSTextAlignmentNatural;
    }
    return textAlignment;
}

@end
