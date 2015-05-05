//
//  IXBaseAction.m
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

#import "IXBaseAction.h"

#import "IXAttributeContainer.h"
#import "IXAttribute.h"
#import "IXActionContainer.h"
#import "IXBaseObject.h"
#import "IXAppManager.h"

// NSCoding Key Constants
static NSString* const kIXEventNameNSCodingKey = @"eventName";
static NSString* const kIXActionPropertiesNSCodingKey = @"actionProperties";
static NSString* const kIXSetPropertiesNSCodingKey = @"setProperties";
static NSString* const kIXSubActionContainerNSCodingKey = @"subActionContainer";

@interface IXBaseAction ()

@property (nonatomic,assign) BOOL didRegisterForNotifications;

@end

@implementation IXBaseAction

-(void)dealloc
{
    if( _didRegisterForNotifications )
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXAttributeContainer*)actionProperties
                   setProperties:(IXAttributeContainer*)setProperties
              subActionContainer:(IXActionContainer*)subActionContainer
{
    self = [super init];
    if( self )
    {
        _actionContainer = nil;
        _actionProperties = actionProperties;
        _setProperties = setProperties;
        _subActionContainer = subActionContainer;
        
        [self setEventName:eventName];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseAction* actionCopy = [super copyWithZone:zone];
    if( actionCopy )
    {
        [actionCopy setActionContainer:[self actionContainer]];
        [actionCopy setEventName:[[self eventName] copy]];
        [actionCopy setActionProperties:[[self actionProperties] copy]];
        [actionCopy setSetProperties:[[self setProperties] copy]];
        [actionCopy setSubActionContainer:[[self subActionContainer] copy]];
    }
    return actionCopy;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setEventName:[aDecoder decodeObjectForKey:kIXEventNameNSCodingKey]];
        [self setActionProperties:[aDecoder decodeObjectForKey:kIXActionPropertiesNSCodingKey]];
        [self setSetProperties:[aDecoder decodeObjectForKey:kIXSetPropertiesNSCodingKey]];
        [self setSubActionContainer:[aDecoder decodeObjectForKey:kIXSubActionContainerNSCodingKey]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self eventName] forKey:kIXEventNameNSCodingKey];
    [aCoder encodeObject:[self actionProperties] forKey:kIXActionPropertiesNSCodingKey];
    [aCoder encodeObject:[self setProperties] forKey:kIXSetPropertiesNSCodingKey];
    [aCoder encodeObject:[self subActionContainer] forKey:kIXSubActionContainerNSCodingKey];
}

+(instancetype)actionWithRemoteNotificationInfo:(NSDictionary *)remoteNotificationInfo
{
    IXBaseAction* action = nil;
    id actionArray = [remoteNotificationInfo objectForKey:kIX_ACTION];
    if( [actionArray isKindOfClass:[NSArray class]] )
    {
        Class actionClass = nil;
        id type = [actionArray firstObject];
        if( [type isKindOfClass:[NSString class]] )
        {
            NSString* actionClassString = [NSString stringWithFormat:kIX_ACTION_CLASS_NAME_FORMAT,[type capitalizedString]];
            actionClass = NSClassFromString(actionClassString);
        }
        
        if( [actionClass isSubclassOfClass:[IXBaseAction class]] )
        {
            id attributesTopLevelDict = [actionArray objectAtIndex:1];
            if( [attributesTopLevelDict isKindOfClass:[NSDictionary class]] )
            {
                IXAttributeContainer* propertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:attributesTopLevelDict[kIX_ATTRIBUTES]];
                IXAttributeContainer* setContainer = ([IXAttributeContainer attributeContainerWithJSONDict:attributesTopLevelDict[kIX_SET]]) ?: [IXAttributeContainer attributeContainerWithJSONDict:attributesTopLevelDict[kIX_FUNCTION_PARAMETERS]];
                IXActionContainer* subActionContainer = [IXActionContainer actionContainerWithJSONActionsArray:attributesTopLevelDict[kIX_ACTIONS]];
                
                action = [((IXBaseAction*)[actionClass alloc]) initWithEventName:kIXPushRecievedEvent
                                                                actionProperties:propertyContainer
                                                                   setProperties:setContainer
                                                              subActionContainer:subActionContainer];
                
                [action setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:attributesTopLevelDict[kIX_ORIENTATION]]];
                [action setValueIfTrue:[IXAttribute attributeWithAttributeName:nil rawValue:attributesTopLevelDict[kIX_IF]]];
            }
        }
    }
    return action;
}

+(instancetype)actionWithCustomURLQueryParams:(NSDictionary *)queryParams
{
    IXBaseAction* action = nil;

    Class actionClass = nil;
    NSString* actionType = [queryParams objectForKey:kIX_TYPE];
    if( [actionType isKindOfClass:[NSString class]] )
    {
        NSString* actionClassString = [NSString stringWithFormat:kIX_ACTION_CLASS_NAME_FORMAT,[actionType capitalizedString]];
        actionClass = NSClassFromString(actionClassString);
    }

    if( [actionClass isSubclassOfClass:[IXBaseAction class]] )
    {
        NSString* ifValue = [queryParams objectForKey:kIX_IF];
        NSString* orientationValue = [queryParams objectForKey:kIX_ORIENTATION];

        NSMutableDictionary* mutableQueryParams = [queryParams mutableCopy];
        [mutableQueryParams removeObjectForKey:kIX_TYPE];
        [mutableQueryParams removeObjectForKey:kIX_IF];
        [mutableQueryParams removeObjectForKey:kIX_ORIENTATION];

        IXAttributeContainer* paramsAsPropertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:mutableQueryParams];
        action = [(IXBaseAction*)[actionClass alloc] initWithEventName:kIXCustomURLSchemeOpened
                                                      actionProperties:paramsAsPropertyContainer
                                                         setProperties:paramsAsPropertyContainer
                                                    subActionContainer:nil];

        if( [orientationValue length] > 0 ) {
            [action setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:orientationValue]];
        }
        if( [ifValue length] > 0 ) {
            [action setValueIfTrue:[IXAttribute attributeWithAttributeName:nil rawValue:ifValue]];
        }
    }
    return action;
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
            
            IXAttributeContainer* propertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict];
            IXAttributeContainer* setContainer = ([IXAttributeContainer attributeContainerWithJSONDict:actionJSONDict[kIX_SET]]) ?: [IXAttributeContainer attributeContainerWithJSONDict:actionJSONDict[kIX_FUNCTION_PARAMETERS]];
            IXActionContainer* subActionContainer = [IXActionContainer actionContainerWithJSONActionsArray:actionJSONDict[kIX_ACTIONS]];
            
            action = [((IXBaseAction*)[actionClass alloc]) initWithEventName:eventName
                                                            actionProperties:propertyContainer
                                                               setProperties:setContainer
                                                          subActionContainer:subActionContainer];
            
            [action setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:actionJSONDict[kIX_ORIENTATION]]];
            [action setValueIfTrue:[IXAttribute attributeWithAttributeName:nil rawValue:actionJSONDict[kIX_IF]]];
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

-(void)executeBecauseOfNotification:(NSNotification*)notification
{
    DDLogDebug(@"%@ : Did fire because of notification -> %@", NSStringFromClass([self class]),[notification name]);
    
    [self execute];
}

-(void)execute
{
    // Base action does nothing.
}

-(void)setActionProperties:(IXAttributeContainer *)actionProperties
{
    _actionProperties = actionProperties;
    [[self valueIfTrue] setAttributeContainer:actionProperties];
}
    
-(void)setActionContainer:(IXActionContainer *)actionContainer
{
    _actionContainer = actionContainer;
    
    [[self actionProperties] setOwnerObject:[actionContainer ownerObject]];
    [[self setProperties] setOwnerObject:[actionContainer ownerObject]];
    [[self subActionContainer] setOwnerObject:[actionContainer ownerObject]];
}

-(void)actionDidFinishWithEvents:(NSArray*)eventsToFire
{
    IXActionContainer* subActionContainer = [self subActionContainer];
    for( NSString* eventToFire in eventsToFire )
    {
        [subActionContainer executeActionsForEventNamed:eventToFire];
    }
    [subActionContainer executeActionsForEventNamed:kIX_DONE];
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString stringWithFormat:@"\n%@ on %@:",NSStringFromClass([self class]),[self eventName]];
    if( [self valueIfTrue] )
    {
        [description appendFormat:@"\n\nConditional: %@",[[self valueIfTrue] attributeStringValue]];
        if( [[self valueIfTrue] evaluations] )
        {
            [description appendFormat:@" (%@)",[[self valueIfTrue] originalString]];
        }
    }
    [description appendFormat:@"\n\nProperties:\n%@ ",[[self actionProperties] description]];
    if( [self setProperties] )
    {
        [description appendFormat:@"\nSet:\n%@ ",[[self setProperties] description]];
    }
    if( [self subActionContainer] )
    {
        [description appendFormat:@"\nSub Actions:\n%@ ",[[self subActionContainer] description]];
    }
    return description;
}

@end
