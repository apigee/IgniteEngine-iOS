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

@property (nonatomic,strong) IXPropertyContainer* queryParamsProperties;
@property (nonatomic,strong) IXPropertyContainer* bodyProperties;
@property (nonatomic,strong) IXPropertyContainer* headersProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;

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
