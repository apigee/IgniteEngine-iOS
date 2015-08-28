//
//  IXCircle.m
//  Ignite Engine
//
//  Created by Brandon on 3/16/14.
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

#import "IXCircle.h"

static NSString* const kIXSize = @"size";
static NSString* const kIXColor = @"color";

@implementation IXCircle : IXBaseControl

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [self.circleView sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self.circleView setFrame:rect];
}

-(void)buildView
{
    [super buildView];
    self.circleView = [[UIView alloc] init];
    [self.contentView addSubview:self.circleView];
}

-(void)applySettings
{
    [super applySettings];
    
    NSInteger size = [self.attributeContainer getIntValueForAttribute:kIXSize defaultValue:100];
    UIColor *color = [self.attributeContainer getColorValueForAttribute:kIXColor defaultValue:[UIColor blackColor]];
    
    self.circleView.frame = CGRectMake(0,0,size,size);
    self.circleView.layer.cornerRadius = size / 2;
    self.circleView.backgroundColor = color;
    
}

@end
