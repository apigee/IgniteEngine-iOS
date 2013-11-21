//
//  ixeClickableScrollView.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/21.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeClickableScrollView.h"

#import "ixeBaseControl.h"
#import "ixeActionContainer.h"

@implementation ixeClickableScrollView

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
    ixeBaseControl* parentControl = [self parentControl];
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
