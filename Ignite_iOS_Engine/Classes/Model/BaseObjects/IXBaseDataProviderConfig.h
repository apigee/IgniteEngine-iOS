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

@interface IXBaseDataProviderConfig : NSObject

@property (nonatomic,assign) Class dataProviderClass;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;
@property (nonatomic,strong) IXPropertyContainer* requestParameters;
@property (nonatomic,strong) IXPropertyContainer* requestHeaders;
@property (nonatomic,strong) IXPropertyContainer* fileAttachments;
@property (nonatomic,strong) IXEntityContainer* entityContainer;

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer requestParameters:(IXPropertyContainer*)requestParameters requestHeaders:(IXPropertyContainer*)requestHeaders andFileAttachments:(IXPropertyContainer*)fileAttachments;
+(instancetype)baseDataProviderConfigWithDataProviderClass:(Class)dataProviderClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer requestParameters:(IXPropertyContainer*)requestParameters requestHeaders:(IXPropertyContainer*)requestHeaders andFileAttachments:(IXPropertyContainer*)fileAttachments;

-(IXBaseDataProvider*)createDataProvider;

@end
