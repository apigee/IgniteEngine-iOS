//
//  ixeActionContainer.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeActionContainer.h"

#import "ixeAppManager.h"
#import "ixeSandbox.h"
#import "ixeBaseAction.h"
#import "ixeViewController.h"
#import "ixeNavigationViewController.h"
#import "ixeBaseControl.h"
#import "ixeLayout.h"
#import "ixePropertyContainer.h"
#import "ixeAlertAction.h"

@interface ixeActionContainer ()

@property (nonatomic,strong) NSMutableDictionary* actionsDict;

@end

@implementation ixeActionContainer

-(id)init
{
    self = [super init];
    if( self )
    {
        _actionContainerOwner = nil;
        _actionsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSMutableArray*)actionsForEvent:(NSString*)eventName
{
    if( eventName == nil )
        return nil;
    
    return [[self actionsDict] objectForKey:eventName];
}

-(BOOL)hasActionsForEvent:(NSString*)eventName
{
    NSArray* actionsForEvent = [self actionsForEvent:eventName];
    return actionsForEvent != nil && [actionsForEvent count] > 0;
}

-(void)addActions:(NSArray*)actions
{
    for( ixeBaseAction* action in actions )
    {
        [self addAction:action];
    }
}

-(void)addAction:(ixeBaseAction*)action
{
    NSString* actionEventName = [action eventName];
    if( action == nil || actionEventName == nil )
    {
        NSLog(@"ERROR: TRYING TO ADD ACTION THAT IS NIL OR ACTIONS NAME IS NIL");
        return;
    }

    [action setActionContainer:self];
    
    NSMutableArray* actionsForType = [self actionsForEvent:actionEventName];
    if( actionsForType == nil )
    {
        actionsForType = [[NSMutableArray alloc] initWithObjects:action, nil];
        [[self actionsDict] setObject:actionsForType forKey:actionEventName];
    }
    else if( ![actionsForType containsObject:action] )
    {
        [actionsForType addObject:action];
    }
}

-(void)executeActionsForEventNamed:(NSString*)eventName
{
    NSArray* actionsForEventName = [self actionsForEvent:eventName];
    if( actionsForEventName == nil )
        return;
    
    UIInterfaceOrientation currentOrientation = [ixeAppManager currentInterfaceOrientation];
    BOOL firedAnAction = NO;
    for( ixeBaseAction* action in actionsForEventName )
    {
        BOOL enabled = [[action actionProperties] getBoolPropertyValue:@"enabled" defaultValue:YES];
        if( enabled && [action areConditionalAndOrientationMaskValid:currentOrientation] )
        {
            if( ![action isKindOfClass:[ixeAlertAction class]] )
                firedAnAction = YES;
            
            [action execute];
        }
    }
    
    if( firedAnAction )
    {
        [[[[ixeAppManager sharedInstance] currentixeViewController] containerControl] applySettings];
        [[[[ixeAppManager sharedInstance] currentixeViewController] containerControl] layoutControl];
    }
}

@end
