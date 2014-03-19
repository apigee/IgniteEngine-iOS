//
//  IXBaseControlConfig.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseControlConfig.h"

#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"
#import "IXLogger.h"

@implementation IXBaseControlConfig

-(instancetype)init
{
    return [self initWithControlClass:nil
                           styleClass:nil
                    propertyContainer:nil
                      actionContainer:nil
               andChildControlConfigs:nil];
}

-(instancetype)initWithControlClass:(Class)controlClass
                         styleClass:(NSString*)styleClass
                  propertyContainer:(IXPropertyContainer*)propertyContainer
                    actionContainer:(IXActionContainer*)actionContainer
             andChildControlConfigs:(NSArray*)childControlConfigs
{
    self = [super init];
    if( self )
    {
        _controlClass = controlClass;
        _styleClass = [styleClass copy];
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _childControlConfigs = childControlConfigs;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithControlClass:[self controlClass]
                                                        styleClass:[self styleClass]
                                                 propertyContainer:[[self propertyContainer] copy]
                                                   actionContainer:[[self actionContainer] copy]
                                            andChildControlConfigs:[[NSArray alloc] initWithArray:[self childControlConfigs] copyItems:YES]];
}

+(instancetype)controlConfigWithJSONDictionary:(NSDictionary*)controlJSONDict
{
    IXBaseControlConfig* controlConfig = nil;
    if( [controlJSONDict isKindOfClass:[NSDictionary class]] && [controlJSONDict allKeys] > 0 )
    {
        NSString* controlType = controlJSONDict[kIX_TYPE];
        Class controlClass = NSClassFromString([NSString stringWithFormat:kIX_CONTROL_CLASS_NAME_FORMAT,controlType]);
        if( [controlClass isSubclassOfClass:[IXBaseControl class]] )
        {
            IXPropertyContainer* propertyContainer = nil;
            id propertiesDict = controlJSONDict[kIX_ATTRIBUTES];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = controlJSONDict[kIX_ID];
                if( controlID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:kIX_ID];
                }
                propertyContainer = [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict];
            }
            
            NSString* controlStyleClass = controlJSONDict[kIX_STYLE];
            if( controlStyleClass && ![controlStyleClass isKindOfClass:[NSString class]] )
            {
                controlStyleClass = nil;
            }
            
            IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:controlJSONDict[kIX_ACTIONS]];
            NSArray* childControlConfigs = [IXBaseControlConfig controlConfigsWithJSONControlArray:controlJSONDict[kIX_CONTROLS]];
            
            controlConfig = [[IXBaseControlConfig alloc] initWithControlClass:controlClass
                                                                   styleClass:controlStyleClass
                                                            propertyContainer:propertyContainer
                                                              actionContainer:actionContainer
                                                       andChildControlConfigs:childControlConfigs];
        }
        else
        {
            DDLogError(@"ERROR from %@ in %@ : Control class with type: %@ was not found \n Description of control: \n %@",THIS_FILE,THIS_METHOD,controlType, [controlJSONDict description]);
        }
    }
    return controlConfig;
}

+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray
{
    NSMutableArray* controlArray = nil;
    if( [controlsValueArray isKindOfClass:[NSArray class]] && [controlsValueArray count] )
    {
        controlArray = [NSMutableArray array];
        for( id controlValueDict in controlsValueArray )
        {
            IXBaseControlConfig* controlConfig = [IXBaseControlConfig controlConfigWithJSONDictionary:controlValueDict];
            if( controlConfig != nil )
            {
                [controlArray addObject:controlConfig];
            }
        }
    }
    return controlArray;
}

-(IXBaseControl*)createControl
{
    IXBaseControl* control = [[[self controlClass] alloc] init];
    if( control )
    {
        [control setStyleClass:[[self styleClass] copy]];
        [control setPropertyContainer:[[self propertyContainer] copy]];
        [control setActionContainer:[[self actionContainer] copy]];
        if( [self childControlConfigs] )
        {
            for( IXBaseControlConfig* childControlConfig in [self childControlConfigs] )
            {
                IXBaseControl* childControl = [childControlConfig createControl];
                if( childControl )
                {
                    [control addChildObject:childControl];
                }
            }
        }
    }
    return control;
}

@end
