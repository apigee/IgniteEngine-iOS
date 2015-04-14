//
//  IXJSONDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXDataRowDataProvider.h"
#import "IXHTTPResponse.h"

typedef void(^LoadFinished)(BOOL success, NSURLSessionDataTask* task, id responseObject, NSError* error);

@interface IXHTTPDataProvider : IXDataRowDataProvider

//@property (nonatomic,strong) id lastJSONResponse;
//@property (nonatomic,strong) IXAFHTTPSessionManager *manager;
@property (nonatomic,strong) NSMutableDictionary* rowDataResultsDict;
//@property (nonatomic,copy,readonly) NSString* cacheID;
@property (nonatomic,strong,readonly) NSString* acceptedContentType;
@property (nonatomic,strong) IXHTTPResponse* response;
@property (nonatomic,strong) IXHTTPResponse* previousResponse;
@property (nonatomic,strong) IXHTTPResponse* nextResponse;
@property (nonatomic,strong) id responseSerializer;

@property (nonatomic,strong) NSString* paginationNextQueryParam;
@property (nonatomic,strong) NSString* paginationNextPath;
@property (nonatomic,strong) NSString* paginationNextValue;
@property (nonatomic,strong) NSString* paginationPrevQueryParam;
@property (nonatomic,strong) NSString* paginationPrevPath;
@property (nonatomic,strong) NSString* paginationPrevValue;
@property (nonatomic,strong) NSString* paginationDataPath;

//@property (nonatomic,strong) NSDictionary* queryParamsObject;
//@property (nonatomic,strong) NSDictionary* bodyObject;
//@property (nonatomic,copy) NSString* responseString;
//@property (nonatomic,assign) NSInteger responseStatusCode;
//@property (nonatomic,copy) NSDictionary* responseHeaders;
//@property (nonatomic,copy) NSString* responseErrorMessage;
//@property (nonatomic) CGFloat responseTime;
//@property (nonatomic) CFAbsoluteTime requestStartTime; // = CFAbsoluteTimeGetCurrent();
//@property (nonatomic) CFAbsoluteTime requestEndTime;
@property (nonatomic,assign,getter=shouldCacheResponse) BOOL cacheResponse;
@property (nonatomic,assign,getter=shouldAppendDataOnPaginate) BOOL appendDataOnPaginate;

-(void)loadData:(BOOL)forceGet completion:(LoadFinished)completion;
//-(void)loadDataFromCache:(NSString*)cachedResponse;
-(void)loadDataFromLocalPath;
-(void)buildHTTPRequest;
//-(NSString*)cacheForCacheID:(NSString*)cacheID;
//-(void)cacheResponse;
+(BOOL)cacheExistsForURL:(NSString*)url;
+(void)clearCacheForURL:(NSString*)url;
//-(void)fireLoadFinishdEventsFromCache;
//-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse;
//-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse isFromCache:(BOOL)isFromCache;

@end
