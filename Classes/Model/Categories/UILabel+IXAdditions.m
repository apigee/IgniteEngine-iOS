//
//  UILabel+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/19/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
