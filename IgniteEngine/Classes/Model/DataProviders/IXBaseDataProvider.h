//
//  IXBaseDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseObject.h"
#import "AFNetworking.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;
typedef void(^LoadFinished)(BOOL success, AFHTTPRequestOperation* operation, NSError* error);

@class AFHTTPRequestOperationManager;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
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

@property (nonatomic,copy) id responseObject;
@property (nonatomic,copy) id responseSerializer;
@property (nonatomic,copy) NSString* responseString;
@property (nonatomic,assign) NSInteger responseStatusCode;
@property (nonatomic,copy) NSDictionary* responseHeaders;
@property (nonatomic,copy) NSString* responseErrorMessage;

//-(void)createRequest;
//-(NSURLRequest*)createURLRequest;

-(void)loadData:(BOOL)forceGet;
-(void)loadData:(BOOL)forceGet completion:(LoadFinished)completion;
-(void)loadDataFromCache:(NSString*)cachedResponse;
-(void)loadDataFromLocalPath;
-(void)buildHTTPRequest;
-(void)fireLoadFinishedEventsFromCachedResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache;

-(void)cacheResponse;
+(void)clearCache;

@end
