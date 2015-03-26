//
//  IXMMDrawerController.m
//  Ignite Engine
//
//  Created by Robert Walsh on 9/10/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXMMDrawerController.h"

#import "MHRotaryKnob.h"

@interface MMDrawerController () <UIGestureRecognizerDelegate>
@end

@implementation IXMMDrawerController

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( [touch.view isKindOfClass:[MHRotaryKnob class]] ) {
        return NO;
    } else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
}
@end
