//
//  IXLogAction.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/23/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/29/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Raises an event on the _target control ID.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name     | Type       | Description                | Default |
 |----------|------------|----------------------------|---------|
 | text     | *(string)* | Text to log to the console |         |
 | delay    | *(float)*  | Delay logging              |         |

 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

>   None

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### (re)Load Data Provider:
 
    {
      "_type": "Log",
      "on": "touch_up",
      "attributes": {
        "text": "Console Debug Logging Message"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXLogAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"
#import "IXLogger.h"

static NSString* const kIXText = @"text";
static NSString* const kIXDelay = @"delay";

@implementation IXLogAction

-(void)execute
{
    [super execute];
    
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSString* text = [actionProperties getStringPropertyValue:kIXText defaultValue:nil];
    
    IX_LOG_DEBUG(@"Log action: %@", text);
}

@end