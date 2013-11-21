//
//  IxBaseObject.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IxSandbox.h"
#import "IxActionContainer.h"
#import "IxPropertyContainer.h"

@class IxBaseAction;

@interface IxBaseObject : NSObject

@property (nonatomic,weak) IxBaseObject* parentObject;
@property (nonatomic,weak) IxSandbox* sandbox;

@property (nonatomic,strong) NSString* ID;
@property (nonatomic,strong) NSMutableArray* childObjects;
@property (nonatomic,strong) IxActionContainer* actionContainer;
@property (nonatomic,strong) IxPropertyContainer* propertyContainer;

-(void)addChildObject:(IxBaseObject*)childObject;
-(void)addChildObjects:(NSArray*)childObjects;
-(NSArray*)childrenWithID:(NSString*)childObjectID;

-(void)applySettings;
-(void)applyFunction:(NSString*)functionName withParameters:(IxPropertyContainer*)parameterContainer;

@end
