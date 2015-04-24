//
//  IXCircle.m
//  Ignite Engine
//
//  Created by Brandon on 3/16/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
    
    NSInteger size = [self.propertyContainer getIntPropertyValue:kIXSize defaultValue:100];
    UIColor *color = [self.propertyContainer getColorPropertyValue:kIXColor defaultValue:[UIColor blackColor]];
    
    self.circleView.frame = CGRectMake(0,0,size,size);
    self.circleView.layer.cornerRadius = size / 2;
    self.circleView.backgroundColor = color;
    
}

@end
