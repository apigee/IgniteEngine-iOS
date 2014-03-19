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
                [((IXBaseDataProvider*)baseObject) loadData:YES];
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
