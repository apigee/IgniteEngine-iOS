//
//  IXBrowserControl.h
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/2013/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseControl.h"
#import "IXPathHandler.h"


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
            "url": "http://IXgee.com",
            "width": 320,
            "height": 320
        }
    }
 */


@interface IXBrowser : IXBaseControl

@property (nonatomic,strong) NSString* url;

@end