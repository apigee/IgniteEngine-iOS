//
//  IXRefreshAction.m
//  Ignite Engine
//
//  Created by Robert Walsh on 12/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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

static NSString* kIXShouldReloadData = @"reloadData.enabled";

@implementation IXRefreshAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
   
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
                BOOL reloadData = [self.actionProperties getBoolValueForAttribute:kIXShouldReloadData defaultValue:YES];
                [((IXBaseDataProvider*)baseObject) loadData:reloadData];
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
