//
//  IXBaseObject.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXBaseObject.h"
#import "IXBaseAction.h"
#import "IXAttributeContainer.h"
#import "IXActionContainer.h"
#import "IXBaseControl.h"

// IXBaseObject ReadOnly Attributes
static NSString* kIXDescription = @"description";

// NSCoding Key Constants
static NSString* kIXIDNSCodingKey = @"ID";
static NSString* kIXStyleClassNSCodingKey = @"styleClass";
static NSString* kIXActionContainerNSCodingKey = @"actionContainer";
static NSString* kIXPropertyContainerNSCodingKey = @"attributeContainer";
static NSString* kIXChildObjectsNSCodingKey = @"childObjects";

@implementation IXBaseObject

@synthesize sandbox = _sandbox;
@synthesize attributeContainer = _attributeContainer;
@synthesize actionContainer = _actionContainer;

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseObject* baseObjectCopy = [[[self class] allocWithZone:zone] init];
    if( baseObjectCopy )
    {
        [baseObjectCopy setID:[[self ID] copy]];
        [baseObjectCopy setStyleClass:[[self styleClass] copy]];
        if( [[self childObjects] count] )
        {
            NSArray* childObjectsCopy = [[NSMutableArray alloc] initWithArray:[self childObjects] copyItems:YES];
            [baseObjectCopy addChildObjects:childObjectsCopy];
        }
        [baseObjectCopy setActionContainer:[[self actionContainer] copy]];
        [baseObjectCopy setAttributeContainer:[[self attributeContainer] copy]];
    }
    return baseObjectCopy;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self ID] forKey:kIXIDNSCodingKey];
    [aCoder encodeObject:[self styleClass] forKey:kIXStyleClassNSCodingKey];
    [aCoder encodeObject:[self actionContainer] forKey:kIXActionContainerNSCodingKey];
    [aCoder encodeObject:[self attributeContainer] forKey:kIXPropertyContainerNSCodingKey];
    [aCoder encodeObject:[self childObjects] forKey:kIXChildObjectsNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if( self != nil )
    {
        [self setID:[aDecoder decodeObjectForKey:kIXIDNSCodingKey]];
        [self setStyleClass:[aDecoder decodeObjectForKey:kIXStyleClassNSCodingKey]];
        [self setActionContainer:[aDecoder decodeObjectForKey:kIXActionContainerNSCodingKey]];
        [self setAttributeContainer:[aDecoder decodeObjectForKey:kIXPropertyContainerNSCodingKey]];
        [self addChildObjects:[aDecoder decodeObjectForKey:kIXChildObjectsNSCodingKey]];
    }
    return self;
}

-(IXSandbox*)sandbox
{
    return _sandbox;
}

-(IXAttributeContainer*)attributeContainer
{
    return _attributeContainer;
}

-(IXActionContainer*)actionContainer
{
    return _actionContainer;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    _sandbox = sandbox;    
    for( IXBaseObject* child in [self childObjects] )
    {
        [child setSandbox:_sandbox];
    }
}

-(void)setAttributeContainer:(IXAttributeContainer *)propertyContainer
{
    _attributeContainer = propertyContainer;
    [_attributeContainer setOwnerObject:self];
}

-(void)setActionContainer:(IXActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    [_actionContainer setOwnerObject:self];
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

-(NSArray*)childrenThatAreKindOfClass:(Class)baseObjectClass
{
    NSMutableArray* childObjectsFound = [NSMutableArray array];
    
    if( [self isKindOfClass:baseObjectClass] )
        [childObjectsFound addObject:self];
    
    for( IXBaseObject* childObject in [self childObjects] )
    {
        [childObjectsFound addObjectsFromArray:[childObject childrenThatAreKindOfClass:baseObjectClass]];
    }
    
    return childObjectsFound;
}

-(void)applySettings
{
    [self setID:[[self attributeContainer] getStringValueForAttribute:kIX_ID defaultValue:[self ID]]];
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXAttributeContainer*)parameterContainer
{
    
}


-(void)beginAnimation:(NSString*)animation duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount params:(NSDictionary*)params
{
    
}

-(void)endAnimation:(NSString*)animation
{
    
}

-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXDescription] )
    {
        returnValue = [self description];
    }
    return returnValue;
}

-(NSString*)description
{
    NSMutableString* description = [[NSMutableString alloc] initWithString:[super description]];
    [description appendString:[NSMutableString stringWithFormat:@"\n%@ Description : \n\nProperties:\n\n%@",NSStringFromClass([self class]),[[self attributeContainer] description]]];    
    if( [self actionContainer] )
    {
        [description appendFormat:@"\nActions:\n%@",[[self actionContainer] description]];
    }
    for( IXBaseObject* childObject in [self childObjects] )
    {
        [description appendString:[childObject description]];
    }
    return description;
}

@end
