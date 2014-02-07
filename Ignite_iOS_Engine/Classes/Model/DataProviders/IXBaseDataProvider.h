//
//  IXBaseDataProvider.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseObject.h"

@protocol IXDataProviderDelegate <NSObject>

-(void)dataProviderDidUpdate:(IXBaseDataProvider*)coreDataProvider;

@end

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) IXPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IXPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;

@property (nonatomic,strong) NSMutableArray* delegates;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,copy) NSString* dataLocation;

@property (nonatomic,assign) NSInteger lastResponseStatusCode;
@property (nonatomic,copy) NSString* rawResponse;
@property (nonatomic,copy) NSString* lastResponseErrorMessage;

-(void)notifyAllDelegates;
-(void)addDelegate:(id<IXDataProviderDelegate>)delegate;
-(void)removeDelegate:(id<IXDataProviderDelegate>)delegate;

-(void)loadData:(BOOL)forceGet;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed;


-(NSInteger)getRowCount;
-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath;

@end
