//
//  UIButton+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/15/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <objc/runtime.h>
#import "UIButton+IXAdditions.h"

@implementation UIButton (IXAdditions)

static char highlightKey;

- (void) setShouldHighlightImageOnTouch:(BOOL)shouldHighlightImageOnTouch {
    objc_setAssociatedObject( self, &highlightKey, [NSNumber numberWithBool:shouldHighlightImageOnTouch], OBJC_ASSOCIATION_RETAIN );
}

- (BOOL) shouldHighlightImageOnTouch {
    return [objc_getAssociatedObject( self, &highlightKey ) boolValue];
}
@end
