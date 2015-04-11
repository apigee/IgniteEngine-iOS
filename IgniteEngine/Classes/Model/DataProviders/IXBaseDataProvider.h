//
//  IXBaseDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseObject.h"
#import "IXAFHTTPSessionManager.h"

extern NSString* IXBaseDataProviderDidUpdateNotification;

//@class AFHTTPRequestOperationManager;

@interface IXBaseDataProvider : IXBaseObject

@property (nonatomic,strong) IXPropertyContainer* requestQueryParamsObject;
@property (nonatomic,strong) IXPropertyContainer* requestBodyObject;
@property (nonatomic,strong) IXPropertyContainer* requestHeadersObject;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentObject;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;
@property (nonatomic,assign,getter = shouldUrlEncodeParams) BOOL urlEncodeParams;
@property (nonatomic,assign,getter = shouldDeriveValueTypes) BOOL deriveValueTypes;
@property (nonatomic,assign,getter = isPathLocal)    BOOL pathIsLocal;

@property (nonatomic,copy) NSString* method;
@property (nonatomic,copy) NSString* body;
@property (nonatomic,copy) NSString* queryParams;
//@property (nonatomic,copy,readonly) NSString* fullDataLocation;
@property (nonatomic,copy) NSString* url;
//@property (nonatomic,copy,readonly) NSString* dataPath;

//-(void)createRequest;
//-(NSURLRequest*)createURLRequest;

-(void)loadData:(BOOL)forceGet;
-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed;
+(void)clearAllCachedResponses;

@end
