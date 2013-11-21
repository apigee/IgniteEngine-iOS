//
//  ixeBaseObject.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ixeSandbox.h"
#import "ixeActionContainer.h"
#import "ixePropertyContainer.h"

@class ixeBaseAction;

@interface ixeBaseObject : NSObject

@property (nonatomic,weak) ixeBaseObject* parentObject;
@property (nonatomic,weak) ixeSandbox* sandbox;

@property (nonatomic,strong) NSString* ID;
@property (nonatomic,strong) NSMutableArray* childObjects;
@property (nonatomic,strong) ixeActionContainer* actionContainer;
@property (nonatomic,strong) ixePropertyContainer* propertyContainer;

-(void)addChildObject:(ixeBaseObject*)childObject;
-(void)addChildObjects:(NSArray*)childObjects;
-(NSArray*)childrenWithID:(NSString*)childObjectID;

-(void)applySettings;
-(void)applyFunction:(NSString*)functionName withParameters:(ixePropertyContainer*)parameterContainer;

@end
