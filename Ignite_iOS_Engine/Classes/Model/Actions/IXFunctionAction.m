//
//  IXFunctionAction.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
 
 ###    Raises an event on the _target control ID.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name          | Type       | Description                    | Default |
 |---------------|------------|--------------------------------|---------|
 | _target       | *(string)* | ID of control to call function |         |
 | function_name | *(string)* | Function name to call          |         |
 | duration      | *(float)*  | Duration                       | 0       |

 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

>   None

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### Call 'keyboard_show' function on a IXTextInput:
 
    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "textInputTest",
        "function_name": "keyboard_show"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXFunctionAction.h"

#import "IXPropertyContainer.h"
#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXBaseDataProvider.h"

#import "IXAppManager.h"
#import "SDWebImageManager.h"
#import "IXDataGrabber.h"
#import "IXControlCacheContainer.h"

#import "MMDrawerController.h"

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"functionName";
static NSString* const kIXDuration = @"duration";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
    NSString* functionName = [[self actionProperties] getStringPropertyValue:kIXFunctionName defaultValue:nil];
    CGFloat duration = [[self actionProperties] getFloatPropertyValue:kIXDuration defaultValue:0.0f];
    
    if( [objectIDs count] && [functionName length] > 0 )
    {
        if ([[objectIDs firstObject] isEqualToString:kIXAppRef])
        {
            [[IXAppManager sharedAppManager] applyFunction:functionName parameters:[self parameterProperties]];
        }
        else
        {
            IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
            IXSandbox* sandbox = [ownerObject sandbox];
            NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                     withSelfObject:ownerObject];
            if( [objectsWithID count] )
            {
                if (duration > 0)
                {
                    [UIView animateWithDuration:duration
                                          delay:0.0f
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                         for( IXBaseObject* baseObject in objectsWithID )
                                         {
                                             [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
                                         }
                                     }
                                     completion:nil];
                }
                else
                {
                    for( IXBaseObject* baseObject in objectsWithID )
                    {
                        [baseObject applyFunction:functionName withParameters:[self parameterProperties]];
                    }
                }
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
