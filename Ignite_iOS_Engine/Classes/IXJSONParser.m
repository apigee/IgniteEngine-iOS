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
#import "IXBaseControlConfig.h"
#import "IXBaseDataProviderConfig.h"
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
#import "IXLogger.h"
#import "IXPathHandler.h"

static NSCache* sCustomControlCache;

@interface IXCustomControlCacheContainer : NSObject <NSCopying>

@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) NSArray* childConfigControls;
@property (nonatomic,strong) NSArray* dataProviderConfigs;

@end

@implementation IXCustomControlCacheContainer

-(instancetype)init
{
    return [self initWithPropertyContainer:nil actionContainer:nil childConfigControls:nil dataProviderConfigs:nil];
}

-(instancetype)initWithPropertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer childConfigControls:(NSArray*)childConfigControls dataProviderConfigs:(NSArray*)dataProviderConfigs
{
    self = [super init];
    if( self )
    {
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _childConfigControls = childConfigControls;
        _dataProviderConfigs = dataProviderConfigs;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithPropertyContainer:[[self propertyContainer] copy]
                                                        actionContainer:[[self actionContainer] copy]
                                                    childConfigControls:[[NSArray alloc] initWithArray:[self childConfigControls] copyItems:YES]
                                                    dataProviderConfigs:[[NSArray alloc] initWithArray:[self dataProviderConfigs] copyItems:YES]];
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
            DDLogWarn(@"WARNING from %@ in %@ : Property value array for %@ does not have a dictionary objects",THIS_FILE,THIS_METHOD,propertyName);
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
            DDLogWarn(@"WARNING from %@ in %@ : Property value for %@ not a valid object",THIS_FILE,THIS_METHOD,key);
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

+(NSArray*)actionsWithEventNames:(NSArray*)eventNames actionValueDictionary:(NSDictionary*)actionValueDict
{
    NSMutableArray* actionArray = nil;
    if( [eventNames count] )
    {
        IXBaseAction* action = nil;
        for( id eventName in eventNames )
        {
            if( [eventName isKindOfClass:[NSString class]] )
            {
                if( action == nil )
                {
                    action = [IXJSONParser actionWithEventName:eventName valueDictionary:actionValueDict];
                    if( action )
                    {
                        actionArray = [NSMutableArray arrayWithObject:action];
                    }
                    else
                    {
                        // Break out of loop here if the action wasn't created on the first go around.
                        break;
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

+(IXBaseAction*)actionWithEventName:(NSString*)eventName valueDictionary:(NSDictionary*)actionValueDict
{
    IXBaseAction* action = nil;
    if( [actionValueDict allKeys] > 0 )
    {
        BOOL debugMode = [[actionValueDict objectForKey:@"debug"] boolValue];
        if( debugMode && [[IXAppManager sharedAppManager] appMode] != IXDebugMode )
        {
            return nil;
        }
        
        id type = [actionValueDict objectForKey:kIX_TYPE];
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
            
            id parametersDict = [actionValueDict objectForKey:@"set"];
            IXPropertyContainer* parameterContainer = [IXJSONParser propertyContainerWithPropertyDictionary:parametersDict];
            [action setParameterProperties:parameterContainer];
            
            id actionsDict = [actionValueDict objectForKey:@"actions"];
            IXActionContainer* subActionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsDict];
            [action setSubActionContainer:subActionContainer];
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
                id eventNameValue = [actionValueDict objectForKey:@"on"];
                NSArray* eventNameStrings = nil;
                if( eventNameValue )
                {
                    if( [eventNameValue isKindOfClass:[NSString class]] )
                    {
                        eventNameStrings = [eventNameValue componentsSeparatedByString:@","];
                    }
                    else if( [eventNameValue isKindOfClass:[NSArray class]] )
                    {
                        eventNameStrings = eventNameValue;
                    }
                    
                    if( [eventNameStrings count] > 1 )
                    {
                        NSArray* actions = [IXJSONParser actionsWithEventNames:eventNameStrings actionValueDictionary:actionValueDict];
                        [actionContainer addActions:actions];
                    }
                    else
                    {
                        IXBaseAction* action = [IXJSONParser actionWithEventName:[eventNameStrings firstObject] valueDictionary:actionValueDict];
                        [actionContainer addAction:action];
                    }
                }
            }
        }
    }
    return actionContainer;
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

+(IXBaseControlConfig*)controlConfigWithValueDictionary:(NSDictionary*)controlValueDict
{
    IXBaseControlConfig* controlConfig = nil;
    if( [controlValueDict allKeys] > 0 )
    {
        NSString* controlType = [controlValueDict objectForKey:kIX_TYPE];
        NSString* controlClassString = [NSString stringWithFormat:@"IX%@",controlType];
        
        Class controlClass = NSClassFromString(controlClassString);
        if( controlClass != nil )
        {
            controlConfig = [[IXBaseControlConfig alloc] init];
            [controlConfig setControlClass:controlClass];
            id propertiesDict = [controlValueDict objectForKey:@"attributes"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = [controlValueDict objectForKey:kIX_ID];
                if( controlID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:kIX_ID];
                }
                
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [controlConfig setPropertyContainer:propertyContainer];
                
                id actionsArray = [controlValueDict objectForKey:@"actions"];
                IXActionContainer* actionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [controlConfig setActionContainer:actionContainer];
                
                NSArray* controlsValueArray = [controlValueDict objectForKey:@"controls"];
                NSArray* childControlConfigs = [IXJSONParser controlConfigsWithJSONControlArray:controlsValueArray];
                [controlConfig setChildControlConfigs:childControlConfigs];
            }
        }
        else
        {
            DDLogError(@"ERROR from %@ in %@ : Control class with type: %@ was not found \n Description of control: \n %@",THIS_FILE,THIS_METHOD,controlType, [controlValueDict description]);
        }
    }
    return controlConfig;
}

+(void)populateControlsCustomControlChildren:(IXBaseControl*)control
{
    for( IXBaseControl* childControl in [control childObjects] )
    {
        if( [childControl isKindOfClass:[IXCustom class]] )
        {
            IXCustom* customControl = (IXCustom*)childControl;
            NSString* pathToJSON = [[customControl propertyContainer] getPathPropertyValue:@"control_location" basePath:nil defaultValue:nil];
            [customControl setPathToJSON:pathToJSON];
            BOOL loadAsync = [[customControl propertyContainer] getBoolPropertyValue:@"load_async" defaultValue:YES];
            [IXJSONParser populateControl:customControl
                           withJSONAtPath:pathToJSON
                                loadAsync:loadAsync
                          completionBlock:^(BOOL didSucceed, NSError *error) {
                              if( didSucceed )
                              {
                                  if( loadAsync )
                                  {
                                      [[[customControl sandbox] containerControl] applySettings];
                                      [[[customControl sandbox] containerControl] layoutControl];
                                  }
                                  [[customControl actionContainer] executeActionsForEventNamed:@"did_load"];
                              }
                              else
                              {
                                  [[customControl actionContainer] executeActionsForEventNamed:@"load_failed"];
                              }
                          }];
        }
        
        [IXJSONParser populateControlsCustomControlChildren:childControl];
    }
}

+(void)populateControl:(IXBaseControl *)control withCustomControlCacheContainer:(IXCustomControlCacheContainer*)customControlCacheContainer completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock
{
    if( customControlCacheContainer != nil )
    {
        IXPropertyContainer* controlPropertyContainer = [control propertyContainer];
        if( [customControlCacheContainer propertyContainer] )
        {
            [control setPropertyContainer:[[customControlCacheContainer propertyContainer] copy]];
            [[control propertyContainer] addPropertiesFromPropertyContainer:controlPropertyContainer evaluateBeforeAdding:NO replaceOtherPropertiesWithTheSameName:YES];
        }
        if( [control actionContainer] )
        {
            [[control actionContainer] addActionsFromActionContainer:[[customControlCacheContainer actionContainer] copy]];
        }
        else
        {
            [control setActionContainer:[[customControlCacheContainer actionContainer] copy]];
        }
        
        NSMutableArray* dataProviders = [[NSMutableArray alloc] init];
        for( IXBaseDataProviderConfig* dataProviderConfig in [customControlCacheContainer dataProviderConfigs] )
        {
            IXBaseDataProvider* dataProvider = [dataProviderConfig createDataProvider];
            if( dataProvider )
            {
                [dataProviders addObject:dataProvider];
            }
        }
        
        if( [control isKindOfClass:[IXCustom class]] )
        {
            [((IXCustom*)control) setDataProviders:dataProviders];
        }
        else
        {
            [[control sandbox] addDataProviders:dataProviders];
        }
        
        for( IXBaseControlConfig* controlConfig in [customControlCacheContainer childConfigControls] )
        {
            IXBaseControl* childControl = [controlConfig createControl];
            if( childControl )
            {
                [control addChildObject:childControl];
            }
        }
        
        [IXJSONParser populateControlsCustomControlChildren:control];
        
        completionBlock(YES,nil);
    }
    else
    {
        completionBlock(NO,[NSError errorWithDomain:@"No control cache found." code:0 userInfo:nil] );
    }
}

+(void)populateControl:(IXBaseControl*)control withJSONAtPath:(NSString*)pathToJSON loadAsync:(BOOL)loadAsync completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock
{
    if( pathToJSON )
    {
        __block IXCustomControlCacheContainer* customControlCacheContainer = [sCustomControlCache objectForKey:pathToJSON];
        if( customControlCacheContainer == nil )
        {
            [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:pathToJSON
                                                         asynch:loadAsync
                                                    shouldCache:NO
                                                completionBlock:^(id jsonObject, NSError *error) {
                                                    
                                                    if( jsonObject != nil )
                                                    {
                                                        customControlCacheContainer = [[IXCustomControlCacheContainer alloc] init];
                                                        
                                                        NSDictionary* controlJSONDictionary = [jsonObject objectForKey:@"view"];
                                                        if( controlJSONDictionary == nil )
                                                        {
                                                            controlJSONDictionary = jsonObject;
                                                        }
                                                        
                                                        NSDictionary* customControlAttributeDict = [controlJSONDictionary objectForKey:@"attributes"];
                                                        [customControlCacheContainer setPropertyContainer:[IXJSONParser propertyContainerWithPropertyDictionary:customControlAttributeDict]];
                                                        
                                                        NSArray* customControlActionsArray = [controlJSONDictionary objectForKey:@"actions"];
                                                        [customControlCacheContainer setActionContainer:[IXJSONParser actionContainerWithJSONActionsArray:customControlActionsArray]];
                                                        
                                                        NSArray* customControlControlsArray = [controlJSONDictionary objectForKey:@"controls"];
                                                        [customControlCacheContainer setChildConfigControls:[IXJSONParser controlConfigsWithJSONControlArray:customControlControlsArray]];
                                                        
                                                        NSArray* customControlDataProvidersArray = [controlJSONDictionary objectForKey:@"data_providers"];
                                                        [customControlCacheContainer setDataProviderConfigs:[IXJSONParser dataProviderConfigsWithJSONDataProviderArray:customControlDataProvidersArray]];
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                            [sCustomControlCache setObject:customControlCacheContainer forKey:pathToJSON];
                                                        });
                                                        
                                                        if( customControlCacheContainer != nil )
                                                        {
                                                            [IXJSONParser populateControl:control withCustomControlCacheContainer:customControlCacheContainer completionBlock:completionBlock];
                                                        }
                                                    }
                                                    else
                                                    {
                                                        completionBlock(NO,error);
                                                        
                                                        DDLogError(@"ERROR from %@ in %@ : Grabbing custom control JSON at path %@ with error : %@",THIS_FILE,THIS_METHOD,pathToJSON,[error description]);
                                                    }
                                                }];
        }        
        else
        {
            [IXJSONParser populateControl:control withCustomControlCacheContainer:customControlCacheContainer completionBlock:completionBlock];
        }
    }
}

+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray
{
    NSMutableArray* controlArray = nil;
    if( [controlsValueArray isKindOfClass:[NSArray class]] )
    {
        controlArray = [NSMutableArray array];
        for( id controlValueDict in controlsValueArray )
        {
            if( [controlValueDict isKindOfClass:[NSDictionary class]] )
            {
                IXBaseControlConfig* controlConfig = [IXJSONParser controlConfigWithValueDictionary:controlValueDict];
                if( controlConfig != nil )
                {
                    [controlArray addObject:controlConfig];
                }
            }
        }
    }
    return controlArray;
}

+(IXBaseDataProviderConfig*)dataProviderConfigWithValueDictionary:(NSDictionary*)dataProviderValueDict
{
    IXBaseDataProviderConfig* dataProviderConfig = nil;
    if( [dataProviderValueDict allKeys] > 0 )
    {
        NSString* dataProviderType = [dataProviderValueDict objectForKey:kIX_TYPE];
        NSString* dataProviderClassString = [NSString stringWithFormat:@"IX%@DataProvider",dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        if( dataProviderType != nil )
        {
            dataProviderConfig = [[IXBaseDataProviderConfig alloc] init];
            [dataProviderConfig setDataProviderClass:dataProviderClass];
            
            id propertiesDict = [dataProviderValueDict objectForKey:@"attributes"];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = [dataProviderValueDict objectForKey:kIX_ID];
                if( controlID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:kIX_ID];
                }
                
                IXPropertyContainer* propertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:propertiesDict];
                [dataProviderConfig setPropertyContainer:propertyContainer];
                
                if( dataProviderClass == [IXCoreDataDataProvider class] )
                {
                    id entitiesDict = [dataProviderValueDict objectForKey:@"entity"];
                    IXEntityContainer* entityContainer = [IXJSONParser entityContainerWithJSONEntityDict:entitiesDict];
                    [dataProviderConfig setEntityContainer:entityContainer];
                }
                
                id parametersDict = [dataProviderValueDict objectForKey:@"parameters"];
                IXPropertyContainer* parametersPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:parametersDict];
                [dataProviderConfig setRequestParameters:parametersPropertyContainer];
                
                id headersDict = [dataProviderValueDict objectForKey:@"headers"];
                IXPropertyContainer* headersPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:headersDict];
                [dataProviderConfig setRequestHeaders:headersPropertyContainer];
                
                id attachmentsDict = [dataProviderValueDict objectForKey:@"attachments"];
                IXPropertyContainer* attachmentsPropertyContainer = [IXJSONParser propertyContainerWithPropertyDictionary:attachmentsDict];
                [dataProviderConfig setFileAttachments:attachmentsPropertyContainer];
                
                id actionsArray = [dataProviderValueDict objectForKey:@"actions"];
                IXActionContainer* actionContainer = [IXJSONParser actionContainerWithJSONActionsArray:actionsArray];
                [dataProviderConfig setActionContainer:actionContainer];
            }
        }
        else
        {
            DDLogError(@"ERROR from %@ in %@ : DataProvider class with type: %@ was not found \n Description of control: \n %@",THIS_FILE,THIS_METHOD,dataProviderType, [dataProviderValueDict description]);
        }
    }
    return dataProviderConfig;
}

+(NSArray*)dataProviderConfigsWithJSONDataProviderArray:(NSArray*)dataProvidersValueArray
{
    NSMutableArray* dataProviderConfigsArray = nil;
    if( [dataProvidersValueArray isKindOfClass:[NSArray class]] )
    {
        dataProviderConfigsArray = [NSMutableArray array];
        for( id dataProviderValueDict in dataProvidersValueArray )
        {
            if( [dataProviderValueDict isKindOfClass:[NSDictionary class]] )
            {
                IXBaseDataProviderConfig* dataProvider = [IXJSONParser dataProviderConfigWithValueDictionary:dataProviderValueDict];
                if( dataProvider != nil )
                {
                    [dataProviderConfigsArray addObject:dataProvider];
                }
            }
        }
    }
    return dataProviderConfigsArray;
}

+(void)viewControllerWithPathToJSON:(NSString*)pathToJSON loadAsync:(BOOL)loadAsync completionBlock:(IXJSONParseViewControllerCompletionBlock)completionBlock
{
    IXViewController* viewController = [IXViewController viewControllerWithPathToJSON:pathToJSON];
    [IXJSONParser populateControl:[viewController containerControl]
                   withJSONAtPath:pathToJSON
                        loadAsync:loadAsync
                  completionBlock:^(BOOL didSucceed,NSError* error) {
                      completionBlock(didSucceed,viewController,error);
                  }];
}

+(void)clearCache
{
    [sCustomControlCache removeAllObjects];
}

@end
