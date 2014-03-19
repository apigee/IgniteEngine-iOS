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
#import "IXAppManager.h"

@implementation IXBaseAction

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXPropertyContainer*)actionProperties
             parameterProperties:(IXPropertyContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer
{
    self = [super init];
    if( self )
    {
        _actionContainer = nil;
        _eventName = [eventName copy];
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
    [actionCopy setEventName:[[self eventName] copy]];
    [actionCopy setActionProperties:[[self actionProperties] copy]];
    [actionCopy setParameterProperties:[[self parameterProperties] copy]];
    [actionCopy setSubActionContainer:[[self subActionContainer] copy]];
    return actionCopy;
}

+(instancetype)actionWithEventName:(NSString*)eventName jsonDictionary:(NSDictionary*)actionJSONDict;
{
    IXBaseAction* action = nil;
    if( [actionJSONDict allKeys] > 0 )
    {
        BOOL debugMode = [actionJSONDict[kIX_DEBUG] boolValue];
        if( debugMode && [[IXAppManager sharedAppManager] appMode] != IXDebugMode )
        {
            return nil;
        }
        
        id type = actionJSONDict[kIX_TYPE];
        Class actionClass = nil;
        if( [type isKindOfClass:[NSString class]] )
        {
            NSString* actionClassString = [NSString stringWithFormat:kIX_ACTION_CLASS_NAME_FORMAT,[type capitalizedString]];
            actionClass = NSClassFromString(actionClassString);
        }
        
        if( [actionClass isSubclassOfClass:[IXBaseAction class]] )
        {
            id propertiesDict = actionJSONDict[kIX_ATTRIBUTES];
            
            id enabled = actionJSONDict[kIX_ENABLED];
            if( enabled && !propertiesDict[kIX_ENABLED] )
            {
                propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                [propertiesDict setObject:enabled forKey:kIX_ENABLED];
            }
            
            IXPropertyContainer* propertyContainer = [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict];
            IXPropertyContainer* parameterContainer = [IXPropertyContainer propertyContainerWithJSONDict:actionJSONDict[kIX_SET]];
            IXActionContainer* subActionContainer = [IXActionContainer actionContainerWithJSONActionsArray:actionJSONDict[kIX_ACTIONS]];
            
            action = [((IXBaseAction*)[actionClass alloc]) initWithEventName:eventName
                                                            actionProperties:propertyContainer
                                                         parameterProperties:parameterContainer
                                                          subActionContainer:subActionContainer];
            
            [action setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:actionJSONDict[kIX_ORIENTATION]]];
            [action setConditionalProperty:[IXProperty propertyWithPropertyName:nil rawValue:actionJSONDict[kIX_IF]]];
        }
    }
    return action;
}

+(NSArray*)actionsWithEventNames:(NSArray*)eventNames jsonDictionary:(NSDictionary*)actionJSONDict
{
    NSMutableArray* actionArray = nil;
    if( [eventNames count] )
    {
        IXBaseAction* action = nil;
        for( id eventName in eventNames )
        {
            if( [eventName isKindOfClass:[NSString class]] && [eventName length] > 0 )
            {
                if( action == nil )
                {
                    action = [IXBaseAction actionWithEventName:eventName jsonDictionary:actionJSONDict];
                    if( action ) {
                        actionArray = [NSMutableArray arrayWithObject:action];
                    } else {
                        break; // Break out of loop here if the action wasn't created on the first go around.
                    }
                }
                else
                {
                    IXBaseAction* copiedAction = [action copy];
                    [copiedAction setEventName:eventName];
                    if( copiedAction )
                    {
                        [actionArray addObject:copiedAction];
                    }
                }
            }
        }
    }
    return actionArray;
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

-(void)actionDidFinishWithEvents:(NSArray*)eventsToFire
{
    IXActionContainer* subActionContainer = [self subActionContainer];
    for( NSString* eventToFire in eventsToFire )
    {
        [subActionContainer executeActionsForEventNamed:eventToFire];
    }
    [subActionContainer executeActionsForEventNamed:kIX_FINISHED];
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
