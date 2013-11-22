//
//  IXTextControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXText.h"

@interface IXText ()

@property (nonatomic,strong) UITextView* textView;

@end

@implementation IXText

-(void)buildView
{
    [super buildView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:[self textView]];
}

@end
