//
//  IXLoadAction.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 3/6/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXLoadAction.h"

#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXLayout.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"

@implementation IXLoadAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeperatedArrayListValue:kIX_ID defaultValue:nil];
    
    IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
    IXSandbox* sandbox = [ownerObject sandbox];
    NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                             withSelfObject:ownerObject];
    
    for( IXBaseObject* baseObject in objectsWithID )
    {
        [baseObject applySettings];
        
        if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
        {
            [((IXBaseDataProvider*)baseObject) loadData:YES];
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
