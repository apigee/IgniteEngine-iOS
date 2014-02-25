//
//  IXBaseAction.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXProperty;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXBaseAction : IXBaseConditionalObject <NSCopying>

@property (nonatomic,weak) IXActionContainer* actionContainer;

@property (nonatomic,copy) NSString* eventName;
@property (nonatomic,strong) IXPropertyContainer* actionProperties;
@property (nonatomic,strong) IXPropertyContainer* parameterProperties;
@property (nonatomic,strong) IXActionContainer* subActionContainer;

-(instancetype)initWithEventName:(NSString*)eventName
                actionProperties:(IXPropertyContainer*)actionProperties
             parameterProperties:(IXPropertyContainer*)parameterProperties
              subActionContainer:(IXActionContainer*)subActionContainer;

-(void)execute;
-(void)actionDidFinishWithEvents:(NSArray*)actionsToFire;

@end
