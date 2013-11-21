//
//  IxTextControl.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxText.h"

@interface IxText ()

@property (nonatomic,strong) UITextView* textView;

@end

@implementation IxText

-(void)buildView
{
    [super buildView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:[self textView]];
}

@end
