//
//  IxBrowserControl.h
//  Ignite iOS Engine (Ix)
//
//  Created by Jeremy Anticouni on 11/16/2013.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseControl.h"

/** This object is used to display HTML & websites.
 
 ##Properties##

 *  **url** *(string) (read/write)*
    *  The URL to the content to display
 
 *  **mode** *(string) (read/write)*
     *  The type of display to use.
     *  **default**, modal

 ##Usage##
     {
        "type": "Browser",
        "properties": {
            "id": "myBrowser",
            "mode": "default",
            "url": "http://Ixgee.com",
            "width": 320,
            "height": 320
        }
    }
 */


@interface IxBrowser : IxBaseControl

@end
