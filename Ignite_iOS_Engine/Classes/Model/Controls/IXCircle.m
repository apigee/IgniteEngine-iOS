//
//  IXCircle.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/16/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCircle.h"

static NSString* const kIXSize = @"size";
static NSString* const kIXColor = @"color";

@interface IXCircle ()

@property (nonatomic,strong) UIView* circleView;

@end

@implementation IXCircle

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

}

-(void)applySettings
{
    [super applySettings];
    
    NSInteger size = [self.propertyContainer getIntPropertyValue:kIXSize defaultValue:100];
    UIColor *color = [self.propertyContainer getColorPropertyValue:kIXColor defaultValue:[UIColor blackColor]];
    
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(10,20,size,size)];
    self.circleView.layer.cornerRadius = size / 2;
    self.circleView.backgroundColor = color;
    [self.contentView addSubview:self.circleView];


}

@end
