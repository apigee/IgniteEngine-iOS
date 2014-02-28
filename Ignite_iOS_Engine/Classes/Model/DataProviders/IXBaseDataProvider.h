//
//  IXBaseDataProvider.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseObject.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) IXPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IXPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,copy) NSString* dataLocation;
@property (nonatomic,copy) NSString* objectsPath;
@property (nonatomic,copy) NSString* fetchPredicate;
@property (nonatomic,copy) NSString* fetchPredicateStrings;
@property (nonatomic,copy) NSString* sortDescriptorKey;
@property (nonatomic,assign) BOOL sortAscending;

@property (nonatomic,assign) NSInteger lastResponseStatusCode;
@property (nonatomic,copy) NSString* rawResponse;
@property (nonatomic,copy) NSString* lastResponseErrorMessage;

-(NSSortDescriptor*)sortDescriptor;
-(NSPredicate*)predicate;

-(void)loadData:(BOOL)forceGet;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed;

-(NSUInteger)getRowCount;
-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath;

@end
