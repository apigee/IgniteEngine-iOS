//
//  IXCreateAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 1/27/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/30/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Creates a new control from .json file.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name             | Type       | Description                               | Default |
 |------------------|------------|-------------------------------------------|---------|
 | control_location | *(string)* | http:// or /path/to/control.json          |         |
 | parent_id        | *(string)* | ID of the destination parent control      |         |

 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name            | Description                                     |
 |-----------------|-------------------------------------------------|
 | success         | Fires when control is created successfully      |
 | failed          | Fires when create control fails                 |
 | created         | Fires on the newly created control when created |

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### Create new control:

    {
      "_type": "Create",
      "on": "touch_up",
      "attributes": {
        "control_location": "/path/to/control.json",
        "parent_id": "parendId"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXCreateAction.h"

#import "IXAppManager.h"
#import "IXLogger.h"

#import "IXPropertyContainer.h"
#import "IXBaseControlConfig.h"
#import "IXControlCacheContainer.h"
#import "IXCustom.h"

#import "IXBaseControl.h"

// IXCreateAction Properties
static NSString* const kIXControlLocation = @"control_location";
static NSString* const kIXParentID = @"parent_id";

// IXCreateAction Events: kIX_SUCCESS and kIX_FAILED
static NSString* const kIXCreated = @"created"; // Fires on the actual created control. 

@implementation IXCreateAction

-(void)execute
{
    [super execute];
    
    BOOL needsToSendFailed = YES;
    
    NSString* controlJSONLocation = [[self actionProperties] getPathPropertyValue:kIXControlLocation
                                                                         basePath:nil
                                                                     defaultValue:nil];
    
    if( controlJSONLocation )
    {
        NSString* parentControlID = [[self actionProperties] getStringPropertyValue:kIXParentID
                                                                       defaultValue:nil];

        IXBaseControl* parentControl = nil;
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        if( [parentControlID length] > 0 )
        {
            parentControl = [[sandbox getAllControlsWithID:parentControlID] firstObject];
        }
        else
        {
            parentControl = [sandbox containerControl];
        }
        
        if( parentControl != nil )
        {
            needsToSendFailed = NO;
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(parentControl) weakParentControl = parentControl;
            
            [IXControlCacheContainer createControlWithPathToJSON:controlJSONLocation loadAsync:NO completionBlock:^(BOOL didSucceed, IXBaseControl *createdControl, NSError *error) {
                                                     
                 if( createdControl && weakParentControl )
                 {
                     [weakParentControl addChildObject:createdControl];

                     if( [createdControl isKindOfClass:[IXCustom class]] )
                     {
                         IXCustom* customControl = (IXCustom*)createdControl;
                         if( !([[customControl pathToJSON] length] > 0) )
                         {
                             [customControl setPathToJSON:controlJSONLocation];
                         }
                     }

                     [createdControl applySettings];
                     [weakParentControl layoutControl];
                     
                     // Fire the created action on the actual created control (not on the action).
                     [[createdControl actionContainer] executeActionsForEventNamed:kIXCreated];
                     
                     [weakSelf actionDidFinishWithEvents:@[kIX_SUCCESS]];
                }
                else
                {
                    [weakSelf actionDidFinishWithEvents:@[kIX_FAILED]];
                }
             }];
        }
    }
    
    if( needsToSendFailed )
    {
        [self actionDidFinishWithEvents:@[kIX_FAILED]];
    }
}

@end
