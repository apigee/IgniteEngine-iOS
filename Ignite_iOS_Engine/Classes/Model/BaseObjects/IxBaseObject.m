//
//  IxBaseObject.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseObject.h"
#import "IxBaseAction.h"
#import "IxPropertyContainer.h"
#import "IxActionContainer.h"

@implementation IxBaseObject

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
        _childObjects = [[NSMutableArray alloc] init];
        _actionContainer = [[IxActionContainer alloc] init];
        _propertyContainer = [[IxPropertyContainer alloc] init];
    }
    return self;
}

-(IxSandbox*)sandbox
{
    return _sandbox;
}

-(IxPropertyContainer*)propertyContainer
{
    return _propertyContainer;
}

-(IxActionContainer*)actionContainer
{
    return _actionContainer;
}

-(void)setSandbox:(IxSandbox *)sandbox
{
    _sandbox = sandbox;
    
    [_actionContainer setSandbox:_sandbox];
    [_propertyContainer setSandbox:_sandbox];
    
    for( IxBaseObject* child in [self childObjects] )
    {
        [child setSandbox:_sandbox];
    }
}

-(void)setPropertyContainer:(IxPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    [_propertyContainer setSandbox:[self sandbox]];
}

-(void)setActionContainer:(IxActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    [_actionContainer setSandbox:[self sandbox]];
}

-(void)addChildObjects:(NSArray*)childObjects
{
    for( IxBaseObject* childObject in childObjects )
    {
        [self addChildObject:childObject];
    }
}

-(void)addChildObject:(IxBaseObject*)childObject
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

-(NSArray*)childrenWithID:(NSString*)childObjectID
{
    NSMutableArray* childObjectsFound = [NSMutableArray array];

    if( [[self ID] isEqualToString:childObjectID] )
        [childObjectsFound addObject:self];
        
    for( IxBaseObject* childObject in [self childObjects] )
    {
        [childObjectsFound addObjectsFromArray:[childObject childrenWithID:childObjectID]];
    }
    
    return childObjectsFound;
}

-(void)applySettings
{
    [self setID:[[self propertyContainer] getStringPropertyValue:@"id" defaultValue:[self ID]]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IxPropertyContainer*)parameterContainer
{
    
}

@end
