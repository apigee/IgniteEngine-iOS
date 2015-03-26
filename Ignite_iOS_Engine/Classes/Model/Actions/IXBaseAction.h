//
//  IXBaseAction.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXProperty;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXBaseAction : IXBaseConditionalObject

@property (nonatomic,weak) IXActionContainer* actionContainer;

@property (nonatomic,copy) NSString* eventName;
@property (nonatomic,strong) IXPropertyContainer* actionProperties;
@property (nonatomic,strong) IXPropertyContainer* parameterProperties;
@property (nonatomic,strong) IXActionContainer* subActionContainer;

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXPropertyContainer*)actionProperties
             parameterProperties:(IXPropertyContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer;

+(instancetype)actionWithEventName:(NSString*)eventName
                    jsonDictionary:(NSDictionary*)actionJSONDict;

+(instancetype)actionWithRemoteNotificationInfo:(NSDictionary *)remoteNotificationInfo;

+(instancetype)actionWithCustomURLQueryParams:(NSDictionary *)queryParams;

+(NSArray*)actionsWithEventNames:(NSArray*)eventNames
                  jsonDictionary:(NSDictionary*)actionJSONDict;

-(void)execute;
-(void)actionDidFinishWithEvents:(NSArray*)actionsToFire;

@end
