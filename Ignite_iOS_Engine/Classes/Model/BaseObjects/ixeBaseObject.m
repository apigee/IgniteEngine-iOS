//
//  ixeBaseObject.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseObject.h"
#import "ixeBaseAction.h"
#import "ixePropertyContainer.h"
#import "ixeActionContainer.h"

@implementation ixeBaseObject

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
        _actionContainer = [[ixeActionContainer alloc] init];
        _propertyContainer = [[ixePropertyContainer alloc] init];
    }
    return self;
}

-(ixeSandbox*)sandbox
{
    return _sandbox;
}

-(ixePropertyContainer*)propertyContainer
{
    return _propertyContainer;
}

-(ixeActionContainer*)actionContainer
{
    return _actionContainer;
}

-(void)setSandbox:(ixeSandbox *)sandbox
{
    _sandbox = sandbox;
    
    [_actionContainer setSandbox:_sandbox];
    [_propertyContainer setSandbox:_sandbox];
    
    for( ixeBaseObject* child in [self childObjects] )
    {
        [child setSandbox:_sandbox];
    }
}

-(void)setPropertyContainer:(ixePropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    [_propertyContainer setSandbox:[self sandbox]];
}

-(void)setActionContainer:(ixeActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    [_actionContainer setSandbox:[self sandbox]];
}

-(void)addChildObjects:(NSArray*)childObjects
{
    for( ixeBaseObject* childObject in childObjects )
    {
        [self addChildObject:childObject];
    }
}

-(void)addChildObject:(ixeBaseObject*)childObject
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
        
    for( ixeBaseObject* childObject in [self childObjects] )
    {
        [childObjectsFound addObjectsFromArray:[childObject childrenWithID:childObjectID]];
    }
    
    return childObjectsFound;
}

-(void)applySettings
{
    [self setID:[[self propertyContainer] getStringPropertyValue:@"id" defaultValue:[self ID]]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(ixePropertyContainer*)parameterContainer
{
    
}

@end
