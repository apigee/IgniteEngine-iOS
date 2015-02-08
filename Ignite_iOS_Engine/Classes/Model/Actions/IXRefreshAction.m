//
//  IXRefreshAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/3/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
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
 
 ###    Displays a native alert. Can be informational with a single button or actionable with two buttons. 
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name        | Type       | Description                                  | Default |
 |-------------|------------|----------------------------------------------|---------|
 | _target     | *(string)* | ID of control to refresh                     |         |
 | reload_data | *(bool)*   | When targeting a Data Provider, reload data? | true    |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

>   None
 

 ##  <a name="functions">Functions</a>
 
>   None

 
 ##  <a name="example">Example JSON</a> 
 
### Simple Refresh
    {
      "_type": "Refresh",
      "on": "touch_up",
      "attributes": {
        "_target": "controlToRefresh"
      }
    }

### Refresh Data Provider, *don't reload data*
    {
      "_type": "Refresh",
      "on": "touch_up",
      "attributes": {
        "_target": "controlToRefresh",
        "reload_data": false
      }
    }
 
 
 */
//
//  [/Documentation]
/*  -----------------------------  */

#import "IXRefreshAction.h"

#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXView.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"

static NSString* kIXShouldReloadData = @"reload_data";

@implementation IXRefreshAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_TARGET defaultValue:nil];
   
    if( [objectIDs count] )
    {
        IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
        IXSandbox* sandbox = [ownerObject sandbox];
        NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                 withSelfObject:ownerObject];
        
        for( IXBaseObject* baseObject in objectsWithID )
        {
            [baseObject applySettings];
            
            if( [baseObject isKindOfClass:[IXBaseControl class]] )
            {
                [((IXBaseControl*)baseObject) layoutControl];
            }
            else if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
            {
                BOOL reloadData = [self.actionProperties getBoolPropertyValue:kIXShouldReloadData defaultValue:YES];
                [((IXBaseDataProvider*)baseObject) loadData:reloadData];
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
