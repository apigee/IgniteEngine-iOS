//
//  IXBaseDataProviderConfig.m
//  Ignite Engine
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
#import "IXLogger.h"
#import "IXEntityContainer.h"

@implementation IXBaseDataProviderConfig

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass
                              styleClass:(NSString*)styleClass
                       propertyContainer:(IXPropertyContainer*)propertyContainer
                         actionContainer:(IXActionContainer*)actionContainer
                      requestQueryParams:(IXPropertyContainer*)requestQueryParams
                             requestBody:(IXPropertyContainer*)requestBody
                          requestHeaders:(IXPropertyContainer*)requestHeaders
                         fileAttachments:(IXPropertyContainer*)fileAttachments
                         entityContainer:(IXEntityContainer*)entityContainer
{
    self = [super init];
    if( self )
    {
        _styleClass = [styleClass copy];
        _dataProviderClass = dataProviderClass;
        _propertyContainer = propertyContainer;
        _actionContainer = actionContainer;
        _requestQueryParams = requestQueryParams;
        _requestBody = requestBody;
        _requestHeaders = requestHeaders;
        _fileAttachments = fileAttachments;
        _entityContainer = entityContainer;
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithDataProviderClass:[self dataProviderClass]
                                                             styleClass:[self styleClass]
                                                      propertyContainer:[[self propertyContainer] copy]
                                                        actionContainer:[[self actionContainer] copy]
                                                     requestQueryParams:[[self requestQueryParams] copy]
                                                            requestBody:[[self requestBody] copy]
                                                         requestHeaders:[[self requestHeaders] copy]
                                                        fileAttachments:[[self fileAttachments] copy]
                                                        entityContainer:[[self entityContainer] copy]];
}

+(instancetype)dataProviderConfigWithJSONDictionary:(NSDictionary*)dataProviderJSONDict
{
    IXBaseDataProviderConfig* dataProviderConfig = nil;
    if( [dataProviderJSONDict isKindOfClass:[NSDictionary class]] && [dataProviderJSONDict allKeys] > 0 )
    {
        NSString* dataProviderType = dataProviderJSONDict[kIX_TYPE];
        NSString* dataProviderClassString = [NSString stringWithFormat:kIX_DATA_PROVIDER_CLASS_NAME_FORMAT,dataProviderType];
        
        Class dataProviderClass = NSClassFromString(dataProviderClassString);
        if( [dataProviderClass isSubclassOfClass:[IXBaseDataProvider class]]  )
        {
            IXPropertyContainer* propertyContainer = nil;
            id propertiesDict = dataProviderJSONDict[kIX_ATTRIBUTES];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id dataProviderID = dataProviderJSONDict[kIX_ID];
                if( dataProviderID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:dataProviderID forKey:kIX_ID];
                }
                propertyContainer = [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict];
            }
            
            NSString* dataProviderStyleClass = dataProviderJSONDict[kIX_STYLE];
            if( dataProviderStyleClass && ![dataProviderStyleClass isKindOfClass:[NSString class]] )
            {
                dataProviderStyleClass = nil;
            }
            
            IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:dataProviderJSONDict[kIX_ACTIONS]];
            IXPropertyContainer* requestQueryParams = (propertiesDict[kIX_DP_QUERYPARAMS]) ? [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict[kIX_DP_QUERYPARAMS]] : [IXPropertyContainer new];
            IXPropertyContainer* requestBody = (propertiesDict[kIX_DP_BODY]) ? [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict[kIX_DP_BODY]] : [IXPropertyContainer new];
            IXPropertyContainer* requestHeaders = (propertiesDict[kIX_DP_HEADERS]) ? [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict[kIX_DP_HEADERS]] : [IXPropertyContainer new];
            IXPropertyContainer* fileAttachments = (propertiesDict[kIX_DP_ATTACHMENTS]) ? [IXPropertyContainer propertyContainerWithJSONDict:propertiesDict[kIX_DP_ATTACHMENTS]] : nil;
            
            IXEntityContainer* entityContainer = nil;
            if( dataProviderClass == [IXCoreDataDataProvider class] )
            {
                entityContainer = [IXEntityContainer entityContainerWithJSONEntityDict:dataProviderJSONDict[kIX_DP_ENTITY]];
            }
            
            dataProviderConfig = [[IXBaseDataProviderConfig alloc] initWithDataProviderClass:dataProviderClass
                                                                                  styleClass:dataProviderStyleClass
                                                                           propertyContainer:propertyContainer
                                                                             actionContainer:actionContainer
                                                                          requestQueryParams:requestQueryParams
                                                                                 requestBody:requestBody
                                                                              requestHeaders:requestHeaders
                                                                             fileAttachments:fileAttachments
                                                                             entityContainer:entityContainer];
        }
        else
        {
            IX_LOG_ERROR(@"ERROR from %@ in %@ : DataProvider class with type: %@ was not found \n Description of data provider: \n %@",THIS_FILE,THIS_METHOD,dataProviderType, [dataProviderJSONDict description]);
        }
    }
    return dataProviderConfig;
}

+(NSArray*)dataProviderConfigsWithJSONArray:(NSArray*)dataProviderJSONArray
{
    NSMutableArray* dataProviderConfigsArray = nil;
    if( [dataProviderJSONArray isKindOfClass:[NSArray class]] && [dataProviderJSONArray count] )
    {
        dataProviderConfigsArray = [NSMutableArray array];
        for( id dataProviderValueDict in dataProviderJSONArray )
        {
            IXBaseDataProviderConfig* dataProvider = [IXBaseDataProviderConfig dataProviderConfigWithJSONDictionary:dataProviderValueDict];
            if( dataProvider != nil )
            {
                [dataProviderConfigsArray addObject:dataProvider];
            }
        }
    }
    return dataProviderConfigsArray;
}

+(NSArray*)createDataProvidersFromConfigs:(NSArray*)dataProviderConfigs
{
    NSMutableArray* dataProviders = nil;
    for( IXBaseDataProviderConfig* dataProviderConfig in dataProviderConfigs )
    {
        if( [dataProviderConfig isKindOfClass:[IXBaseDataProviderConfig class]] )
        {
            IXBaseDataProvider* dataProvider = [dataProviderConfig createDataProvider];
            if( dataProvider )
            {
                if( dataProviders == nil )
                {
                    dataProviders = [NSMutableArray arrayWithObject:dataProvider];
                }
                else
                {
                    [dataProviders addObject:dataProvider];
                }
            }
        }
    }
    return dataProviders;
}

-(IXBaseDataProvider*)createDataProvider
{
    IXBaseDataProvider* dataProvider = [[[self dataProviderClass] alloc] init];
    if( dataProvider )
    {
        [dataProvider setStyleClass:[[self styleClass] copy]];
        [dataProvider setActionContainer:[[self actionContainer] copy]];
        [dataProvider setQueryParamsProperties:[[self requestQueryParams] copy]];
        [dataProvider setBodyProperties:[[self requestBody] copy]];
        [dataProvider setHeadersProperties:[[self requestHeaders] copy]];
        [dataProvider setFileAttachmentProperties:[[self fileAttachments] copy]];
        [dataProvider setPropertyContainer:[[self propertyContainer] copy]];
        
        if( [dataProvider propertyContainer] == nil )
        {
            // We need to have a property container for the default values and modifies to work!
            [dataProvider setPropertyContainer:[[IXPropertyContainer alloc] init]];
        }
        
//        if( [dataProvider isKindOfClass:[IXCoreDataDataProvider class]] )
//        {
//            [((IXCoreDataDataProvider*)dataProvider) setEntityContainer:[[self entityContainer] copy]];
//        }
    }
    return dataProvider;
}

@end
