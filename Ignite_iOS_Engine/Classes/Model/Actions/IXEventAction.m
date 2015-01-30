//
//  IXEventAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/25/14.
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
 
 | Name          | Type       | Description                                     | Default |
 |---------------|------------|-------------------------------------------------|---------|
 | _target       | *(string)* | ID of control to raise event on                 |         |
 | event_name    | *(string)* | Name of the event to fire. i.e. 'touch_up' etc. |         |

 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

>   None

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### Raise 'touch_up' Event:
 
    {
      "_type": "Event",
      "on": "touch_up",
      "attributes": {
        "_target": "buttonTest",
        "event_name": "touch_up"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXEventAction.h"

#import "IXSandbox.h"

#import "IXPropertyContainer.h"
#import "IXActionContainer.h"

#import "IXBaseObject.h"

// IXEventAction Properties
static NSString* const kIXEventName = @"event_name";

@implementation IXEventAction

-(void)execute
{
    IXPropertyContainer* actionProperties = [self actionProperties];
    
    NSArray* objectIDs = [actionProperties getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* eventName = [actionProperties getStringPropertyValue:kIXEventName defaultValue:nil];
    
    if( objectIDs && eventName )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [[baseObject actionContainer] executeActionsForEventNamed:eventName];
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
