//
//  IXBaseDataProvider.m
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

#import "IXBaseDataProvider.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "AFOAuth2Manager.h"
#import "IXImage.h"
#import "IXAttributeContainer.h"
#import "IXEntityContainer.h"
#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXPathHandler.h"
#import "IXOAuthWebAuthViewController.h"
#import "IXSandbox.h"
#import "IXNavigationViewController.h"
#import "IXAppManager.h"
#import "UIViewController+IXAdditions.h"
#import "NSDictionary+IXAdditions.h"

//#import <RestKit/RestKit.h>

NSString* IXBaseDataProviderDidUpdateNotification = @"IXBaseDataProviderDidUpdateNotification";

// IXBaseDataProvider Attributes
IX_STATIC_CONST_STRING kIXAutoLoad = @"autoLoad.enabled";
IX_STATIC_CONST_STRING kIXUrl = @"url";
IX_STATIC_CONST_STRING kIXUrlEncodeParams = @"urlEncodeParams.enabled"; // When enabled, url-encodes query params
IX_STATIC_CONST_STRING kIXDeriveValueTypes = @"deriveValueTypes.enabled"; // Default=true; parses POST/PUT body JSON number and bool values
IX_STATIC_CONST_STRING kIXRequestType = @"requestType"; // must match counterpart in HTTPDP

// IXBaseDataProvider Attribute Accepted Values
IX_STATIC_CONST_STRING kIXRequestTypeJSON = @"json"; // kIXBodyEncoding - must match counterpart in HTTPDP

// IXBaseDataProvider Functions
IX_STATIC_CONST_STRING kIXDeleteCookies = @"deleteCookies"; // kIXCookieURL is the parameter for this function.
IX_STATIC_CONST_STRING kIXCookieURL = @"url"; // Function parameter for deleteCookies

// IXBaseDataProvider Events
IX_STATIC_CONST_STRING kIXStarted = @"started";

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXRequestBodyObjectNSCodingKey = @"requestBodyObject";
IX_STATIC_CONST_STRING kIXRequestQueryParamsObjectNSCodingKey = @"requestQueryParamsObject";
IX_STATIC_CONST_STRING kIXRequestHeadersObjectNSCodingKey = @"requestHeadersObject";
IX_STATIC_CONST_STRING kIXFileAttachmentObjectNSCodingKey = @"fileAttachmentObject";

@interface IXImage ()

@property (nonatomic,strong) UIImage* defaultImage;

@end

@interface IXBaseDataProvider () <IXOAuthWebAuthViewControllerDelegate>

@end

@implementation IXBaseDataProvider
@synthesize body = _body;
@synthesize queryParams = _queryParams;

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

-(id)copyWithZone:(NSZone *)zone
{
    IXBaseDataProvider *copiedDataProvider = [super copyWithZone:zone];
    [copiedDataProvider setQueryParamsProperties:[[self queryParamsProperties] copy]];
    [copiedDataProvider setBodyProperties:[[self bodyProperties] copy]];
    [copiedDataProvider setHeadersProperties:[[self headersProperties] copy]];
    [copiedDataProvider setFileAttachmentProperties:[[self fileAttachmentProperties] copy]];
    return copiedDataProvider;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self queryParamsProperties] forKey:kIXRequestQueryParamsObjectNSCodingKey];
    [aCoder encodeObject:[self bodyProperties] forKey:kIXRequestBodyObjectNSCodingKey];
    [aCoder encodeObject:[self headersProperties] forKey:kIXRequestHeadersObjectNSCodingKey];
    [aCoder encodeObject:[self fileAttachmentProperties] forKey:kIXFileAttachmentObjectNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setQueryParamsProperties:[aDecoder decodeObjectForKey:kIXRequestQueryParamsObjectNSCodingKey]];
        [self setBodyProperties:[aDecoder decodeObjectForKey:kIXRequestBodyObjectNSCodingKey]];
        [self setHeadersProperties:[aDecoder decodeObjectForKey:kIXRequestHeadersObjectNSCodingKey]];
        [self setFileAttachmentProperties:[aDecoder decodeObjectForKey:kIXFileAttachmentObjectNSCodingKey]];
    }
    return self;
}

-(void)setHeadersProperties:(IXAttributeContainer *)headersProperties
{
    _headersProperties = headersProperties;
    [_headersProperties setOwnerObject:self];
}

-(void)setQueryParamsProperties:(IXAttributeContainer *)queryParamsProperties
{
    _queryParamsProperties = queryParamsProperties;
    [_queryParamsProperties setOwnerObject:self];
}

-(void)setBodyProperties:(IXAttributeContainer *)bodyProperties
{
    _bodyProperties = bodyProperties;
    [_bodyProperties setOwnerObject:self];
}

-(void)setFileAttachmentProperties:(IXAttributeContainer *)fileAttachmentProperties
{
    _fileAttachmentProperties = fileAttachmentProperties;
    [fileAttachmentProperties setOwnerObject:self];
}

-(void)applySettings
{
    [super applySettings];

    [self setAutoLoad:[[self attributeContainer] getBoolValueForAttribute:kIXAutoLoad defaultValue:NO]];
    NSString* url = [[self attributeContainer] getPathValueForAttribute:kIXUrl basePath:nil defaultValue:nil];
    [self setUrl:url];
    [self setPathIsLocal:[IXPathHandler pathIsLocal:url]];
    [self setUrlEncodeParams:[[self attributeContainer] getBoolValueForAttribute:kIXUrlEncodeParams defaultValue:YES]];
    [self setDeriveValueTypes:[[self attributeContainer] getBoolValueForAttribute:kIXDeriveValueTypes defaultValue:YES]];
    [self setBody:[_bodyProperties getAllAttributesAsDictionaryWithURLEncodedValues:NO] ?: @{}];
    [self setQueryParams:[_queryParamsProperties getAllAttributesAsDictionaryWithURLEncodedValues:_urlEncodeParams] ?: @{}];
}

-(void)setBody:(NSDictionary *)body
{
    @try {
        NSString* bodyString = [[self attributeContainer] getStringValueForAttribute:kIX_DP_BODY defaultValue:nil];
        if (body) {
            _body = body;
        } else if (bodyString) {
            NSError* __autoreleasing error = nil;
            _body = [NSJSONSerialization JSONObjectWithData:[bodyString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error] ?: nil;
        }
        if (_deriveValueTypes && [[[self attributeContainer] getStringValueForAttribute:kIXRequestType defaultValue:nil] isEqualToString:kIXRequestTypeJSON]) {
            _body = [NSDictionary ix_dictionaryWithParsedValuesFromDictionary:_body];
        }
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: 'body' included with request was not a valid JSON object or string: %@", body);
    }
}

-(void)setQueryParams:(NSDictionary *)queryParams
{
    @try {
        NSString* queryParamsString = [[self attributeContainer] getStringValueForAttribute:kIX_DP_QUERYPARAMS defaultValue:nil];
        if (queryParams) {
            _queryParams = queryParams;
        } else if (queryParamsString) {
            _queryParams = [NSDictionary ix_dictionaryFromQueryParamsString:queryParamsString];
        }
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR: 'queryParams' included with request was not a valid JSON object or string: %@", queryParams);
    }
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    returnValue = [super getReadOnlyPropertyValue:propertyName];
    return returnValue;
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXDeleteCookies] )
    {
        NSString* urlToDeleteCookiesFor = [parameterContainer getStringValueForAttribute:kIXCookieURL defaultValue:nil];
        if( [urlToDeleteCookiesFor length] > 0 )
        {
            NSArray *cookiesToDelete = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlToDeleteCookiesFor]];
            for (NSHTTPCookie *cookie in cookiesToDelete )
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)loadData:(BOOL)forceGet
{
    [self loadData:forceGet paginationKey:nil];
}

-(void)loadData:(BOOL)forceGet paginationKey:(NSString *)paginationKey
{
    [[self actionContainer] executeActionsForEventNamed:kIXStarted];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    [self fireLoadFinishedEvents:loadDidSucceed paginationKey:nil];
}


-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed paginationKey:(NSString *)paginationKey
{

    IX_LOG_DEBUG(@"Datasource load %@: %@", (loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED, self.url);
    
    [[self actionContainer] executeActionsForEventNamed:(loadDidSucceed) ? kIX_SUCCESS : kIX_FAILED];
    [[self actionContainer] executeActionsForEventNamed:kIX_DONE];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                            object:self];
    });
}

+(void)clearAllCachedResponses
{
    NSURLCache* cache =[NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
}

@end
