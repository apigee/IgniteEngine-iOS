//
//  ixeTextControl.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/15.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeText.h"

@interface ixeText ()

@property (nonatomic,strong) UITextView* textView;

@end

@implementation ixeText

-(void)buildView
{
    [super buildView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [[self contentView] addSubview:[self textView]];
}

@end
