//
//  IXWindow.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXWindow.h"

#import "IXAppManager.h"
#import "SDWebImageManager.h"
#import "IXJSONGrabber.h"
#import "IXJSONParser.h"

@implementation IXWindow

- (void)motionBegan:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
    // This is a motion/shake event
    if (event.type == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake)
    {
        // Clear caches.
        [[[SDWebImageManager sharedManager] imageCache] clearMemory];
        [[[SDWebImageManager sharedManager] imageCache] clearDisk];
        [IXJSONGrabber clearCache];
        [IXJSONParser clearCache];
        
        [[IXAppManager sharedAppManager] startApplication];
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
