//
//  IxActionContainer.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxActionContainer.h"

#import "IxAppManager.h"
#import "IxSandbox.h"
#import "IxBaseAction.h"
#import "IxViewController.h"
#import "IxNavigationViewController.h"
#import "IxBaseControl.h"
#import "IxLayout.h"
#import "IxPropertyContainer.h"
#import "IxAlertAction.h"

@interface IxActionContainer ()

@property (nonatomic,strong) NSMutableDictionary* actionsDict;

@end

@implementation IxActionContainer

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
    for( IxBaseAction* action in actions )
    {
        [self addAction:action];
    }
}

-(void)addAction:(IxBaseAction*)action
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
    
    UIInterfaceOrientation currentOrientation = [IxAppManager currentInterfaceOrientation];
    BOOL firedAnAction = NO;
    for( IxBaseAction* action in actionsForEventName )
    {
        BOOL enabled = [[action actionProperties] getBoolPropertyValue:@"enabled" defaultValue:YES];
        if( enabled && [action areConditionalAndOrientationMaskValid:currentOrientation] )
        {
            if( ![action isKindOfClass:[IxAlertAction class]] )
                firedAnAction = YES;
            
            [action execute];
        }
    }
    
    if( firedAnAction )
    {
        [[[[IxAppManager sharedInstance] currentIxViewController] containerControl] applySettings];
        [[[[IxAppManager sharedInstance] currentIxViewController] containerControl] layoutControl];
    }
}

@end
