//
//  IXWindow.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXWindow.h"

#import "IXAppManager.h"

@implementation IXWindow

- (void)motionBegan:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
    // This is a motion/shake event
    if (event.type == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake)
    {
//        [[IXAppManager sharedAppManager] startApplication];
    }
}

// A motion event has ended
- (void)motionEnded:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
    // This is a motion/shake event
    if (event.type == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake)
    {
        // Post a 'Shake Ended' event to the notification center
        NSLog(@"");
    }
}

@end
