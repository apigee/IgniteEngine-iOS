//
//  IXBaseDataProvider.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseObject.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;

@class AFHTTPClient;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) IXPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IXPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,strong) AFHTTPClient* httpClient;
@property (nonatomic,copy) NSString* authType;
@property (nonatomic,copy) NSString* dataLocation;
@property (nonatomic,copy) NSString* objectsPath;
@property (nonatomic,copy) NSString* predicateFormat;
@property (nonatomic,copy) NSString* predicateArguments;
@property (nonatomic,copy) NSString* sortDescriptorKey;
@property (nonatomic,copy) NSString* sortOrder;

@property (nonatomic,assign) NSInteger lastResponseStatusCode;
@property (nonatomic,copy) NSString* rawResponse;
@property (nonatomic,copy) NSString* lastResponseErrorMessage;

-(NSSortDescriptor*)sortDescriptor;
-(NSPredicate*)predicate;

-(void)loadData:(BOOL)forceGet;
-(void)authenticateAndEnqueRequestOperation:(AFHTTPRequestOperation*)requestOperation;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed;

-(NSUInteger)getRowCount;
-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath;

@end
