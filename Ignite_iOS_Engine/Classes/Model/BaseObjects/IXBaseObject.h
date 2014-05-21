//
//  IXBaseObject.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXConstants.h"
#import "IXSandbox.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"


@class IXBaseAction;

@interface IXBaseObject : NSObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXBaseObject* parentObject;
@property (nonatomic,weak) IXSandbox* sandbox;

@property (nonatomic,copy) NSString* ID;
@property (nonatomic,copy) NSString* styleClass;

@property (nonatomic,strong) NSMutableArray* childObjects;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;

-(void)addChildObject:(IXBaseObject*)childObject;
-(void)removeChildObject:(IXBaseObject*)childObject;
-(void)addChildObjects:(NSArray*)childObjects;
-(NSArray*)childrenWithID:(NSString*)childObjectID;
-(NSArray*)childrenThatAreKindOfClass:(Class)baseObjectClass;

-(void)applySettings;
-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer;
-(void)beginAnimation:(NSString*)animation duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount params:(NSDictionary*)params;
-(void)endAnimation:(NSString*)animation;
-(NSString*)getReadOnlyPropertyValue:(NSString*)propertyName;

@end
