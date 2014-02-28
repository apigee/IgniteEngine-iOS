//
//  IXBaseDataProviderConfig.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseDataProviderConfig.h"

#import "IXBaseDataProvider.h"
#import "IXCoreDataDataProvider.h"
#import "IXEntityContainer.h"
#import "IXActionContainer.h"
#import "IXPropertyContainer.h"

@implementation IXBaseDataProviderConfig

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer requestParameters:(IXPropertyContainer*)requestParameters requestHeaders:(IXPropertyContainer*)requestHeaders andFileAttachments:(IXPropertyContainer*)fileAttachments
{
    self = [super init];
    if( self )
    {
        _dataProviderClass = dataProviderClass;
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _requestParameters = requestParameters;
        _requestHeaders = requestHeaders;
        _fileAttachments = fileAttachments;
    }
    return self;
}

+(instancetype)baseDataProviderConfigWithDataProviderClass:(Class)dataProviderClass propertyContainer:(IXPropertyContainer*)propertyContainer actionContainer:(IXActionContainer*)actionContainer requestParameters:(IXPropertyContainer*)requestParameters requestHeaders:(IXPropertyContainer*)requestHeaders andFileAttachments:(IXPropertyContainer*)fileAttachments
{
    return [[[self class] alloc] initWithDataProviderClass:dataProviderClass propertyContainer:propertyContainer actionContainer:actionContainer requestParameters:requestParameters requestHeaders:requestHeaders andFileAttachments:fileAttachments];
}

-(IXBaseDataProvider*)createDataProvider
{
    IXBaseDataProvider* dataProvider = [[[self dataProviderClass] alloc] init];
    if( dataProvider )
    {
        [dataProvider setPropertyContainer:[[self propertyContainer] copy]];
        [dataProvider setActionContainer:[[self actionContainer] copy]];
        [dataProvider setRequestParameterProperties:[[self requestParameters] copy]];
        [dataProvider setRequestHeaderProperties:[[self requestHeaders] copy]];
        [dataProvider setFileAttachmentProperties:[[self fileAttachments] copy]];
        if( [dataProvider isKindOfClass:[IXCoreDataDataProvider class]] )
        {
            [((IXCoreDataDataProvider*)dataProvider) setEntityContainer:[[self entityContainer] copy]];
        }
    }
    return dataProvider;
}


@end
