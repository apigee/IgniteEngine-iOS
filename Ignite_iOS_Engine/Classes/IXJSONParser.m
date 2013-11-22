//
//  IXJSONParser.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/10/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXJSONParser.h"

#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXViewController.h"
#import "IXBaseControl.h"
#import "IXLayout.h"
#import "IXBaseAction.h"
#import "IXTextInput.h"
#import "IXActionContainer.h"
#import "IXBaseDataprovider.h"
#import "IXEntityContainer.h"

@implementation IXJSONParser

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue
{
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
    if( [orientationValue isKindOfClass:[NSString class]] )
    {
        if( [orientationValue isEqualToString:@"landscape"] )
        {
            mask = UIInterfaceOrientationMaskLandscape;
        }
        else if( [orientationValue isEqualToString:@"portrait"] )
        {
            mask = UIInterfaceOrientationMaskPortrait;
        }
    }
    return mask;
}

+(IXProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue
{
    IXProperty* conditionalProperty = nil;
    if( [conditionalValue isKindOfClass:[NSString class]] )
    {
        conditionalProperty = [[IXProperty alloc] initWithPropertyName:@"if" rawValue:conditionalValue];
    }
    return conditionalProperty;
}

+(IXProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict
{
    IXProperty* property = nil;
    if( propertyValueDict != nil && [[propertyValueDict allKeys] count] > 0 )
    {
        id propertyValue = [propertyValueDict objectForKey:@"value"];
        if( [propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNull class]] )
        {
            if( [propertyValue isKindOfClass:[NSNull class]] )
            {
                propertyValue = nil;
            }
            property = [[IXProperty alloc] initWithPropertyName:propertyName rawValue:propertyValue];
        }
        
        if( property != nil )
        {
            id orientation = [propertyValueDict objectForKey:@"orientation"];
            [property setInterfaceOrientationMask:[IXJSONParser orientationMaskForValue:orientation]];
            
            id conditional = [propertyValueDict objectForKey:@"if"];
            [property setConditionalProperty:[IXJSONParser conditionalPropertyForConditionalValue:conditional]];
        }
    }
    return property;
}

+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray
{
    NSMutableArray* propertyArray = [NSMutableArray array];
    for( id propertyValueObject in propertyValueArray )
    {
        if( [propertyValueObject isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary* propertyValueDict = (NSDictionary*) propertyValueObject;
            IXProperty* property = [IXJSONParser propertyWithPropertyName:propertyName propertyValueDict:propertyValueDict];
            if( property != nil )
            {
                [propertyArray addObject:property];
            }
        }
        else
        {
            NSLog(@"WARNING: property value array for %@ does not have a dictionary objects",propertyName);
        }
    }
    return propertyArray;
}

+(IXPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary
{
    IXPropertyContainer* propertyContainer = nil;
    if( propertDictionary != nil && [propertDictionary isKindOfClass:[NSDictionary class]] && [[propertDictionary allValues] count] > 0 )
    {
        propertyContainer = [[IXPropertyContainer alloc] init];
        [propertDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSArray class]] )
            {
                NSArray* properties = [IXJSONParser propertiesWithPropertyName:key propertyValueArray:obj];
                for( IXProperty* property in properties )
                {
                    [propertyContainer addProperty:property];
                }
            }
            else if( [obj isKindOfClass:[NSString class]] )
            {
                IXProperty* property = [[IXProperty alloc] initWithPropertyName:key rawValue:obj];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                IXProperty* property = [[IXProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSDictionary class]] )
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id subKey, id subObj, BOOL *stop) {
                    subKey = [NSString stringWithFormat:@"%@.%@",key,subKey];
                    if( [subObj isKindOfClass:[NSArray class]] )
                    {
                        NSArray* properties = [IXJSONParser propertiesWithPropertyName:subKey propertyValueArray:subObj];
                        for( IXProperty* property in properties )
                        {
                            [propertyContainer addProperty:property];
                        }
                    }
                    else if( [subObj isKindOfClass:[NSString class]] )
                    {
                        IXProperty* property = [[IXProperty alloc] initWithPropertyName:subKey rawValue:subObj];
                        [propertyContainer addProperty:property];
                    }
                    else if( [obj isKindOfClass:[NSNumber class]] )
                    {
                        IXProperty* property = [[IXProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                        [propertyContainer addProperty:property];
                    }
                    else
                    {
                        NSLog(@"WARNING: property value for %@ not a string or dictionary of values %@",key,[subObj description]);
                    }
                }];
            }
            else
            {
                NSLog(@"WARNING: property value for %@ not a string or dictionary of values",key);
            }
        }];
    }
    return propertyContainer;
}

+(IXBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict
{
    IXBaseAction* action = nil;
    if( [actionValueDict allKeys] > 0 )
    {
        id eventName = [actionValueDict objectForKey:@"on"];
        if( [eventName isKindOfClass:[NSString class]] )
        {
            id type = [actionValueDict objectForKey:@"type"];
            if( [type isKindOfClass:[NSString class]] )
            {
                NSString* actionClassString = [NSString stringWithFormat:@"IX%@Action",[type capitalizedString]];
                action = [[NSClassFromString(actionClassString) alloc] init];
            }
            
            if( action != nil )
            {
                [action setEventName:eventName];
                
                id orientation = [actionValueDict objectForKey:@"orientation"];
                [action setInterfaceOrientationMask:[IXJSONParser orientationMaskForValue:orientation]];
                
                id conditional = [actionValueDict objectForKey:@"if"];
                [action setConditionalProperty:[IXJSONParser conditionalPropertyForConditionalValue:conditional]];
                
                id propertiesDict = [actionValueDict objectForKey:@"properties"];
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [action setActionProperties:propertyContainer];
                
                id parametersDict = [actionValueDict objectForKey:@"parameters"];
                IXPropertyContainer* parameterContainer = [IXJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [action setParameterProperties:parameterContainer];
                
                id actionsDict = [actionValueDict objectForKey:@"actions"];
                IXActionContainer* subActionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsDict];
                [action setSubActionContainer:subActionContainer];
            }
        }
    }
    return action;
}

+(IXActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray
{
    IXActionContainer* actionContainer = nil;
    if( [actionsArray isKindOfClass:[NSArray class]] )
    {
        actionContainer = [[IXActionContainer alloc] init];
        for( id actionValueDict in actionsArray )
        {
            if( [actionValueDict isKindOfClass:[NSDictionary class]] )
            {
                IXBaseAction* action = [IXJSONParser actionWithValueDictionary:actionValueDict];
                if( action != nil )
                {
                    [actionContainer addAction:action];
                }
            }
        }
    }
    return actionContainer;
}

+(IXBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict
{
    IXBaseControl* control = nil;
    if( [controlValueDict allKeys] > 0 )
    {
        NSString* controlType = [controlValueDict objectForKey:@"type"];
        NSString* controlClassString = [NSString stringWithFormat:@"IX%@",controlType];
        
        Class controlClass = NSClassFromString(controlClassString);
        control = [[controlClass alloc] init];
        if( control != nil )
        {
            id propertiesDict = [controlValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [control setPropertyContainer:propertyContainer];
                
                id actionsArray = [controlValueDict objectForKey:@"actions"];
                IXActionContainer* actionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [control setActionContainer:actionContainer];
                
                NSArray* controlsValueArray = [controlValueDict objectForKey:@"controls"];
                NSArray* controls = [IXJSONParser controlsWithJSONControlArray:controlsValueArray];
                [control addChildObjects:controls];
            }
        }
        else
        {
            NSLog(@"JSONPARSER ERROR: Control class with name: %@ was not found \n Description of control: \n %@", controlType, [controlValueDict description]);
        }
    }
    return control;
}

+(NSArray*)controlsWithJSONControlArray:(NSArray*)controlsValueArray
{
    NSMutableArray* controlArray = nil;
    if( [controlsValueArray isKindOfClass:[NSArray class]] )
    {
        controlArray = [NSMutableArray array];
        for( id controlValueDict in controlsValueArray )
        {
            if( [controlValueDict isKindOfClass:[NSDictionary class]] )
            {
                IXBaseControl* control = [IXJSONParser controlWithValueDictionary:controlValueDict];
                if( control != nil )
                {
                    [controlArray addObject:control];
                }
            }
        }
    }
    return controlArray;
}

+(IXBaseDataprovider*)dataProviderWithValueDictionary:(NSDictionary*)dataProviderValueDict
{
    IXBaseDataprovider* dataProvider = nil;
    if( [dataProviderValueDict allKeys] > 0 )
    {
        NSString* dataProviderType = [dataProviderValueDict objectForKey:@"type"];
        NSString* dataProviderClassString = [NSString stringWithFormat:@"IX%@Dataprovider",dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        dataProvider = [[dataProviderClass alloc] init];
        if( dataProviderType != nil )
        {
            id propertiesDict = [dataProviderValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [dataProvider setPropertyContainer:propertyContainer];
                
                id entitiesDict = [dataProviderValueDict objectForKey:@"entity"];
                IXEntityContainer* entityContainer = [IXJSONParser entityContainerWithJSONEntityDict:entitiesDict];
                [dataProvider setEntityContainer:entityContainer];

                id parametersDict = [dataProviderValueDict objectForKey:@"parameters"];
                IXPropertyContainer* parametersPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [dataProvider setRequestParameterProperties:parametersPropertyContainer];
                
                id headersDict = [dataProviderValueDict objectForKey:@"headers"];
                IXPropertyContainer* headersPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:headersDict];
                [dataProvider setRequestHeaderProperties:headersPropertyContainer];

                id attachmentsDict = [dataProviderValueDict objectForKey:@"attachments"];
                IXPropertyContainer* attachmentsPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:attachmentsDict];
                [dataProvider setFileAttachmentProperties:attachmentsPropertyContainer];
                
                id actionsArray = [dataProviderValueDict objectForKey:@"actions"];
                IXActionContainer* actionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [dataProvider setActionContainer:actionContainer];            
            }
        }
        else
        {
            NSLog(@"JSONPARSER ERROR: Control class with name: %@ was not found \n Description of control: \n %@", dataProviderType, [dataProviderValueDict description]);
        }
    }
    return dataProvider;
}

+(IXEntityContainer*)entityContainerWithJSONEntityDict:(NSDictionary*)entityDict
{
    IXEntityContainer* entity = nil;
    if( [entityDict isKindOfClass:[NSDictionary class]] )
    {
        entity = [[IXEntityContainer alloc] init];
        
        [entityDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSString class]] )
            {
                IXProperty* property = [[IXProperty alloc] initWithPropertyName:key rawValue:obj];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                IXProperty* property = [[IXProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSArray class]] && [key isEqualToString:@"sub_entities"] )
            {
                for( NSDictionary* subEntityDict in obj )
                {
                    IXEntityContainer* subEntityContainer = [IXJSONParser entityContainerWithJSONEntityDict:subEntityDict];
                    if( subEntityContainer != nil )
                        [[entity subEntities] addObject:subEntityContainer];
                }
            }
        }];
    }
    return entity;
}

+(NSArray*)dataProvidersWithJSONDataProviderArray:(NSArray*)dataProvidersValueArray
{
    NSMutableArray* dataProviderArray = nil;
    if( [dataProvidersValueArray isKindOfClass:[NSArray class]] )
    {
        dataProviderArray = [NSMutableArray array];
        for( id dataProviderValueDict in dataProvidersValueArray )
        {
            if( [dataProviderValueDict isKindOfClass:[NSDictionary class]] )
            {
                IXBaseDataprovider* dataProvider = [IXJSONParser dataProviderWithValueDictionary:dataProviderValueDict];
                if( dataProvider != nil )
                {
                    [dataProviderArray addObject:dataProvider];
                }
            }
        }
    }
    return dataProviderArray;
}


+(IXViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary
{
    IXViewController* viewController = [[IXViewController alloc] init];
    
    NSDictionary* viewPropertyDictionary = [viewDictionary objectForKey:@"properties"];
    
    // FIXME: Setting the properties for the view on the viewControllers containerControl.  Might need to change this not sure yet!
    [[viewController containerControl] setPropertyContainer:[IXJSONParser propertyContainerWithPropertyDictionary:viewPropertyDictionary]];
    
    NSArray* dataProviderArray = [viewDictionary objectForKey:@"data_providers"];
    NSArray* dataProviders = [IXJSONParser dataProvidersWithJSONDataProviderArray:dataProviderArray];
    [[viewController sandbox] addDataProviders:dataProviders];
    
    NSArray* controlsValueArray = [viewDictionary objectForKey:@"controls"];
    NSArray* controls = [IXJSONParser controlsWithJSONControlArray:controlsValueArray];
    [[viewController containerControl] addChildObjects:controls];
    
    NSArray* actionsArray = [viewDictionary objectForKey:@"actions"];
    IXActionContainer* actionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsArray];
    [[viewController containerControl] setActionContainer:actionContainer];
    
    return viewController;
}

@end
