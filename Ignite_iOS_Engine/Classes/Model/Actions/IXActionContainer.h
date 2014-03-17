//
//  IXActionContainer.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXSandbox;
@class IXBaseObject;
@class IXBaseAction;

@interface IXActionContainer : NSObject <NSCopying>

@property (nonatomic,weak) IXBaseObject* ownerObject;

+(instancetype)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;

-(void)addAction:(IXBaseAction*)action;
-(void)addActions:(NSArray*)actions;
-(void)addActionsFromActionContainer:(IXActionContainer*)actionContainer;

-(BOOL)hasActionsForEvent:(NSString*)eventName;
-(BOOL)hasActionsWithEventNamePrefix:(NSString*)eventNamePrefix;
-(NSMutableArray*)actionsForEvent:(NSString*)eventName;

-(void)executeActionsForEventNamed:(NSString*)eventName;
-(void)executeActionsForEventNamed:(NSString*)eventName propertyWithName:(NSString*)propertyName mustHaveValue:(NSString*)value;

@end
