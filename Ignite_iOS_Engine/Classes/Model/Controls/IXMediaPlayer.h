//
//  IXVideoControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/2013/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#warning Should rename to VideoPlayer

#import "IXBaseControl.h"

/** This object is used to display video files, including .mov .mp4 .mpv .3gp.
 
 ##Properties##

 *  **video** *(string) (read/write)*
    *  The URL to the video to display
 
 *  **controls** *(string) (read/write)*
     *  The type of controls to display.
     *  **default**, embedded, fullscreen, none

 *  **bar**
    *  **height** *(float) (read/write)*
        *  The height of the UI controls to display.
        *  **70 (iOS 7)**, **50 (<iOS 7)**
     *  **color** *(color) (read/write)*
         *  The tinted color of the UI controls.
         *  **#FF00FF**

 ##Usage##
     {
         "type": "Video",
         "properties": {
            "id": "myVideo",
            "layout_type": "relative",
            "height": "180",
            "width": "320",
            "video": "/path/to/video.mp4",
            "controls": "default",
                "bar": {
                "height": "50",
                "color": "#00FF0050"
            }
         }
     }
 */

@interface IXMediaPlayer : IXBaseControl

@end
