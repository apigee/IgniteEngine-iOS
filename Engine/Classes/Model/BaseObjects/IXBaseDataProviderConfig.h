//
//  IXBaseDataProviderConfig.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXActionContainer;
@class IXAttributeContainer;
@class IXBaseDataProvider;
@class IXEntityContainer;

@interface IXBaseDataProviderConfig : NSObject <NSCopying>

@property (nonatomic,assign) Class dataProviderClass;
@property (nonatomic,copy)   NSString* styleClass;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXAttributeContainer* propertyContainer;
@property (nonatomic,strong) IXAttributeContainer* requestQueryParams;
@property (nonatomic,strong) IXAttributeContainer* requestBody;
@property (nonatomic,strong) IXAttributeContainer* requestHeaders;
@property (nonatomic,strong) IXAttributeContainer* fileAttachments;
@property (nonatomic,strong) IXEntityContainer* entityContainer;

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass
                              styleClass:(NSString*)styleClass
                       propertyContainer:(IXAttributeContainer*)propertyContainer
                         actionContainer:(IXActionContainer*)actionContainer
                      requestQueryParams:(IXAttributeContainer*)requestQueryParams
                             requestBody:(IXAttributeContainer*)requestBody
                          requestHeaders:(IXAttributeContainer*)requestHeaders
                         fileAttachments:(IXAttributeContainer*)fileAttachments
                         entityContainer:(IXEntityContainer*)entityContainer;

+(instancetype)dataProviderConfigWithJSONDictionary:(NSDictionary*)dataProviderJSONDict;
+(NSArray*)dataProviderConfigsWithJSONArray:(NSArray*)dataProviderValueArray;

+(NSArray*)createDataProvidersFromConfigs:(NSArray*)dataProviderConfigs;
-(IXBaseDataProvider*)createDataProvider;

@end
