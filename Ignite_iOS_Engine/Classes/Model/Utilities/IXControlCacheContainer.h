//
//  IXControlCacheContainer.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/17/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXPropertyContainer;
@class IXActionContainer;
@class IXControlCacheContainer;

typedef void(^IXGetControlCacheContainerCompletionBlock)(BOOL didSucceed, IXControlCacheContainer* controlCacheContainer, NSError* error);
typedef void(^IXCreateControlCompletionBlock)(BOOL didSucceed, IXBaseControl* createdControl, NSError* error);
typedef void(^IXPopulateControlCompletionBlock)(BOOL didSucceed, IXBaseControl* populatedControl, NSError* error);

@interface IXControlCacheContainer : NSObject <NSCopying>

@property (nonatomic,readonly) Class controlClass;
@property (nonatomic,copy) NSString* controlType;
@property (nonatomic,copy) NSString* styleClass;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) NSArray* childConfigControls;
@property (nonatomic,strong) NSArray* dataProviderConfigs;

-(instancetype)initWithControlType:(NSString*)controlType
                        styleClass:(NSString*)styleClass
                 propertyContainer:(IXPropertyContainer*)propertyContainer
                   actionContainer:(IXActionContainer*)actionContainer
               childConfigControls:(NSArray*)childConfigControls
               dataProviderConfigs:(NSArray*)dataProviderConfigs;

+(void)controlCacheContainerWithJSONAtPath:(NSString*)pathToJSON
                                 loadAsync:(BOOL)loadAsync
                           completionBlock:(IXGetControlCacheContainerCompletionBlock)completionBlock;

+(void)createControlWithPathToJSON:(NSString*)pathToJSON
                         loadAsync:(BOOL)loadAsync
                   completionBlock:(IXCreateControlCompletionBlock)completionBlock;

+(void)createControlWithControlCacheContainer:(IXControlCacheContainer*)controlCacheContainer
                              completionBlock:(IXCreateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl*)control
        withJSONAtPath:(NSString*)pathToJSON
             loadAsync:(BOOL)loadAsync
       completionBlock:(IXPopulateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl*)control
 controlCacheContainer:(IXControlCacheContainer*)controlCacheContainer
       completionBlock:(IXPopulateControlCompletionBlock)completionBlock;

+(void)clearCache;

@end
