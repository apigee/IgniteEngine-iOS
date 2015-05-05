//
//  IXBaseDataProviderConfig.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/26/14.
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

#import "IXBaseDataProviderConfig.h"

#import "IXBaseDataProvider.h"
#import "IXEntityContainer.h"
#import "IXActionContainer.h"
#import "IXAttributeContainer.h"
#import "IXLogger.h"
#import "IXEntityContainer.h"

@implementation IXBaseDataProviderConfig

-(instancetype)initWithDataProviderClass:(Class)dataProviderClass
                              styleClass:(NSString*)styleClass
                       propertyContainer:(IXAttributeContainer*)propertyContainer
                         actionContainer:(IXActionContainer*)actionContainer
                      requestQueryParams:(IXAttributeContainer*)requestQueryParams
                             requestBody:(IXAttributeContainer*)requestBody
                          requestHeaders:(IXAttributeContainer*)requestHeaders
                         fileAttachments:(IXAttributeContainer*)fileAttachments
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
        if( [dataProviderClass isSubclassOfClass:[IXBaseDataProvider class]])
        {
            IXAttributeContainer* propertyContainer = nil;
            id propertiesDict = dataProviderJSONDict[kIX_ATTRIBUTES];
            if( [propertiesDict isKindOfClass:[NSDictionary class]] )
            {
                id dataProviderID = dataProviderJSONDict[kIX_ID];
                if( dataProviderID )
                {
                    propertiesDict = [NSMutableDictionary dictionaryWithDictionary:propertiesDict];
                    [propertiesDict setObject:dataProviderID forKey:kIX_ID];
                }
                propertyContainer = [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict];
            }
            
            NSString* dataProviderStyleClass = dataProviderJSONDict[kIX_STYLE];
            if( dataProviderStyleClass && ![dataProviderStyleClass isKindOfClass:[NSString class]] )
            {
                dataProviderStyleClass = nil;
            }
            
            IXActionContainer* actionContainer = [IXActionContainer actionContainerWithJSONActionsArray:dataProviderJSONDict[kIX_ACTIONS]];
            IXAttributeContainer* requestQueryParams = (propertiesDict[kIX_DP_QUERYPARAMS]) ? [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict[kIX_DP_QUERYPARAMS]] : [IXAttributeContainer new];
            IXAttributeContainer* requestBody = (propertiesDict[kIX_DP_BODY]) ? [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict[kIX_DP_BODY]] : [IXAttributeContainer new];
            IXAttributeContainer* requestHeaders = (propertiesDict[kIX_DP_HEADERS]) ? [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict[kIX_DP_HEADERS]] : [IXAttributeContainer new];
            IXAttributeContainer* fileAttachments = (propertiesDict[kIX_DP_ATTACHMENTS]) ? [IXAttributeContainer attributeContainerWithJSONDict:propertiesDict[kIX_DP_ATTACHMENTS]] : nil;
            
            IXEntityContainer* entityContainer = nil;
//            if( dataProviderClass == [IXCoreDataDataProvider class] )
//            {
//                entityContainer = [IXEntityContainer entityContainerWithJSONEntityDict:dataProviderJSONDict[kIX_DP_ENTITY]];
//            }
            
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
        [dataProvider setAttributeContainer:[[self propertyContainer] copy]];
        
        if( [dataProvider attributeContainer] == nil )
        {
            // We need to have a property container for the default values and modifies to work!
            [dataProvider setAttributeContainer:[[IXAttributeContainer alloc] init]];
        }
        
//        if( [dataProvider isKindOfClass:[IXCoreDataDataProvider class]] )
//        {
//            [((IXCoreDataDataProvider*)dataProvider) setEntityContainer:[[self entityContainer] copy]];
//        }
    }
    return dataProvider;
}

@end
