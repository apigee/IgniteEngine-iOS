//
//  UIView+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
