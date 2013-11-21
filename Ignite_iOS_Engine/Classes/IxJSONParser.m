//
//  IxJSONParser.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/10.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxJSONParser.h"

#import "IxPropertyContainer.h"
#import "IxProperty.h"
#import "IxViewController.h"
#import "IxBaseControl.h"
#import "IxLayout.h"
#import "IxBaseAction.h"
#import "IxTextInput.h"
#import "IxActionContainer.h"
#import "IxBaseDataprovider.h"
#import "IxEntityContainer.h"

@implementation IxJSONParser

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

+(IxProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue
{
    IxProperty* conditionalProperty = nil;
    if( [conditionalValue isKindOfClass:[NSString class]] )
    {
        conditionalProperty = [[IxProperty alloc] initWithPropertyName:@"if" rawValue:conditionalValue];
    }
    return conditionalProperty;
}

+(IxProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict
{
    IxProperty* property = nil;
    if( propertyValueDict != nil && [[propertyValueDict allKeys] count] > 0 )
    {
        id propertyValue = [propertyValueDict objectForKey:@"value"];
        if( [propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNull class]] )
        {
            if( [propertyValue isKindOfClass:[NSNull class]] )
            {
                propertyValue = nil;
            }
            property = [[IxProperty alloc] initWithPropertyName:propertyName rawValue:propertyValue];
        }
        
        if( property != nil )
        {
            id orientation = [propertyValueDict objectForKey:@"orientation"];
            [property setInterfaceOrientationMask:[IxJSONParser orientationMaskForValue:orientation]];
            
            id conditional = [propertyValueDict objectForKey:@"if"];
            [property setConditionalProperty:[IxJSONParser conditionalPropertyForConditionalValue:conditional]];
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
            IxProperty* property = [IxJSONParser propertyWithPropertyName:propertyName propertyValueDict:propertyValueDict];
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

+(IxPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary
{
    IxPropertyContainer* propertyContainer = nil;
    if( propertDictionary != nil && [propertDictionary isKindOfClass:[NSDictionary class]] && [[propertDictionary allValues] count] > 0 )
    {
        propertyContainer = [[IxPropertyContainer alloc] init];
        [propertDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSArray class]] )
            {
                NSArray* properties = [IxJSONParser propertiesWithPropertyName:key propertyValueArray:obj];
                for( IxProperty* property in properties )
                {
                    [propertyContainer addProperty:property];
                }
            }
            else if( [obj isKindOfClass:[NSString class]] )
            {
                IxProperty* property = [[IxProperty alloc] initWithPropertyName:key rawValue:obj];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                IxProperty* property = [[IxProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSDictionary class]] )
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id subKey, id subObj, BOOL *stop) {
                    subKey = [NSString stringWithFormat:@"%@.%@",key,subKey];
                    if( [subObj isKindOfClass:[NSArray class]] )
                    {
                        NSArray* properties = [IxJSONParser propertiesWithPropertyName:subKey propertyValueArray:subObj];
                        for( IxProperty* property in properties )
                        {
                            [propertyContainer addProperty:property];
                        }
                    }
                    else if( [subObj isKindOfClass:[NSString class]] )
                    {
                        IxProperty* property = [[IxProperty alloc] initWithPropertyName:subKey rawValue:subObj];
                        [propertyContainer addProperty:property];
                    }
                    else if( [obj isKindOfClass:[NSNumber class]] )
                    {
                        IxProperty* property = [[IxProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
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

+(IxBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict
{
    IxBaseAction* action = nil;
    if( [actionValueDict allKeys] > 0 )
    {
        id eventName = [actionValueDict objectForKey:@"on"];
        if( [eventName isKindOfClass:[NSString class]] )
        {
            id type = [actionValueDict objectForKey:@"type"];
            if( [type isKindOfClass:[NSString class]] )
            {
                NSString* actionClassString = [NSString stringWithFormat:@"Ix%@Action",[type capitalizedString]];
                action = [[NSClassFromString(actionClassString) alloc] init];
            }
            
            if( action != nil )
            {
                [action setEventName:eventName];
                
                id orientation = [actionValueDict objectForKey:@"orientation"];
                [action setInterfaceOrientationMask:[IxJSONParser orientationMaskForValue:orientation]];
                
                id conditional = [actionValueDict objectForKey:@"if"];
                [action setConditionalProperty:[IxJSONParser conditionalPropertyForConditionalValue:conditional]];
                
                id propertiesDict = [actionValueDict objectForKey:@"properties"];
                IxPropertyContainer* propertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [action setActionProperties:propertyContainer];
                
                id parametersDict = [actionValueDict objectForKey:@"parameters"];
                IxPropertyContainer* parameterContainer = [IxJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [action setParameterProperties:parameterContainer];
                
                id actionsDict = [actionValueDict objectForKey:@"actions"];
                IxActionContainer* subActionContainer = [IxJSONParser actionContainerWithJSONActionsArray:actionsDict];
                [action setSubActionContainer:subActionContainer];
            }
        }
    }
    return action;
}

+(IxActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray
{
    IxActionContainer* actionContainer = nil;
    if( [actionsArray isKindOfClass:[NSArray class]] )
    {
        actionContainer = [[IxActionContainer alloc] init];
        for( id actionValueDict in actionsArray )
        {
            if( [actionValueDict isKindOfClass:[NSDictionary class]] )
            {
                IxBaseAction* action = [IxJSONParser actionWithValueDictionary:actionValueDict];
                if( action != nil )
                {
                    [actionContainer addAction:action];
                }
            }
        }
    }
    return actionContainer;
}

+(IxBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict
{
    IxBaseControl* control = nil;
    if( [controlValueDict allKeys] > 0 )
    {
        NSString* controlType = [controlValueDict objectForKey:@"type"];
        NSString* controlClassString = [NSString stringWithFormat:@"Ix%@",controlType];
        
        Class controlClass = NSClassFromString(controlClassString);
        control = [[controlClass alloc] init];
        if( control != nil )
        {
            id propertiesDict = [controlValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                IxPropertyContainer* propertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [control setPropertyContainer:propertyContainer];
                
                id actionsArray = [controlValueDict objectForKey:@"actions"];
                IxActionContainer* actionContainer = [IxJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [control setActionContainer:actionContainer];
                
                NSArray* controlsValueArray = [controlValueDict objectForKey:@"controls"];
                NSArray* controls = [IxJSONParser controlsWithJSONControlArray:controlsValueArray];
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
                IxBaseControl* control = [IxJSONParser controlWithValueDictionary:controlValueDict];
                if( control != nil )
                {
                    [controlArray addObject:control];
                }
            }
        }
    }
    return controlArray;
}

+(IxBaseDataprovider*)dataProviderWithValueDictionary:(NSDictionary*)dataProviderValueDict
{
    IxBaseDataprovider* dataProvider = nil;
    if( [dataProviderValueDict allKeys] > 0 )
    {
        NSString* dataProviderType = [dataProviderValueDict objectForKey:@"type"];
        NSString* dataProviderClassString = [NSString stringWithFormat:@"Ix%@Dataprovider",dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        dataProvider = [[dataProviderClass alloc] init];
        if( dataProviderType != nil )
        {
            id propertiesDict = [dataProviderValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                IxPropertyContainer* propertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [dataProvider setPropertyContainer:propertyContainer];
                
                id entitiesDict = [dataProviderValueDict objectForKey:@"entity"];
                IxEntityContainer* entityContainer = [IxJSONParser entityContainerWithJSONEntityDict:entitiesDict];
                [dataProvider setEntityContainer:entityContainer];

                id parametersDict = [dataProviderValueDict objectForKey:@"parameters"];
                IxPropertyContainer* parametersPropertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [dataProvider setRequestParameterProperties:parametersPropertyContainer];
                
                id headersDict = [dataProviderValueDict objectForKey:@"headers"];
                IxPropertyContainer* headersPropertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:headersDict];
                [dataProvider setRequestHeaderProperties:headersPropertyContainer];

                id attachmentsDict = [dataProviderValueDict objectForKey:@"attachments"];
                IxPropertyContainer* attachmentsPropertyContainer = [IxJSONParser propertyContainerWithPropertyDictionary:attachmentsDict];
                [dataProvider setFileAttachmentProperties:attachmentsPropertyContainer];
                
                id actionsArray = [dataProviderValueDict objectForKey:@"actions"];
                IxActionContainer* actionContainer = [IxJSONParser actionContainerWithJSONActionsArray:actionsArray];
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

+(IxEntityContainer*)entityContainerWithJSONEntityDict:(NSDictionary*)entityDict
{
    IxEntityContainer* entity = nil;
    if( [entityDict isKindOfClass:[NSDictionary class]] )
    {
        entity = [[IxEntityContainer alloc] init];
        
        [entityDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSString class]] )
            {
                IxProperty* property = [[IxProperty alloc] initWithPropertyName:key rawValue:obj];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                IxProperty* property = [[IxProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSArray class]] && [key isEqualToString:@"sub_entities"] )
            {
                for( NSDictionary* subEntityDict in obj )
                {
                    IxEntityContainer* subEntityContainer = [IxJSONParser entityContainerWithJSONEntityDict:subEntityDict];
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
                IxBaseDataprovider* dataProvider = [IxJSONParser dataProviderWithValueDictionary:dataProviderValueDict];
                if( dataProvider != nil )
                {
                    [dataProviderArray addObject:dataProvider];
                }
            }
        }
    }
    return dataProviderArray;
}


+(IxViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary
{
    IxViewController* viewController = [[IxViewController alloc] init];
    
    NSDictionary* viewPropertyDictionary = [viewDictionary objectForKey:@"properties"];
    
    // FIXME: Setting the properties for the view on the viewControllers containerControl.  Might need to change this not sure yet!
    [[viewController containerControl] setPropertyContainer:[IxJSONParser propertyContainerWithPropertyDictionary:viewPropertyDictionary]];
    
    NSArray* dataProviderArray = [viewDictionary objectForKey:@"data_providers"];
    NSArray* dataProviders = [IxJSONParser dataProvidersWithJSONDataProviderArray:dataProviderArray];
    [[viewController sandbox] addDataProviders:dataProviders];
    
    NSArray* controlsValueArray = [viewDictionary objectForKey:@"controls"];
    NSArray* controls = [IxJSONParser controlsWithJSONControlArray:controlsValueArray];
    [[viewController containerControl] addChildObjects:controls];
    
    NSArray* actionsArray = [viewDictionary objectForKey:@"actions"];
    IxActionContainer* actionContainer = [IxJSONParser actionContainerWithJSONActionsArray:actionsArray];
    [[viewController containerControl] setActionContainer:actionContainer];
    
    return viewController;
}

@end
