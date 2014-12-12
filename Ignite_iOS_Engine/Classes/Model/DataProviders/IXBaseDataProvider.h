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

@property (nonatomic,strong) AFHTTPClient* httpClient;
@property (nonatomic,strong) IXPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IXPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;

@property (nonatomic,assign,readonly,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,readonly,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,copy,readonly) NSString* cacheID;
@property (nonatomic,copy,readonly) NSString* acceptedContentType;
@property (nonatomic,copy,readonly) NSString* httpMethod;
@property (nonatomic,copy,readonly) NSString* httpBody;
@property (nonatomic,copy,readonly) NSString* fullDataLocation;
@property (nonatomic,copy,readonly) NSString* dataBaseURL;
@property (nonatomic,copy,readonly) NSString* dataPath;

@property (nonatomic,assign) NSInteger responseStatusCode;
@property (nonatomic,copy)   NSString* responseRawString;
@property (nonatomic,copy)   NSString* responseErrorMessage;

-(void)createHTTPClient;
-(NSURLRequest*)createURLRequest;

-(void)loadData:(BOOL)forceGet;
-(void)fireLoadFinishedEventsFromCachedResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache;

+(void)clearCache;

@end
