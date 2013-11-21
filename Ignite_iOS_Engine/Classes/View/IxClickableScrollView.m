//
//  IxClickableScrollView.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxClickableScrollView.h"

#import "IxBaseControl.h"
#import "IxActionContainer.h"

@implementation IxClickableScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _parentControl = nil;
        [self setCanCancelContentTouches:NO];
    }
    return self;
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    IxBaseControl* parentControl = [self parentControl];
    UIControl* parentContentView = [parentControl contentView];
    if( parentContentView != nil && ![parentContentView isHidden] && [parentContentView isEnabled] )
    {
        if( [[parentControl actionContainer] hasActionsForEvent:@"touch"] )
        {
            return parentContentView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
