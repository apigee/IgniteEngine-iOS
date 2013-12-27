//
//  UILabel+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/19/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "UILabel+IXAdditions.h"

@implementation UILabel (IXAdditions)

-(CGSize)sizeForFixedWidth:(float)fixedWidth
{
    CGSize returnSize = CGSizeZero;
    
    float lineHeight = ([[self font] ascender] - [[self font] descender] ) + 1;
    
    returnSize = [[self text] sizeWithFont:[self font]
                         constrainedToSize:CGSizeMake(fixedWidth,FLT_MAX)
                             lineBreakMode:[self lineBreakMode]];
    
    if( [self numberOfLines] != 0 && lineHeight * [self numberOfLines] < returnSize.height )
        returnSize.height = lineHeight * [self numberOfLines];
    
    return returnSize;
}

@end
