//
//  ixeJSONParser.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/10.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeJSONParser.h"

#import "ixePropertyContainer.h"
#import "ixeProperty.h"
#import "ixeViewController.h"
#import "ixeBaseControl.h"
#import "ixeLayout.h"
#import "ixeBaseAction.h"
#import "ixeTextInput.h"
#import "ixeActionContainer.h"
#import "ixeBaseDataprovider.h"
#import "ixeEntityContainer.h"

@implementation ixeJSONParser

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

+(ixeProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue
{
    ixeProperty* conditionalProperty = nil;
    if( [conditionalValue isKindOfClass:[NSString class]] )
    {
        conditionalProperty = [[ixeProperty alloc] initWithPropertyName:@"if" rawValue:conditionalValue];
    }
    return conditionalProperty;
}

+(ixeProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict
{
    ixeProperty* property = nil;
    if( propertyValueDict != nil && [[propertyValueDict allKeys] count] > 0 )
    {
        id propertyValue = [propertyValueDict objectForKey:@"value"];
        if( [propertyValue isKindOfClass:[NSString class]] || [propertyValue isKindOfClass:[NSNull class]] )
        {
            if( [propertyValue isKindOfClass:[NSNull class]] )
            {
                propertyValue = nil;
            }
            property = [[ixeProperty alloc] initWithPropertyName:propertyName rawValue:propertyValue];
        }
        
        if( property != nil )
        {
            id orientation = [propertyValueDict objectForKey:@"orientation"];
            [property setInterfaceOrientationMask:[ixeJSONParser orientationMaskForValue:orientation]];
            
            id conditional = [propertyValueDict objectForKey:@"if"];
            [property setConditionalProperty:[ixeJSONParser conditionalPropertyForConditionalValue:conditional]];
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
            ixeProperty* property = [ixeJSONParser propertyWithPropertyName:propertyName propertyValueDict:propertyValueDict];
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

+(ixePropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary
{
    ixePropertyContainer* propertyContainer = nil;
    if( propertDictionary != nil && [propertDictionary isKindOfClass:[NSDictionary class]] && [[propertDictionary allValues] count] > 0 )
    {
        propertyContainer = [[ixePropertyContainer alloc] init];
        [propertDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSArray class]] )
            {
                NSArray* properties = [ixeJSONParser propertiesWithPropertyName:key propertyValueArray:obj];
                for( ixeProperty* property in properties )
                {
                    [propertyContainer addProperty:property];
                }
            }
            else if( [obj isKindOfClass:[NSString class]] )
            {
                ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:key rawValue:obj];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [propertyContainer addProperty:property];
            }
            else if( [obj isKindOfClass:[NSDictionary class]] )
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id subKey, id subObj, BOOL *stop) {
                    subKey = [NSString stringWithFormat:@"%@.%@",key,subKey];
                    if( [subObj isKindOfClass:[NSArray class]] )
                    {
                        NSArray* properties = [ixeJSONParser propertiesWithPropertyName:subKey propertyValueArray:subObj];
                        for( ixeProperty* property in properties )
                        {
                            [propertyContainer addProperty:property];
                        }
                    }
                    else if( [subObj isKindOfClass:[NSString class]] )
                    {
                        ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:subKey rawValue:subObj];
                        [propertyContainer addProperty:property];
                    }
                    else if( [obj isKindOfClass:[NSNumber class]] )
                    {
                        ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
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

+(ixeBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict
{
    ixeBaseAction* action = nil;
    if( [actionValueDict allKeys] > 0 )
    {
        id eventName = [actionValueDict objectForKey:@"on"];
        if( [eventName isKindOfClass:[NSString class]] )
        {
            id type = [actionValueDict objectForKey:@"type"];
            if( [type isKindOfClass:[NSString class]] )
            {
                NSString* actionClassString = [NSString stringWithFormat:@"ixe%@Action",[type capitalizedString]];
                action = [[NSClassFromString(actionClassString) alloc] init];
            }
            
            if( action != nil )
            {
                [action setEventName:eventName];
                
                id orientation = [actionValueDict objectForKey:@"orientation"];
                [action setInterfaceOrientationMask:[ixeJSONParser orientationMaskForValue:orientation]];
                
                id conditional = [actionValueDict objectForKey:@"if"];
                [action setConditionalProperty:[ixeJSONParser conditionalPropertyForConditionalValue:conditional]];
                
                id propertiesDict = [actionValueDict objectForKey:@"properties"];
                ixePropertyContainer* propertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [action setActionProperties:propertyContainer];
                
                id parametersDict = [actionValueDict objectForKey:@"parameters"];
                ixePropertyContainer* parameterContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [action setParameterProperties:parameterContainer];
                
                id actionsDict = [actionValueDict objectForKey:@"actions"];
                ixeActionContainer* subActionContainer = [ixeJSONParser actionContainerWithJSONActionsArray:actionsDict];
                [action setSubActionContainer:subActionContainer];
            }
        }
    }
    return action;
}

+(ixeActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray
{
    ixeActionContainer* actionContainer = nil;
    if( [actionsArray isKindOfClass:[NSArray class]] )
    {
        actionContainer = [[ixeActionContainer alloc] init];
        for( id actionValueDict in actionsArray )
        {
            if( [actionValueDict isKindOfClass:[NSDictionary class]] )
            {
                ixeBaseAction* action = [ixeJSONParser actionWithValueDictionary:actionValueDict];
                if( action != nil )
                {
                    [actionContainer addAction:action];
                }
            }
        }
    }
    return actionContainer;
}

+(ixeBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict
{
    ixeBaseControl* control = nil;
    if( [controlValueDict allKeys] > 0 )
    {
        NSString* controlType = [controlValueDict objectForKey:@"type"];
        NSString* controlClassString = [NSString stringWithFormat:@"ixe%@",controlType];
        
        Class controlClass = NSClassFromString(controlClassString);
        control = [[controlClass alloc] init];
        if( control != nil )
        {
            id propertiesDict = [controlValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                ixePropertyContainer* propertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [control setPropertyContainer:propertyContainer];
                
                id actionsArray = [controlValueDict objectForKey:@"actions"];
                ixeActionContainer* actionContainer = [ixeJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [control setActionContainer:actionContainer];
                
                NSArray* controlsValueArray = [controlValueDict objectForKey:@"controls"];
                NSArray* controls = [ixeJSONParser controlsWithJSONControlArray:controlsValueArray];
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
                ixeBaseControl* control = [ixeJSONParser controlWithValueDictionary:controlValueDict];
                if( control != nil )
                {
                    [controlArray addObject:control];
                }
            }
        }
    }
    return controlArray;
}

+(ixeBaseDataprovider*)dataProviderWithValueDictionary:(NSDictionary*)dataProviderValueDict
{
    ixeBaseDataprovider* dataProvider = nil;
    if( [dataProviderValueDict allKeys] > 0 )
    {
        NSString* dataProviderType = [dataProviderValueDict objectForKey:@"type"];
        NSString* dataProviderClassString = [NSString stringWithFormat:@"ixe%@Dataprovider",dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        dataProvider = [[dataProviderClass alloc] init];
        if( dataProviderType != nil )
        {
            id propertiesDict = [dataProviderValueDict objectForKey:@"properties"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                ixePropertyContainer* propertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [dataProvider setPropertyContainer:propertyContainer];
                
                id entitiesDict = [dataProviderValueDict objectForKey:@"entity"];
                ixeEntityContainer* entityContainer = [ixeJSONParser entityContainerWithJSONEntityDict:entitiesDict];
                [dataProvider setEntityContainer:entityContainer];

                id parametersDict = [dataProviderValueDict objectForKey:@"parameters"];
                ixePropertyContainer* parametersPropertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [dataProvider setRequestParameterProperties:parametersPropertyContainer];
                
                id headersDict = [dataProviderValueDict objectForKey:@"headers"];
                ixePropertyContainer* headersPropertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:headersDict];
                [dataProvider setRequestHeaderProperties:headersPropertyContainer];

                id attachmentsDict = [dataProviderValueDict objectForKey:@"attachments"];
                ixePropertyContainer* attachmentsPropertyContainer = [ixeJSONParser propertyContainerWithPropertyDictionary:attachmentsDict];
                [dataProvider setFileAttachmentProperties:attachmentsPropertyContainer];
                
                id actionsArray = [dataProviderValueDict objectForKey:@"actions"];
                ixeActionContainer* actionContainer = [ixeJSONParser actionContainerWithJSONActionsArray:actionsArray];
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

+(ixeEntityContainer*)entityContainerWithJSONEntityDict:(NSDictionary*)entityDict
{
    ixeEntityContainer* entity = nil;
    if( [entityDict isKindOfClass:[NSDictionary class]] )
    {
        entity = [[ixeEntityContainer alloc] init];
        
        [entityDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if( [obj isKindOfClass:[NSString class]] )
            {
                ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:key rawValue:obj];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSNumber class]] )
            {
                ixeProperty* property = [[ixeProperty alloc] initWithPropertyName:key rawValue:[obj stringValue]];
                [[entity entityProperties] addProperty:property];
            }
            else if( [obj isKindOfClass:[NSArray class]] && [key isEqualToString:@"sub_entities"] )
            {
                for( NSDictionary* subEntityDict in obj )
                {
                    ixeEntityContainer* subEntityContainer = [ixeJSONParser entityContainerWithJSONEntityDict:subEntityDict];
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
                ixeBaseDataprovider* dataProvider = [ixeJSONParser dataProviderWithValueDictionary:dataProviderValueDict];
                if( dataProvider != nil )
                {
                    [dataProviderArray addObject:dataProvider];
                }
            }
        }
    }
    return dataProviderArray;
}


+(ixeViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary
{
    ixeViewController* viewController = [[ixeViewController alloc] init];
    
    NSDictionary* viewPropertyDictionary = [viewDictionary objectForKey:@"properties"];
    
    // FIXME: Setting the properties for the view on the viewControllers containerControl.  Might need to change this not sure yet!
    [[viewController containerControl] setPropertyContainer:[ixeJSONParser propertyContainerWithPropertyDictionary:viewPropertyDictionary]];
    
    NSArray* dataProviderArray = [viewDictionary objectForKey:@"data_providers"];
    NSArray* dataProviders = [ixeJSONParser dataProvidersWithJSONDataProviderArray:dataProviderArray];
    [[viewController sandbox] addDataProviders:dataProviders];
    
    NSArray* controlsValueArray = [viewDictionary objectForKey:@"controls"];
    NSArray* controls = [ixeJSONParser controlsWithJSONControlArray:controlsValueArray];
    [[viewController containerControl] addChildObjects:controls];
    
    NSArray* actionsArray = [viewDictionary objectForKey:@"actions"];
    ixeActionContainer* actionContainer = [ixeJSONParser actionContainerWithJSONActionsArray:actionsArray];
    [[viewController containerControl] setActionContainer:actionContainer];
    
    return viewController;
}

@end
