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

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _actionsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone*)zone
{
    IXActionContainer* actionContainerCopy = [[[self class] allocWithZone:zone] init];
    if( actionContainerCopy )
    {
        [actionContainerCopy setSandbox:[self sandbox]];
        [actionContainerCopy setActionContainerOwner:[self actionContainerOwner]];
        [[self actionsDict] enumerateKeysAndObjectsUsingBlock:^(NSString* actionName, NSArray* actionArray, BOOL *stop) {
            NSMutableArray* actionArrayCopy = [[NSMutableArray alloc] initWithArray:actionArray copyItems:YES];
            [actionContainerCopy addActions:actionArrayCopy];
        }];
    }
    return actionContainerCopy;
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
            [[action actionProperties] setSandbox:_sandbox];
            [[action parameterProperties] setSandbox:_sandbox];
            [[action subActionContainer] setSandbox:_sandbox];
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

-(BOOL)hasActionsWithEventNamePrefix:(NSString*)eventNamePrefix;
{
    BOOL hasActionsWithEventNamePrefix = NO;
    if( eventNamePrefix )
    {
        for( NSString* actionNameKey in [[self actionsDict] allKeys] )
        {
            if( [actionNameKey hasPrefix:eventNamePrefix] )
            {
                hasActionsWithEventNamePrefix = YES;
                break;
            }
        }
    }
    return hasActionsWithEventNamePrefix;
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
    for( IXBaseAction* action in actionsForEventName )
    {
        BOOL enabled = [[action actionProperties] getBoolPropertyValue:@"enabled" defaultValue:YES];
        if( enabled && [action areConditionalAndOrientationMaskValid:currentOrientation usingSandbox:[self sandbox]] )
        {
            [action performSelector:@selector(execute) withObject:nil afterDelay:[[action actionProperties] getFloatPropertyValue:@"delay" defaultValue:0.0f]];
        }
    }
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString string];
    [[self actionsDict] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [description appendFormat:@"\nActions For %@:\n",key];
        for( IXBaseAction* action in obj )
        {
            [description appendString:[action description]];
        }
    }];
    return description;
}

@end
