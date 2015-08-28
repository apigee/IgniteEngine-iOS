//
//  UIFont+IXAdditions.m
//  Ignite Engine
//
//  Created by Brandon on 2/9/15.
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

#import "UIFont+IXAdditions.h"
#import "IXConstants.h"

@implementation UIFont (IXAdditions)

+ (UIFont*)ix_fontFromString:(NSString*)string {
    
    if (string == nil)
        return nil;
    
    NSArray* fontComponents = [string componentsSeparatedByString:kIX_COLON_SEPARATOR];
    
    NSString* fontName = [fontComponents firstObject];
    CGFloat fontSize = [[fontComponents lastObject] floatValue] ?: 12.0;
    
    return ( fontName ) ? [UIFont fontWithName:fontName size:fontSize] : nil;
}

+ (UIFont*)ix_fontForString:(NSString*)string toFitInRect:(CGRect)rect seedFont:(UIFont*)seedFont {
    UIFont* returnFont = seedFont;
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName : seedFont}];
    
    if (stringSize.width > rect.size.width) {
        while ([string sizeWithAttributes:@{NSFontAttributeName: returnFont}].width > rect.size.width)
        {
            returnFont = [UIFont fontWithName:seedFont.fontName size:returnFont.pointSize - 0.25];
            stringSize = [string sizeWithAttributes:@{NSFontAttributeName: returnFont}];
        }
    }
    else if (stringSize.width < rect.size.width) {
        while ([string sizeWithAttributes:@{NSFontAttributeName: returnFont}].width < rect.size.width)
        {
            returnFont = [UIFont fontWithName:seedFont.fontName size:returnFont.pointSize + 0.25];
            stringSize = [string sizeWithAttributes:@{NSFontAttributeName: returnFont}];
            if (stringSize.width >= rect.size.width) {
                returnFont = [UIFont fontWithName:seedFont.fontName size:returnFont.pointSize - 0.25];
                break;
            }
        }
    }
    return returnFont;
}

@end
