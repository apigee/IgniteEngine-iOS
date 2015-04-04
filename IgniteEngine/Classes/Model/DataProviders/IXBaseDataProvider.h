//
//  IXBaseDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseObject.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;

@class AFHTTPRequestOperationManager;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) AFHTTPRequestOperationManager* requestManager;
@property (nonatomic,strong) IXPropertyContainer* requestQueryParamsObject;
@property (nonatomic,strong) IXPropertyContainer* requestBodyObject;
@property (nonatomic,strong) IXPropertyContainer* requestHeadersObject;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentObject;

@property (nonatomic,assign,readonly,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,readonly,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,copy,readonly) NSString* cacheID;
@property (nonatomic,copy,readonly) NSString* acceptedContentType;
@property (nonatomic,copy,readonly) NSString* method;
@property (nonatomic,copy,readonly) NSString* body;
@property (nonatomic,copy,readonly) NSString* queryParams;
//@property (nonatomic,copy,readonly) NSString* fullDataLocation;
@property (nonatomic,copy,readonly) NSString* url;
//@property (nonatomic,copy,readonly) NSString* dataPath;

@property (nonatomic,assign) NSInteger responseStatusCode;
@property (nonatomic,copy)   NSString* responseRawString;
@property (nonatomic,copy)   NSDictionary* responseHeaders;
@property (nonatomic,copy)   NSString* responseErrorMessage;

//-(void)createRequest;
//-(NSURLRequest*)createURLRequest;

-(void)loadData:(BOOL)forceGet;
-(void)fireLoadFinishedEventsFromCachedResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache;

-(void)cacheResponse;
+(void)clearCache;

@end
