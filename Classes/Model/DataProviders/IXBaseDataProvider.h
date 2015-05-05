//
//  IXBaseDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
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

#import "IXBaseObject.h"
#import "IXAFHTTPSessionManager.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;

//@class AFHTTPRequestOperationManager;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) IXAttributeContainer* queryParamsProperties;
@property (nonatomic,strong) IXAttributeContainer* bodyProperties;
@property (nonatomic,strong) IXAttributeContainer* headersProperties;
@property (nonatomic,strong) IXAttributeContainer* fileAttachmentProperties;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,getter = shouldUrlEncodeParams) BOOL urlEncodeParams;
@property (nonatomic,assign,getter = shouldDeriveValueTypes) BOOL deriveValueTypes;
@property (nonatomic,assign,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSDictionary* body;
@property (nonatomic,strong) NSDictionary* queryParams;
//@property (nonatomic,copy,readonly) NSString* fullDataLocation;
@property (nonatomic,strong) NSString* url;
//@property (nonatomic,copy,readonly) NSString* dataPath;

//-(void)createRequest;
//-(NSURLRequest*)createURLRequest;

-(void)loadData:(BOOL)forceGet;
-(void)loadData:(BOOL)forceGet paginationKey:(NSString*)paginationKey;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed paginationKey:(NSString*)paginationKey;
+(void)clearAllCachedResponses;

@end
