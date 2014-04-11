//
//  IXBaseDataProviderConfig.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXActionContainer;
@class IXPropertyContainer;
@class IXBaseDataProvider;
@class IXEntityContainer;

@interface IXBaseDataProviderConfig : NSObject <NSCopying>

@property (nonatomic,assign) Class dataProviderClass;
@property (nonatomic,copy)   NSString* styleClass;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXPropertyContainer* requestParameters;
@property (nonatomic,strong) IXPropertyContainer* requestHeaders;
@property (nonatomic,strong) IXPropertyContainer* fileAttachments;
@property (nonatomic,strong) IXEntityContainer* entityContainer;

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass
                              styleClass:(NSString*)styleClass
                       propertyContainer:(IXPropertyContainer*)propertyContainer
                         actionContainer:(IXActionContainer*)actionContainer
                       requestParameters:(IXPropertyContainer*)requestParameters
                          requestHeaders:(IXPropertyContainer*)requestHeaders
                         fileAttachments:(IXPropertyContainer*)fileAttachments
                         entityContainer:(IXEntityContainer*)entityContainer;

+(instancetype)dataProviderConfigWithJSONDictionary:(NSDictionary*)dataProviderJSONDict;
+(NSArray*)dataProviderConfigsWithJSONArray:(NSArray*)dataProviderValueArray;

+(NSArray*)createDataProvidersFromConfigs:(NSArray*)dataProviderConfigs;
-(IXBaseDataProvider*)createDataProvider;

@end
