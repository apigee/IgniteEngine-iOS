//
//  IXHTTPDataProvider.m
//  Ignite Engine
//
//  Created by Brandon Shelley on 4/7/15.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
