//
//  UIButton+IXAdditions.m
//  Ignite Engine
//
//  Created by Brandon on 3/15/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
