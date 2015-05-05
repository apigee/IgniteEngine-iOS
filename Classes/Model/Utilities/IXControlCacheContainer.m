//
//  IXControlCacheContainer.m
//  Ignite Engine
//
//  Created by Robert Walsh on 3/17/14.
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

#import "IXControlCacheContainer.h"

#import "IXDataLoader.h"
#import "IXAttributeContainer.h"
#import "IXActionContainer.h"
#import "IXBaseControl.h"
#import "IXCustom.h"
#import "IXLogger.h"
#import "IXBaseDataProviderConfig.h"
#import "IXBaseControlConfig.h"

static NSCache* sControlCacheContainerCache;
IX_STATIC_CONST_STRING kIXControlCacheContainerCacheName = @"com.ignite.ControlCacheContainerCache";
IX_STATIC_CONST_STRING kIXControlLocation = @"controlLocation";
IX_STATIC_CONST_STRING kIXLoadAsync = @"loadAsync";

@implementation IXControlCacheContainer

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sControlCacheContainerCache = [[NSCache alloc] init];
        [sControlCacheContainerCache setName:kIXControlCacheContainerCacheName];
    });
}

+(void)clearCache
{
    [sControlCacheContainerCache removeAllObjects];
}

-(instancetype)initWithControlType:(NSString*)controlType
                        styleClass:(NSString*)styleClass
                 propertyContainer:(IXAttributeContainer*)propertyContainer
                   actionContainer:(IXActionContainer*)actionContainer
               childConfigControls:(NSArray*)childConfigControls
               dataProviderConfigs:(NSArray*)dataProviderConfigs;
{
    self = [super init];
    if( self )
    {
        _controlType = [controlType copy];
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
    return [[[self class] allocWithZone:zone] initWithControlType:[self controlType]
                                                       styleClass:[self styleClass]
                                                propertyContainer:[[self propertyContainer] copy]
                                                  actionContainer:[[self actionContainer] copy]
                                              childConfigControls:[[NSArray alloc] initWithArray:[self childConfigControls] copyItems:YES]
                                              dataProviderConfigs:[[NSArray alloc] initWithArray:[self dataProviderConfigs] copyItems:YES]];
}

-(Class)controlClass
{
    Class controlClass = nil;
    NSString* controlType = [self controlType];
    if( [controlType length] ) {
        controlClass = NSClassFromString([NSString stringWithFormat:kIX_CONTROL_CLASS_NAME_FORMAT,controlType]);
    } else {
        controlClass = [IXLayout class];
    }
    return controlClass;
}

+(void)populateControlsCustomControlChildren:(IXBaseControl*)control
{
    for( IXBaseControl* childControl in [control childObjects] )
    {
        if( [childControl isKindOfClass:[IXCustom class]] )
        {
            IXCustom* customControl = (IXCustom*)childControl;
            NSString* pathToJSON = [[customControl attributeContainer] getPathValueForAttribute:kIXControlLocation basePath:nil defaultValue:nil];
            if( pathToJSON == nil )
            {
                IX_LOG_WARN(@"WARNING from %@ in %@: Path to custom control is nil.\nCustom Control Description: %@",THIS_FILE,THIS_METHOD,[customControl description]);
                [[customControl actionContainer] executeActionsForEventNamed:kIX_FAILED];
            }
            else
            {
                [customControl setPathToJSON:pathToJSON];
                BOOL loadAsync = [[customControl attributeContainer] getBoolValueForAttribute:kIXLoadAsync defaultValue:YES] && ![sControlCacheContainerCache objectForKey:pathToJSON];
                [IXControlCacheContainer populateControl:customControl
                                          withJSONAtPath:pathToJSON
                                               loadAsync:loadAsync
                                         completionBlock:^(BOOL didSucceed, IXBaseControl* populatedControl, NSError *error) {
                                              if( didSucceed )
                                              {
                                                  if( loadAsync )
                                                  {
                                                      if( [populatedControl isKindOfClass:[IXCustom class]] )
                                                      {
                                                          [((IXCustom*)populatedControl) setFirstLoad:YES];
                                                      }
                                                      [populatedControl applySettings];
                                                      [populatedControl layoutControl];
                                                  }
                                                  [[populatedControl actionContainer] executeActionsForEventNamed:kIX_SUCCESS];
                                              }
                                              else
                                              {
                                                  [[populatedControl actionContainer] executeActionsForEventNamed:kIX_FAILED];
                                              }
                                         }];
            }
        }
        
        [IXControlCacheContainer populateControlsCustomControlChildren:childControl];
    }
}

+(void)populateControl:(IXBaseControl *)control controlCacheContainer:(IXControlCacheContainer*)controlCacheContainer completionBlock:(IXPopulateControlCompletionBlock)completionBlock
{
    if( control && controlCacheContainer != nil )
    {
        if( [control styleClass] == nil )
        {
            [control setStyleClass:[controlCacheContainer styleClass]];
        }
        
        IXAttributeContainer* controlPropertyContainer = [control attributeContainer];
        if( [controlCacheContainer propertyContainer] )
        {
            [control setAttributeContainer:[[controlCacheContainer propertyContainer] copy]];
            [[control attributeContainer] addAttributesFromContainer:controlPropertyContainer evaluateBeforeAdding:NO replaceOtherAttributesWithSameName:YES];
        }
        if( [control actionContainer] )
        {
            [[control actionContainer] addActionsFromActionContainer:[[controlCacheContainer actionContainer] copy]];
        }
        else
        {
            [control setActionContainer:[[controlCacheContainer actionContainer] copy]];
        }
        
        NSMutableArray* dataProviders = [[NSMutableArray alloc] init];
        for( IXBaseDataProviderConfig* dataProviderConfig in [controlCacheContainer dataProviderConfigs] )
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
        
        for( IXBaseControlConfig* controlConfig in [controlCacheContainer childConfigControls] )
        {
            IXBaseControl* childControl = [controlConfig createControl];
            if( childControl )
            {
                [control addChildObject:childControl];
            }
        }
        
        [IXControlCacheContainer populateControlsCustomControlChildren:control];
        
        completionBlock(YES,control,nil);
    }
    else
    {
        completionBlock(NO,control,[NSError errorWithDomain:@"No control cache found." code:0 userInfo:nil] );
    }
}

+(void)createControlWithControlCacheContainer:(IXControlCacheContainer*)controlCacheContainer
                              completionBlock:(IXCreateControlCompletionBlock)completionBlock
{
    if( controlCacheContainer != nil )
    {
        Class controlClass = [controlCacheContainer controlClass];
        if( [controlClass isSubclassOfClass:[IXBaseControl class]] )
        {
            [IXControlCacheContainer populateControl:[[controlClass alloc] init]
                               controlCacheContainer:controlCacheContainer
                                     completionBlock:^(BOOL didSucceed, IXBaseControl *populatedControl, NSError *error) {
                                         
                                         if( didSucceed && populatedControl )
                                         {
                                             completionBlock(YES,populatedControl,nil);
                                         }
                                         else
                                         {
                                             completionBlock(NO,nil,error);
                                         }
                                     }];
        }
        else
        {
            completionBlock(NO,nil,[NSError errorWithDomain:@"ControlCacheContainer control type is invalid." code:0 userInfo:nil]);
        }
    }
    else
    {
        completionBlock(NO,nil,[NSError errorWithDomain:@"ControlCacheContainer is nil. Cannot create control." code:0 userInfo:nil]);
    }
}

+(void)createControlWithPathToJSON:(NSString*)pathToJSON
                         loadAsync:(BOOL)loadAsync
                   completionBlock:(IXCreateControlCompletionBlock)completionBlock
{
    [IXControlCacheContainer controlCacheContainerWithJSONAtPath:pathToJSON
                                                       loadAsync:loadAsync
                                                 completionBlock:^(BOOL didSucceed, IXControlCacheContainer *controlCacheContainer, NSError *error) {
                                                     
                                                     if( didSucceed ) {
                                                         [IXControlCacheContainer createControlWithControlCacheContainer:controlCacheContainer
                                                                                                         completionBlock:completionBlock];
                                                     } else {
                                                         completionBlock(NO,nil,error);
                                                     }
                                                 }];
}

+(void)controlCacheContainerWithJSONAtPath:(NSString*)pathToJSON
                                 loadAsync:(BOOL)loadAsync
                           completionBlock:(IXGetControlCacheContainerCompletionBlock)completionBlock
{
    IXControlCacheContainer* cachedControlCacheContainer = [sControlCacheContainerCache objectForKey:pathToJSON];
    if( cachedControlCacheContainer == nil )
    {
        [[IXDataLoader sharedDataLoader] loadJSONFromPath:pathToJSON async:loadAsync shouldCache:NO completion:^(id jsonObject, NSString* stringValue, NSError *error) {
            
            if( [jsonObject isKindOfClass:[NSDictionary class]] )
            {
                NSDictionary* controlJSONDictionary = jsonObject[kIXViewControlRef];
                NSDictionary* controlCustomJSONDictionary = jsonObject[kIXCustomContainerControlRef];
                
                if( controlJSONDictionary == nil && controlCustomJSONDictionary == nil)
                {
                    controlJSONDictionary = jsonObject;
                }
                else if (controlJSONDictionary == nil && controlCustomJSONDictionary != nil)
                {
                    controlJSONDictionary = controlCustomJSONDictionary;
                }
                
                NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithDictionary:controlJSONDictionary[kIX_ATTRIBUTES]];
                
                NSString* controlType = controlJSONDictionary[kIX_TYPE];
                if( !controlType ) {
                    controlType = propertiesDictionary[kIX_TYPE];
                }
                NSString* controlStyleClass = controlJSONDictionary[kIX_STYLE];
                if( !controlStyleClass ) {
                    controlStyleClass = propertiesDictionary[kIX_STYLE];
                }
                id controlID = controlJSONDictionary[kIX_ID];
                if( controlID && [propertiesDictionary objectForKey:kIX_ID] == nil ) {
                    [propertiesDictionary setObject:controlID forKey:kIX_ID];
                }
                
                IXAttributeContainer* propertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:propertiesDictionary];
                
                IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:controlJSONDictionary[kIX_ACTIONS]];
                NSArray* childConfigControls = [IXBaseControlConfig controlConfigsWithJSONControlArray:controlJSONDictionary[kIX_CONTROLS]];
                NSArray* dataProviderConfigs = [IXBaseDataProviderConfig dataProviderConfigsWithJSONArray:controlJSONDictionary[kIX_DATASOURCES]];
                
                IXControlCacheContainer* controlCacheContainer = [[IXControlCacheContainer alloc] initWithControlType:controlType
                                                                                                           styleClass:controlStyleClass
                                                                                                    propertyContainer:propertyContainer
                                                                                                      actionContainer:actionContainer
                                                                                                  childConfigControls:childConfigControls
                                                                                                  dataProviderConfigs:dataProviderConfigs];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [sControlCacheContainerCache setObject:controlCacheContainer forKey:pathToJSON];
                });
                
                completionBlock(YES,controlCacheContainer,nil);
            }
            else
            {
                completionBlock(NO,nil,error);
                
                IX_LOG_ERROR(@"ERROR from %@ in %@: Loading custom control JSON at path %@ with error: %@",THIS_FILE,THIS_METHOD,pathToJSON,[error description]);
            }
        }];
    }
    else
    {
        completionBlock(YES,cachedControlCacheContainer,nil);
    }
}

+(void)populateControl:(IXBaseControl*)control withJSONAtPath:(NSString*)pathToJSON loadAsync:(BOOL)loadAsync completionBlock:(IXPopulateControlCompletionBlock)completionBlock
{
    [IXControlCacheContainer controlCacheContainerWithJSONAtPath:pathToJSON loadAsync:loadAsync completionBlock:^(BOOL didSucceed, IXControlCacheContainer *controlCacheContainer, NSError *error) {
                                                        
        if( didSucceed && controlCacheContainer != nil )
        {
            [IXControlCacheContainer populateControl:control
                               controlCacheContainer:controlCacheContainer
                                     completionBlock:completionBlock];
        }
        else
        {
            completionBlock(NO,control,error);
        }
    }];
}

@end
