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
#import "IXControlCacheContainer.h"
#import "IXDeviceInfo.h"
#import "IXBaseDataProvider.h"

#import "NSString+IXAdditions.h"

@implementation IXWindow

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)motionBegan:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
    // This is a motion/shake event
    if (event.type == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake)
    {
        if ([[IXDeviceInfo deviceType] containsSubstring:@"simulator" options:NSCaseInsensitiveSearch])
        {
            // Clear caches.
            [[[SDWebImageManager sharedManager] imageCache] clearMemory];
            [[[SDWebImageManager sharedManager] imageCache] clearDisk];
            
            [IXControlCacheContainer clearCache];
            [IXBaseDataProvider clearCache];
            [IXJSONGrabber clearCache];
            
            [[IXAppManager sharedAppManager] startApplication];
        }
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
