//
//  ixeActionContainer.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeSandbox;
@class ixeBaseObject;
@class ixeBaseAction;

@interface ixeActionContainer : NSObject

@property (nonatomic,weak) ixeSandbox* sandbox;
@property (nonatomic,weak) ixeBaseObject* actionContainerOwner;

-(void)addAction:(ixeBaseAction*)action;
-(void)addActions:(NSArray*)actions;

-(BOOL)hasActionsForEvent:(NSString*)eventName;
-(NSMutableArray*)actionsForEvent:(NSString*)eventName;

-(void)executeActionsForEventNamed:(NSString*)eventName;

@end
