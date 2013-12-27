//
//  UIView+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "UIView+IXAdditions.h"

@implementation UIView (IXAdditions)

-(void)removeAllSubviews
{
    while( [[self subviews] count] )
    {
        UIView* subView = [[self subviews] lastObject];
        [subView removeFromSuperview];
    }
}

@end
