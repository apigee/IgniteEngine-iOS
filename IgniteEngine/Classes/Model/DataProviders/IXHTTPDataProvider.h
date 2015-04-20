//
//  IXHTTPDataProvider.m
//  Ignite Engine
//
//  Created by Brandon Shelley on 4/7/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXDataRowDataProvider.h"
#import "IXHTTPResponse.h"

typedef void(^LoadFinished)(BOOL success, NSURLSessionDataTask* task, id responseObject, NSError* error);

// Internal properties
IX_STATIC_CONST_STRING kIXProgressKVOKey = @"fractionCompleted";


@interface IXHTTPDataProvider : IXDataRowDataProvider

@property (nonatomic,strong) NSMutableDictionary* rowDataResultsDict;
@property (nonatomic,strong) IXHTTPResponse* response;
@property (nonatomic,strong) IXHTTPResponse* previousResponse;
@property (nonatomic,strong) id responseSerializer;

@property (nonatomic,strong) NSString* paginationNextQueryParam;
@property (nonatomic,strong) NSString* paginationNextPath;
@property (nonatomic,strong) NSString* paginationNextValue;
@property (nonatomic,strong) NSString* paginationPrevQueryParam;
@property (nonatomic,strong) NSString* paginationPrevPath;
@property (nonatomic,strong) NSString* paginationPrevValue;
@property (nonatomic,strong) NSString* paginationDataPath;
@property (nonatomic,assign,getter=shouldCacheResponse) BOOL cacheResponse;
@property (nonatomic,assign,getter=shouldAppendDataOnPaginate) BOOL appendDataOnPaginate;

-(void)loadData:(BOOL)forceGet completion:(LoadFinished)completion;
-(void)loadDataFromLocalPath;
-(void)buildHTTPRequest;
+(BOOL)cacheExistsForURL:(NSString*)url;
+(void)clearCacheForURL:(NSString*)url;
-(void)GET:(NSString*)url completion:(LoadFinished)completion;
-(void)POST:(NSString*)url completion:(LoadFinished)completion;
-(void)PUT:(NSString*)url completion:(LoadFinished)completion;
-(void)DELETE:(NSString*)url completion:(LoadFinished)completion;

@end
