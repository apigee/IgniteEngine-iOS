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

@implementation IXBaseAction

-(instancetype)init
{
    return [self initWithEventName:nil
                  actionProperties:[[IXPropertyContainer alloc] init]
               parameterProperties:[[IXPropertyContainer alloc] init]
                subActionContainer:[[IXActionContainer alloc] init]];
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
    IXBaseAction* actionCopy = [[[self class] allocWithZone:zone] init];
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

@end
