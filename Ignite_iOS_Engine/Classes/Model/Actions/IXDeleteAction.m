//
//  IXDeleteAction.m
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
 
 ###    Deletes _target control ID
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name             | Type       | Description                               | Default |
 |------------------|------------|-------------------------------------------|---------|
 | _target          | *(string)* | ID of the control to delete               |         |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name            | Description                                     |
 |-----------------|-------------------------------------------------|
 | success         | Fires when control is deleted successfully      |
 | failed          | Fires when delete control fails                 |

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### Delete control:

    {
      "_type": "Delete",
      "on": "touch_up",
      "attributes": {
        "_target": "controlToDelete"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXDeleteAction.h"

#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXPropertyContainer.h"

// IXDeleteAction Events: kIX_SUCCESS and kIX_FAILED

@implementation IXDeleteAction

-(void)execute
{
    [super execute];
    
    BOOL didSucceed = NO;

    NSString* deleteControlID = [[self actionProperties] getStringPropertyValue:kIX_TARGET defaultValue:nil];
    if( deleteControlID )
    {
        NSMutableArray* parentsNeedingLayout = [NSMutableArray array];
        IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
        NSArray* controlsToDelete = [sandbox getAllControlsWithID:deleteControlID];
        for( IXBaseControl* control in controlsToDelete )
        {
            if( [control parentObject] )
            {
                [parentsNeedingLayout addObject:[control parentObject]];
                [[control parentObject] removeChildObject:control];
            }
        }
        
        for( IXBaseControl* parent in parentsNeedingLayout )
        {
            [parent layoutControl];
        }
        
        didSucceed = ([controlsToDelete count] > 0);
    }
    
    if( didSucceed )
    {
        [self actionDidFinishWithEvents:@[kIX_SUCCESS]];
    }
    else
    {
        [self actionDidFinishWithEvents:@[kIX_FAILED]];
    }
}

@end
