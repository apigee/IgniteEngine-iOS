//
//  IXBaseAction.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseAction.h"

#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXActionContainer.h"
#import "IXBaseObject.h"

@implementation IXBaseAction

-(instancetype)init
{
    return [self initWithEventName:nil
                  actionProperties:nil
               parameterProperties:nil
                subActionContainer:nil];
}

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXPropertyContainer*)actionProperties
             parameterProperties:(IXPropertyContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer
{
    self = [super init];
    if( self )
    {
        _actionContainer = nil;
        _eventName = eventName;
        _actionProperties = actionProperties;
        _parameterProperties = parameterProperties;
        _subActionContainer = subActionContainer;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseAction* actionCopy = [super copyWithZone:zone];
    [actionCopy setActionContainer:[self actionContainer]];
    [actionCopy setEventName:[self eventName]];
    [actionCopy setActionProperties:[[self actionProperties] copy]];
    [actionCopy setParameterProperties:[[self parameterProperties] copy]];
    [actionCopy setSubActionContainer:[[self subActionContainer] copy]];
    return actionCopy;
}

-(void)execute
{
    // Base action does nothing.
}

-(void)setActionProperties:(IXPropertyContainer *)actionProperties
{
    _actionProperties = actionProperties;
    [[self conditionalProperty] setPropertyContainer:actionProperties];
}
    
-(void)setActionContainer:(IXActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    
    [[self actionProperties] setOwnerObject:[actionContainer ownerObject]];
    [[self parameterProperties] setOwnerObject:[actionContainer ownerObject]];
    [[self subActionContainer] setOwnerObject:[actionContainer ownerObject]];
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString stringWithFormat:@"\n%@ on %@:",NSStringFromClass([self class]),[self eventName]];
    if( [self conditionalProperty] )
    {
        [description appendFormat:@"\n\nConditional: %@",[[self conditionalProperty] getPropertyValue]];
        if( [[self conditionalProperty] shortCodes] )
        {
            [description appendFormat:@" (%@)",[[self conditionalProperty] originalString]];
        }
    }
    [description appendFormat:@"\n\nProperties:\n%@ ",[[self actionProperties] description]];
    if( [self parameterProperties] )
    {
        [description appendFormat:@"\nParameters:\n%@ ",[[self parameterProperties] description]];
    }
    if( [self subActionContainer] )
    {
        [description appendFormat:@"\nSub Actions:\n%@ ",[[self subActionContainer] description]];
    }
    return description;
}

@end
