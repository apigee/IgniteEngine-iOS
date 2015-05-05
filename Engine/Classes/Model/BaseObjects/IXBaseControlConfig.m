//
//  IXBaseControlConfig.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseControlConfig.h"

#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXAttributeContainer.h"
#import "IXLogger.h"

static NSString* const kIXControlsSuffix = @"controls";

@implementation IXBaseControlConfig

-(instancetype)init
{
    return [self initWithControlClass:nil
                           styleClass:nil
                    propertyContainer:nil
                      actionContainer:nil
              controlConfigDictionary:nil];
}

-(instancetype)initWithControlClass:(Class)controlClass
                         styleClass:(NSString*)styleClass
                  propertyContainer:(IXAttributeContainer*)propertyContainer
                    actionContainer:(IXActionContainer*)actionContainer
            controlConfigDictionary:(NSDictionary*)controlConfigDictionary

{
    self = [super init];
    if( self )
    {
        _controlClass = controlClass;
        _styleClass = [styleClass copy];
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _controlConfigDictionary = controlConfigDictionary;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithControlClass:[self controlClass]
                                                        styleClass:[self styleClass]
                                                 propertyContainer:[[self propertyContainer] copy]
                                                   actionContainer:[[self actionContainer] copy]
                                           controlConfigDictionary:[[NSDictionary alloc] initWithDictionary:[self controlConfigDictionary] copyItems:YES]];
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
            IXAttributeContainer* propertyContainer = nil;
            id propertiesDict = controlJSONDict[kIX_ATTRIBUTES];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id controlID = controlJSONDict[kIX_ID];
                if( controlID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:controlID forKey:kIX_ID];
                }
                propertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict];
            }
            
            NSString* controlStyleClass = controlJSONDict[kIX_STYLE];
            if( controlStyleClass && ![controlStyleClass isKindOfClass:[NSString class]] )
            {
                controlStyleClass = nil;
            }
            
            IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:controlJSONDict[kIX_ACTIONS]];
            
            NSMutableDictionary __block *controlConfigDictionary = nil;
            [controlJSONDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
                if( [key hasSuffix:kIXControlsSuffix] && [obj isKindOfClass:[NSArray class]] )
                {
                    NSArray* subControlArray = (NSArray*)obj;
                    if( [subControlArray count] > 0 )
                    {
                        NSArray* subControlConfigs = [IXBaseControlConfig controlConfigsWithJSONControlArray:subControlArray];
                        if( [subControlConfigs count] > 0 )
                        {
                            if( controlConfigDictionary == nil )
                            {
                                controlConfigDictionary = [NSMutableDictionary dictionary];
                            }
                            [controlConfigDictionary setObject:subControlConfigs forKey:key];
                        }
                    }
                }
            }];
            
            controlConfig = [[IXBaseControlConfig alloc] initWithControlClass:controlClass
                                                                   styleClass:controlStyleClass
                                                            propertyContainer:propertyContainer
                                                              actionContainer:actionContainer
                                                      controlConfigDictionary:controlConfigDictionary];
        }
        else
        {
            IX_LOG_ERROR(@"ERROR from %@ in %@ : Control class with type: %@ was not found \n Description of control: \n %@",THIS_FILE,THIS_METHOD,controlType, [controlJSONDict description]);
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
        [control setActionContainer:[[self actionContainer] copy]];
        [control setAttributeContainer:[[self propertyContainer] copy]];
        
        if( [control attributeContainer] == nil )
        {
            // We need to have a property container for the default values and modifies to work!
            [control setAttributeContainer:[[IXAttributeContainer alloc] init]];
        }
        
        if( [[[self controlConfigDictionary] allValues] count] > 0 )
        {
            NSMutableDictionary __block *subControlsDictionary = nil;
            
            [[self controlConfigDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* obj, BOOL *stop) {
                
                BOOL isChildControls = [key isEqualToString:kIXControlsSuffix];
                
                NSMutableArray *subControlArray = nil;
                for( IXBaseControlConfig* subControlConfig in obj)
                {
                    IXBaseControl* baseControl = [subControlConfig createControl];
                    if( baseControl )
                    {
                        if( isChildControls )
                        {
                            [control addChildObject:baseControl];
                        }
                        else
                        {
                            if( subControlArray == nil ) {
                                subControlArray = [NSMutableArray array];
                            }
                            [subControlArray addObject:baseControl];
                        }
                    }
                }
                
                if( [subControlArray count] > 0 )
                {
                    if( subControlsDictionary == nil ) {
                        subControlsDictionary = [NSMutableDictionary dictionary];
                    }
                    [subControlsDictionary setObject:subControlArray forKey:key];
                }
            }];
            
            if( [[subControlsDictionary allValues] count] > 0 )
            {
                [control setSubControlsDictionary:subControlsDictionary];
            }
        }
    }
    return control;
}

@end
