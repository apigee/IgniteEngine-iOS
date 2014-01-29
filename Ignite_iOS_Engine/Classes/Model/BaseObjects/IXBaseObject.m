//
//  IXBaseObject.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseObject.h"
#import "IXBaseAction.h"
#import "IXPropertyContainer.h"
#import "IXActionContainer.h"
#import "IXBaseControl.h"

@implementation IXBaseObject

@synthesize sandbox = _sandbox;
@synthesize propertyContainer = _propertyContainer;
@synthesize actionContainer = _actionContainer;

-(id)init
{
    self = [super init];
    if( self )
    {
        _ID = nil;
        _parentObject = nil;
        _childObjects = nil;
        _actionContainer = nil;
        _propertyContainer = nil;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseObject* baseObjectCopy = [[[self class] allocWithZone:zone] init];
    if( baseObjectCopy )
    {
        [baseObjectCopy setID:[[self ID] copy]];
        if( [[self childObjects] count] )
        {
            [baseObjectCopy setChildObjects:[[NSMutableArray alloc] initWithArray:[self childObjects] copyItems:YES]];
        }
        [baseObjectCopy setActionContainer:[[self actionContainer] copy]];
        [baseObjectCopy setPropertyContainer:[[self propertyContainer] copy]];
    }
    return baseObjectCopy;
}

-(IXSandbox*)sandbox
{
    return _sandbox;
}

-(IXPropertyContainer*)propertyContainer
{
    return _propertyContainer;
}

-(IXActionContainer*)actionContainer
{
    return _actionContainer;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    _sandbox = sandbox;
    
    [_actionContainer setSandbox:_sandbox];
    [_propertyContainer setSandbox:_sandbox];
    
    for( IXBaseObject* child in [self childObjects] )
    {
        [child setSandbox:_sandbox];
    }
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    [_propertyContainer setSandbox:[self sandbox]];
}

-(void)setActionContainer:(IXActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    [_actionContainer setSandbox:[self sandbox]];
}

-(void)addChildObjects:(NSArray*)childObjects
{
    if( [childObjects count] > 0 )
    {
        for( IXBaseObject* childObject in childObjects )
        {
            [self addChildObject:childObject];
        }
    }
}

-(void)addChildObject:(IXBaseObject*)childObject
{
    [childObject setParentObject:self];
    [childObject setSandbox:[self sandbox]];
    [[childObject propertyContainer] setSandbox:[self sandbox]];
    [[childObject actionContainer] setSandbox:[self sandbox]];
    
    if( [self childObjects] == nil )
    {
        [self setChildObjects:[NSMutableArray arrayWithObject:childObject]];
    }
    else if( ![[self childObjects] containsObject:childObject] )
    {
        [[self childObjects] addObject:childObject];
    }
}

-(void)removeChildObject:(IXBaseObject*)childObject
{
    [childObject setParentObject:nil];
    if( [childObject isKindOfClass:[IXBaseControl class]] )
    {
        [[(IXBaseControl*)childObject contentView] removeFromSuperview];
    }
    [[self childObjects] removeObject:childObject];
}

-(NSArray*)childrenWithID:(NSString*)childObjectID
{
    NSMutableArray* childObjectsFound = [NSMutableArray array];

    if( [[self ID] isEqualToString:childObjectID] )
        [childObjectsFound addObject:self];
        
    for( IXBaseObject* childObject in [self childObjects] )
    {
        [childObjectsFound addObjectsFromArray:[childObject childrenWithID:childObjectID]];
    }
    
    return childObjectsFound;
}

-(void)applySettings
{
    [self setID:[[self propertyContainer] getStringPropertyValue:@"id" defaultValue:[self ID]]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    
}

-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName
{
    return nil;
}

@end
