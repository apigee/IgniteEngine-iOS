//
//  IXRefreshAction.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/3/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXRefreshAction.h"

#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXLayout.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"

@implementation IXRefreshAction

-(void)execute
{
    IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    NSArray* objectsWithID = [sandbox getAllControlAndDataProvidersWithID:objectID];
    
    for( IXBaseObject* baseObject in objectsWithID )
    {
        [baseObject applySettings];
        
        if( [baseObject isKindOfClass:[IXBaseControl class]] )
        {
            [((IXBaseControl*)baseObject) layoutControl];
        }
        else if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
        {
            [((IXBaseDataProvider*)baseObject) loadData:YES];
        }
    }
}

@end
