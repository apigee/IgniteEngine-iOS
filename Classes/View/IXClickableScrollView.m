//
//  IXClickableScrollView.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/21/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXClickableScrollView.h"

#import "IXBaseControl.h"
#import "IXActionContainer.h"

@implementation IXClickableScrollView

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
    IXBaseControl* parentControl = [self parentControl];
    UIControl* parentContentView = [parentControl contentView];
    if( parentContentView != nil && ![parentContentView isHidden] && [parentContentView isEnabled] )
    {
        if( [[parentControl actionContainer] hasActionsWithEventNamePrefix:@"touch"] )
        {
            return parentContentView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
