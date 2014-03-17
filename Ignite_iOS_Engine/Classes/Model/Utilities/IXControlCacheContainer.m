//
//  IXControlCacheContainer.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/17/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXControlCacheContainer.h"

#import "IXJSONGrabber.h"
#import "IXPropertyContainer.h"
#import "IXActionContainer.h"
#import "IXViewController.h"
#import "IXBaseControl.h"
#import "IXCustom.h"
#import "IXLogger.h"
#import "IXBaseDataProviderConfig.h"
#import "IXBaseControlConfig.h"

static NSCache* sCustomControlCache;

@implementation IXControlCacheContainer

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sCustomControlCache = [[NSCache alloc] init];
        [sCustomControlCache setName:@"com.ignite.CustomControlCache"];
    });
}

+(void)clearCache
{
    [sCustomControlCache removeAllObjects];
}

-(instancetype)initWithStyleClass:(NSString*)styleClass
                propertyContainer:(IXPropertyContainer*)propertyContainer
                  actionContainer:(IXActionContainer*)actionContainer
              childConfigControls:(NSArray*)childConfigControls
              dataProviderConfigs:(NSArray*)dataProviderConfigs;
{
    self = [super init];
    if( self )
    {
        _styleClass = [styleClass copy];
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _childConfigControls = childConfigControls;
        _dataProviderConfigs = dataProviderConfigs;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithStyleClass:[self styleClass]
                                               propertyContainer:[[self propertyContainer] copy]
                                                 actionContainer:[[self actionContainer] copy]
                                             childConfigControls:[[NSArray alloc] initWithArray:[self childConfigControls] copyItems:YES]
                                             dataProviderConfigs:[[NSArray alloc] initWithArray:[self dataProviderConfigs] copyItems:YES]];
}

+(void)populateControlsCustomControlChildren:(IXBaseControl*)control
{
    for( IXBaseControl* childControl in [control childObjects] )
    {
        if( [childControl isKindOfClass:[IXCustom class]] )
        {
            IXCustom* customControl = (IXCustom*)childControl;
            NSString* pathToJSON = [[customControl propertyContainer] getPathPropertyValue:@"control_location" basePath:nil defaultValue:nil];
            if( pathToJSON == nil )
            {
                DDLogWarn(@"WARNING from %@ in %@ : Path to custom control is nil!!! \n Custom Control Description : %@",THIS_FILE,THIS_METHOD,[customControl description]);
                [[customControl actionContainer] executeActionsForEventNamed:@"load_failed"];
            }
            else
            {
                [customControl setPathToJSON:pathToJSON];
                BOOL loadAsync = [[customControl propertyContainer] getBoolPropertyValue:@"load_async" defaultValue:YES];
                [IXControlCacheContainer populateControl:customControl
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
        }
        
        [IXControlCacheContainer populateControlsCustomControlChildren:childControl];
    }
}

+(void)populateControl:(IXBaseControl *)control withCustomControlCacheContainer:(IXControlCacheContainer*)customControlCacheContainer completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock
{
    if( customControlCacheContainer != nil )
    {
        if( [control styleClass] == nil )
        {
            [control setStyleClass:[customControlCacheContainer styleClass]];
        }
        
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
        
        [IXControlCacheContainer populateControlsCustomControlChildren:control];
        
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
        __block IXControlCacheContainer* customControlCacheContainer = [sCustomControlCache objectForKey:pathToJSON];
        if( customControlCacheContainer == nil )
        {
            [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:pathToJSON
                                                         asynch:loadAsync
                                                    shouldCache:NO
                                                completionBlock:^(id jsonObject, NSError *error) {
                                                    
                if( [jsonObject isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary* controlJSONDictionary = jsonObject[@"view"];
                    if( controlJSONDictionary == nil )
                    {
                        controlJSONDictionary = jsonObject;
                    }
                    
                    NSDictionary* propertiesDictionary = controlJSONDictionary[@"attributes"];
                    IXPropertyContainer* propertyContainer = [IXPropertyContainer propertyContainerWithJSONDict:propertiesDictionary];
                    
                    NSString* controlStyleClass = propertiesDictionary[kIX_STYLE];
                    if( controlStyleClass && ![controlStyleClass isKindOfClass:[NSString class]] )
                    {
                        controlStyleClass = nil;
                    }
                    
                    IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:controlJSONDictionary[@"actions"]];
                    NSArray* childConfigControls = [IXBaseControlConfig controlConfigsWithJSONControlArray:controlJSONDictionary[@"controls"]];
                    NSArray* dataProviderConfigs = [IXBaseDataProviderConfig dataProviderConfigsWithJSONArray:controlJSONDictionary[@"data_providers"]];
                    
                    customControlCacheContainer = [[IXControlCacheContainer alloc] initWithStyleClass:controlStyleClass
                                                                                          propertyContainer:propertyContainer
                                                                                            actionContainer:actionContainer
                                                                                        childConfigControls:childConfigControls
                                                                                        dataProviderConfigs:dataProviderConfigs];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [sCustomControlCache setObject:customControlCacheContainer forKey:pathToJSON];
                    });
                    
                    if( customControlCacheContainer != nil )
                    {
                        [IXControlCacheContainer populateControl:control withCustomControlCacheContainer:customControlCacheContainer completionBlock:completionBlock];
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
            [IXControlCacheContainer populateControl:control withCustomControlCacheContainer:customControlCacheContainer completionBlock:completionBlock];
        }
    }
}

@end
