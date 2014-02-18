//
//  IXModifyAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXModifyAction.h"

#import "IXSandbox.h"
#import "IXBaseObject.h"
#import "IXActionContainer.h"
#import "IXAppManager.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXLayout.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"

@implementation IXModifyAction

-(void)performModify
{
    NSString* objectID = [[self actionProperties] getStringPropertyValue:@"id" defaultValue:nil];
    
    if( objectID != nil && [self parameterProperties] != nil )
    {
        if( [objectID isEqualToString:@"session"] )
        {
            IXPropertyContainer* sessionProperties = [[IXAppManager sharedAppManager] sessionProperties];
            [sessionProperties addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES replaceOtherPropertiesWithTheSameName:YES];
        }
        else
        {
            IXSandbox* sandbox = [[[self actionContainer] ownerObject] sandbox];
            NSArray* objectsWithID = [sandbox getAllControlAndDataProvidersWithID:objectID];
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [[baseObject propertyContainer] addPropertiesFromPropertyContainer:[self parameterProperties] evaluateBeforeAdding:YES replaceOtherPropertiesWithTheSameName:YES];
            }
            
            BOOL needsToLayout = [[self parameterProperties] hasLayoutProperties];
            for( IXBaseObject* baseObject in objectsWithID )
            {
                [baseObject applySettings];
                
                if( [baseObject isKindOfClass:[IXBaseDataProvider class]] )
                {
                    [((IXBaseDataProvider*)baseObject) loadData:NO];
                }
            }
            
            if( needsToLayout )
            {
                [[[[IXAppManager sharedAppManager] currentIXViewController] containerControl] layoutControl];
            }
        }
    }
}

-(void)execute
{
    float duration = [[self actionProperties] getFloatPropertyValue:@"duration" defaultValue:0.0f];
    if( duration > 0.0f )
    {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:duration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [weakSelf performModify];
                         } completion:nil];
    }
    else
    {
        [self performModify];
    }
}

@end
