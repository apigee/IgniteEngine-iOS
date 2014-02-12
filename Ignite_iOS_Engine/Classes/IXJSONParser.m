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
#import "IXBaseDataProvider.h"
#import "IXCoreDataDataProvider.h"
#import "IXEntityContainer.h"
#import "IXAppManager.h"
#import "IXCustom.h"
#import "IXJSONGrabber.h"

static NSCache* sCustomControlCache;

@interface IXCustomControlCacheContainer : NSObject <NSCopying>

@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) NSArray* childControls;

@end

@implementation IXCustomControlCacheContainer

-(instancetype)init
{
    return [self initWithPropertyContainer:nil actionContainer:nil childControls:nil];
}

-(instancetype)initWithPropertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer childControls:(NSArray*)childControls
{
    self = [super init];
    if( self )
    {
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _childControls = childControls;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithPropertyContainer:[[self propertyContainer] copy] actionContainer:[[self actionContainer] copy] childControls:[[NSArray alloc] initWithArray:[self childControls] copyItems:YES]];
}

@end

@implementation IXJSONParser

+(void)initialize
{
    if( sCustomControlCache == nil )
    {
        sCustomControlCache = [[NSCache alloc] init];
        [sCustomControlCache setName:@"com.ignite.CustomControlCache"];
    }
}

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
    if( [conditionalValue isKindOfClass:[NSString class]] || [conditionalValue isKindOfClass:[NSNull class]] )
    {
        if( [conditionalValue isKindOfClass:[NSNull class]] )
        {
            conditionalValue = nil;
        }
        conditionalProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:conditionalValue];
    }
    else if( [conditionalValue isKindOfClass:[NSNumber class]] )
    {
        conditionalProperty = [[IXProperty alloc] initWithPropertyName:nil rawValue:[conditionalValue stringValue]];
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
        else if( [propertyValue isKindOfClass:[NSNumber class]] )
        {
            property = [[IXProperty alloc] initWithPropertyName:propertyName rawValue:[propertyValue stringValue]];
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
    NSMutableArray* stringsToBeCommaSeperatedArray = nil;
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
        else if( [propertyValueObject isKindOfClass:[NSString class]] )
        {
            if( !stringsToBeCommaSeperatedArray )
                stringsToBeCommaSeperatedArray = [NSMutableArray arrayWithObject:propertyValueObject];
            else
                [stringsToBeCommaSeperatedArray addObject:propertyValueObject];
        }
        else
        {
            NSLog(@"WARNING: property value array for %@ does not have a dictionary objects",propertyName);
        }
    }
    if( [stringsToBeCommaSeperatedArray count] )
    {
        NSString* commaSeperatedString = [stringsToBeCommaSeperatedArray componentsJoinedByString:@","];
        IXProperty* commaSeperatedProperty = [IXProperty propertyWithPropertyName:propertyName rawValue:commaSeperatedString];
        if( commaSeperatedProperty )
        {
            [propertyArray addObject:commaSeperatedProperty];
        }
    }
    return propertyArray;
}

+(void)populatePropertyContainer:(IXPropertyContainer*)propertyContainer withPropertyDict:(NSDictionary*)propertyDictionary keyPrefix:(NSString*)keyPrefix
{
    [propertyDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        NSString* propertiesKey = key;
        if( [keyPrefix length] > 0 )
        {
            propertiesKey = [NSString stringWithFormat:@"%@.%@",keyPrefix,key];
        }
        
        if( [obj isKindOfClass:[NSArray class]] )
        {
            NSArray* properties = [IXJSONParser propertiesWithPropertyName:propertiesKey propertyValueArray:obj];
            [propertyContainer addProperties:properties];
        }
        else if( [obj isKindOfClass:[NSString class]] )
        {
            IXProperty* property = [[IXProperty alloc] initWithPropertyName:propertiesKey rawValue:obj];
            [propertyContainer addProperty:property];
        }
        else if( [obj isKindOfClass:[NSNumber class]] )
        {
            IXProperty* property = [[IXProperty alloc] initWithPropertyName:propertiesKey rawValue:[obj stringValue]];
            [propertyContainer addProperty:property];
        }
        else if( [obj isKindOfClass:[NSNull class]] )
        {
            IXProperty* property = [[IXProperty alloc] initWithPropertyName:propertiesKey rawValue:nil];
            [propertyContainer addProperty:property];
        }
        else if( [obj isKindOfClass:[NSDictionary class]] )
        {
            [IXJSONParser populatePropertyContainer:propertyContainer withPropertyDict:obj keyPrefix:propertiesKey];
        }
        else
        {
            NSLog(@"WARNING: property value for %@ not a valid object",key);
        }
    }];
}

+(IXPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertyDictionary
{
    IXPropertyContainer* propertyContainer = nil;
    if( propertyDictionary != nil && [propertyDictionary isKindOfClass:[NSDictionary class]] && [[propertyDictionary allValues] count] > 0 )
    {
        propertyContainer = [[IXPropertyContainer alloc] init];
        [IXJSONParser populatePropertyContainer:propertyContainer withPropertyDict:propertyDictionary keyPrefix:nil];
    }
    return propertyContainer;
}

+(IXBaseAction*)actionWithValueDictionary:(NSDictionary*)actionValueDict
{
    IXBaseAction* action = nil;
    if( [actionValueDict allKeys] > 0 )
    {
        BOOL debugMode = [[actionValueDict objectForKey:@"debug"] boolValue];
        if( debugMode && [[IXAppManager sharedAppManager] appMode] != IXDebugMode )
        {
            return nil;
        }
        
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
                
                id enabled = [actionValueDict objectForKey:@"enabled"];
                id propertiesDict = [actionValueDict objectForKey:@"attributes"];
                if( enabled && ![propertiesDict objectForKey:@"enabled"] )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:enabled forKey:@"enabled"];
                }                
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
            id propertiesDict = [controlValueDict objectForKey:@"attributes"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = [controlValueDict objectForKey:@"id"];
                if( controlID )
                {
                    if( [controlID isKindOfClass:[NSString class]] )
                    {
                        [control setID:controlID];
                    }
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:@"id"];
                }
                
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

+(void)populateCustomControl:(IXCustom*)customControl withJSONAtPath:(NSString*)pathToJSON async:(BOOL)async
{
    [customControl setNeedsToPopulate:NO];
    if( pathToJSON )
    {
        __block IXCustomControlCacheContainer* customControlCacheContainer = [[sCustomControlCache objectForKey:pathToJSON] copy];
        if( customControlCacheContainer == nil )
        {
            [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:pathToJSON
                                                         asynch:async
                                                completionBlock:^(id jsonObject, NSError *error) {
                                                    
                                                    if( jsonObject != nil )
                                                    {
                                                        customControlCacheContainer = [[IXCustomControlCacheContainer alloc] init];

                                                        NSDictionary* customControlAttributeDict = [jsonObject objectForKey:@"attributes"];
                                                        [customControlCacheContainer setPropertyContainer:[IXJSONParser propertyContainerWithPropertyDictionary:customControlAttributeDict]];
                                                        
                                                        NSArray* customControlActionsArray = [jsonObject objectForKey:@"actions"];
                                                        [customControlCacheContainer setActionContainer:[IXJSONParser actionContainerWithJSONActionsArray:customControlActionsArray]];
                                                        
                                                        NSArray* customControlControlsArray = [jsonObject objectForKey:@"controls"];
                                                        [customControlCacheContainer setChildControls:[IXJSONParser controlsWithJSONControlArray:customControlControlsArray]];
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                            [sCustomControlCache setObject:[customControlCacheContainer copy] forKey:pathToJSON];
                                                        });
                                                        
                                                        if( customControlCacheContainer != nil )
                                                        {
                                                            IXPropertyContainer* controlPropertyContainer = [customControl propertyContainer];
                                                            [customControl setPropertyContainer:[[customControlCacheContainer propertyContainer] copy]];
                                                            [[customControl propertyContainer] addPropertiesFromPropertyContainer:controlPropertyContainer evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
                                                            [[customControl actionContainer] addActionsFromActionContainer:[[customControlCacheContainer actionContainer] copy]];
                                                            [customControl addChildObjects:[[customControlCacheContainer childControls] copy]];
                                                            [[[customControl sandbox] containerControl] applySettings];
                                                            [[[customControl sandbox] containerControl] layoutControl];
                                                        }
                                                    }
                                                    else
                                                    {
                                                        [customControl setNeedsToPopulate:YES];
                                                        if( [[IXAppManager sharedAppManager] appMode] == IXDebugMode )
                                                        {
                                                            NSLog(@"Error grabbing custom control JSON at path %@ with error : %@",pathToJSON,[error description]);
                                                        }
                                                    }
                                                }];
        }        
        else
        {
            IXPropertyContainer* controlPropertyContainer = [customControl propertyContainer];
            [customControl setPropertyContainer:[[customControlCacheContainer propertyContainer] copy]];
            [[customControl propertyContainer] addPropertiesFromPropertyContainer:controlPropertyContainer evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
            [[customControl actionContainer] addActionsFromActionContainer:[[customControlCacheContainer actionContainer] copy]];
            [customControl addChildObjects:[[customControlCacheContainer childControls] copy]];
            [customControl setNeedsToPopulate:NO];
            [[[customControl sandbox] containerControl] applySettings];
            [[[customControl sandbox] containerControl] layoutControl];

        }
    }
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

+(IXBaseDataProvider*)dataProviderWithValueDictionary:(NSDictionary*)dataProviderValueDict
{
    IXBaseDataProvider* dataProvider = nil;
    if( [dataProviderValueDict allKeys] > 0 )
    {
        NSString* dataProviderType = [dataProviderValueDict objectForKey:@"type"];
        NSString* dataProviderClassString = [NSString stringWithFormat:@"IX%@DataProvider",dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        dataProvider = [[dataProviderClass alloc] init];
        if( dataProviderType != nil )
        {
            id propertiesDict = [dataProviderValueDict objectForKey:@"attributes"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = [dataProviderValueDict objectForKey:@"id"];
                if( controlID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:@"id"];
                }
                
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [dataProvider setPropertyContainer:propertyContainer];
                
                if( [dataProvider isKindOfClass:[IXCoreDataDataProvider class]] )
                {
                    id entitiesDict = [dataProviderValueDict objectForKey:@"entity"];
                    IXEntityContainer* entityContainer = [IXJSONParser entityContainerWithJSONEntityDict:entitiesDict];
                    [((IXCoreDataDataProvider*)dataProvider) setEntityContainer:entityContainer];
                }
                
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
                IXBaseDataProvider* dataProvider = [IXJSONParser dataProviderWithValueDictionary:dataProviderValueDict];
                if( dataProvider != nil )
                {
                    [dataProviderArray addObject:dataProvider];
                }
            }
        }
    }
    return dataProviderArray;
}


+(IXViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary pathToJSON:(NSString*)pathToJSON
{
    IXViewController* viewController = [IXViewController viewControllerWithPathToJSON:pathToJSON];
    
    NSDictionary* viewPropertyDictionary = [viewDictionary objectForKey:@"attributes"];
    
    // FIXME: Setting the properties for the view on the viewControllers containerControl.  Might need to change this not sure yet!
    IXPropertyContainer* viewPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:viewPropertyDictionary];
    [viewController setPropertyContainer:viewPropertyContainer];
    [[viewController containerControl] setPropertyContainer:viewPropertyContainer];
    
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
