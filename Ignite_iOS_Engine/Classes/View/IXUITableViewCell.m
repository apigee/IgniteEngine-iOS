//
//  IXUITableViewCell.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXUITableViewCell.h"

@implementation IXUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _forceSize = NO;
        _forcedSize = CGSizeZero;
        _layoutControl = nil;
    }
    return self;
}

-(CGRect)frame
{
    CGRect returnFrame = [super frame];
    if( [self forceSize] )
    {
        returnFrame.size = [self forcedSize];
    }
    return returnFrame;
}

-(void)setFrame:(CGRect)frame
{
    if( [self forceSize] )
    {
        frame.size = [self forcedSize];
    }
    [super setFrame:frame];
}

@end
