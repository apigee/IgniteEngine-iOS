//
//  IxActionContainer.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxSandbox;
@class IxBaseObject;
@class IxBaseAction;

@interface IxActionContainer : NSObject

@property (nonatomic,weak) IxSandbox* sandbox;
@property (nonatomic,weak) IxBaseObject* actionContainerOwner;

-(void)addAction:(IxBaseAction*)action;
-(void)addActions:(NSArray*)actions;

-(BOOL)hasActionsForEvent:(NSString*)eventName;
-(NSMutableArray*)actionsForEvent:(NSString*)eventName;

-(void)executeActionsForEventNamed:(NSString*)eventName;

@end
