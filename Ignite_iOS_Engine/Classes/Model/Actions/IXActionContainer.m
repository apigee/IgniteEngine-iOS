//
//  IXActionContainer.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXActionContainer.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXBaseAction.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXBaseControl.h"
#import "IXLayout.h"
#import "IXPropertyContainer.h"
#import "IXAlertAction.h"

@interface IXActionContainer ()

@property (nonatomic,strong) NSMutableDictionary* actionsDict;

@end

@implementation IXActionContainer

@synthesize sandbox = _sandbox;

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

-(IXSandbox*)sandbox
{
    return _sandbox;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    _sandbox = sandbox;
    
    for( NSArray* actionArray in [[self actionsDict] allValues] )
    {
        for( IXBaseAction* action in actionArray )
        {
            [[action actionProperties] setSandbox:sandbox];
            [[action parameterProperties] setSandbox:sandbox];
            [[action subActionContainer] setSandbox:sandbox];
        }
    }
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
    for( IXBaseAction* action in actions )
    {
        [self addAction:action];
    }
}

-(void)addAction:(IXBaseAction*)action
{
    NSString* actionEventName = [action eventName];
    if( action == nil || actionEventName == nil )
    {
        NSLog(@"ERROR: TRYING TO ADD ACTION THAT IS NIL OR ACTIONS NAME IS NIL");
        return;
    }

    [action setActionContainer:self];
    [[action actionProperties] setSandbox:[self sandbox]];
    [[action parameterProperties] setSandbox:[self sandbox]];
    [[action subActionContainer] setSandbox:[self sandbox]];

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
    
    UIInterfaceOrientation currentOrientation = [IXAppManager currentInterfaceOrientation];
    BOOL firedAnAction = NO;
    for( IXBaseAction* action in actionsForEventName )
    {
        BOOL enabled = [[action actionProperties] getBoolPropertyValue:@"enabled" defaultValue:YES];
        if( enabled && [action areConditionalAndOrientationMaskValid:currentOrientation] )
        {
            if( ![action isKindOfClass:[IXAlertAction class]] )
                firedAnAction = YES;
            
            [action execute];
        }
    }
    
    if( firedAnAction )
    {
        [[[[IXAppManager sharedInstance] currentIXViewController] containerControl] applySettings];
        [[[[IXAppManager sharedInstance] currentIXViewController] containerControl] layoutControl];
    }
}

@end
