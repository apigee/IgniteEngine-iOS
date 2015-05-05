//
//  IXBaseDataProviderConfig.h
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
