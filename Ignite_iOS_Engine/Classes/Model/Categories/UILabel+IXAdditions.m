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
    
    CGRect textRect = [[self text] boundingRectWithSize:CGSizeMake(fixedWidth,CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[self font]}
                                                context:nil];

    returnSize = textRect.size;
    
    if( [self numberOfLines] != 0 && lineHeight * [self numberOfLines] < returnSize.height )
        returnSize.height = lineHeight * [self numberOfLines];
    
    return returnSize;
}

@end
