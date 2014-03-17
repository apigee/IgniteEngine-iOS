//
//  IXControlCacheContainer.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 3/17/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXViewController;
@class IXBaseControl;
@class IXPropertyContainer;
@class IXActionContainer;

typedef void(^IXJSONPopulateControlCompletionBlock)(BOOL didSucceed, NSError* error);

@interface IXControlCacheContainer : NSObject <NSCopying>

@property (nonatomic,copy) NSString* styleClass;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) NSArray* childConfigControls;
@property (nonatomic,strong) NSArray* dataProviderConfigs;

-(instancetype)initWithStyleClass:(NSString*)styleClass
                propertyContainer:(IXPropertyContainer*)propertyContainer
                  actionContainer:(IXActionContainer*)actionContainer
              childConfigControls:(NSArray*)childConfigControls
              dataProviderConfigs:(NSArray*)dataProviderConfigs;

+(void)clearCache;

+(void)populateControl:(IXBaseControl*)control
        withJSONAtPath:(NSString*)pathToJSON
             loadAsync:(BOOL)loadAsync
       completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl *)control withCustomControlCacheContainer:(IXControlCacheContainer*)customControlCacheContainer completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock;


@end
