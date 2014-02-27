//
//  IXJSONParser.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/10/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXCustom;
@class IXProperty;
@class IXBaseAction;
@class IXBaseControl;
@class IXBaseControlConfig;
@class IXBaseDataProviderConfig;
@class IXCustomControlCacheContainer;
@class IXViewController;
@class IXActionContainer;
@class IXPropertyContainer;

typedef void(^IXJSONParseViewControllerCompletionBlock)(BOOL didSucceed, IXViewController* viewController, NSError* error);
typedef void(^IXJSONPopulateControlCompletionBlock)(BOOL didSucceed, NSError* error);

@interface IXJSONParser : NSObject

+(void)clearCache;

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;
+(IXProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue;

+(IXPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray;
+(IXProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict;

+(IXActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;
+(NSArray*)actionsWithEventNames:(NSArray*)eventNames actionValueDictionary:(NSDictionary*)actionValueDict;
+(IXBaseAction*)actionWithEventName:(NSString*)eventName valueDictionary:(NSDictionary*)actionValueDict;

+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray;
+(IXBaseControlConfig*)controlConfigWithValueDictionary:(NSDictionary*)controlValueDict;

+(IXBaseDataProviderConfig*)dataProviderConfigWithValueDictionary:(NSDictionary*)dataProviderValueDict;
+(NSArray*)dataProviderConfigsWithJSONDataProviderArray:(NSArray*)dataProvidersValueArray;

+(void)populateControl:(IXBaseControl*)control
        withJSONAtPath:(NSString*)pathToJSON
             loadAsync:(BOOL)loadAsync
       completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock;

+(void)populateControl:(IXBaseControl *)control withCustomControlCacheContainer:(IXCustomControlCacheContainer*)customControlCacheContainer completionBlock:(IXJSONPopulateControlCompletionBlock)completionBlock;

+(void)viewControllerWithPathToJSON:(NSString*)pathToJSON
                          loadAsync:(BOOL)loadAsync
                    completionBlock:(IXJSONParseViewControllerCompletionBlock)completionBlock;

@end
