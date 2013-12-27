//
//  IXBaseObject.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXSandbox.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

@class IXBaseAction;

@interface IXBaseObject : NSObject <NSCopying>

@property (nonatomic,weak) IXBaseObject* parentObject;
@property (nonatomic,weak) IXSandbox* sandbox;

@property (nonatomic,strong) NSString* ID;
@property (nonatomic,strong) NSMutableArray* childObjects;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;

-(void)addChildObject:(IXBaseObject*)childObject;
-(void)addChildObjects:(NSArray*)childObjects;
-(NSArray*)childrenWithID:(NSString*)childObjectID;

-(void)applySettings;
-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer;
-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName;

@end
