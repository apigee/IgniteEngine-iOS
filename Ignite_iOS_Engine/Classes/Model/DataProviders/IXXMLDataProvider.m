//
//  IXXMLDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXXMLDataProvider.h"

#import "IXImage.h"
#import "IXPathHandler.h"
#import "IXAFXMLRequestOperation.h"
#import "IXDataGrabber.h"

#import "RXMLElement.h"

@interface IXImage ()

@property (nonatomic,strong) UIImage* defaultImage;

@end

@interface IXXMLDataProvider ()

@property (nonatomic,assign) BOOL isLocalPath;

@property (nonatomic,copy) NSString* httpMethod;
@property (nonatomic,copy) NSString* rowBaseDataPath;

@property (nonatomic,assign) NSUInteger dataRowCount;
@property (nonatomic,strong) RXMLElement* lastXMLResponse;

@end

@implementation IXXMLDataProvider

-(void)applySettings
{
    [super applySettings];
    
    if( [self dataLocation] == nil )
        return;
    
    [self setRowBaseDataPath:[[self propertyContainer] getStringPropertyValue:@"datarow.basepath" defaultValue:nil]];
    [self setIsLocalPath:[IXPathHandler pathIsLocal:[self dataLocation]]];
    
    if( ![self isLocalPath] )
    {
        AFHTTPClientParameterEncoding paramEncoding = AFJSONParameterEncoding;
        NSString* parameterEncoding = [[self propertyContainer] getStringPropertyValue:@"parameter_encoding" defaultValue:@"json"];
        if( [parameterEncoding isEqualToString:@"form"] ) {
            paramEncoding = AFFormURLParameterEncoding;
        } else if( [parameterEncoding isEqualToString:@"plist"] ) {
            paramEncoding = AFPropertyListParameterEncoding;
        }
        
        [[self httpClient] setParameterEncoding:paramEncoding];
        
        [self setHttpMethod:[[self propertyContainer] getStringPropertyValue:@"http_method" defaultValue:@"GET"]];
    }
    else
    {
        [self setDataLocation:[[self propertyContainer] getPathPropertyValue:@"data.baseurl" basePath:nil defaultValue:nil]];
        [self setHttpClient:nil];
        [self setHttpMethod:nil];
    }
    
    NSString* acceptedContentType = [[self propertyContainer] getStringPropertyValue:@"accepted_content_type" defaultValue:nil];
    [IXAFXMLRequestOperation addAcceptedContentType:acceptedContentType];
}

-(void)fireLoadFinishedEventsFromCachedResponse
{
    RXMLElement* xmlElement = [RXMLElement elementFromXMLString:[self rawResponse] encoding:NSUTF8StringEncoding];
    if( [xmlElement isValid] )
    {
        [self setLastXMLResponse:xmlElement];
        [super fireLoadFinishedEventsFromCachedResponse];
    }
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    if (forceGet == NO)
    {
        [self fireLoadFinishedEvents:YES shouldCacheResponse:NO];
    }
    else
    {
        [self setRawResponse:nil];
        [self setLastXMLResponse:nil];
        [self setLastResponseStatusCode:0];
        [self setLastResponseErrorMessage:nil];
        
        if ( [self dataLocation] != nil )
        {
            if( ![self isLocalPath] )
            {
                NSMutableURLRequest* request = nil;
                
                NSMutableDictionary* dictionaryOfFiles = [NSMutableDictionary dictionaryWithDictionary:[[self fileAttachmentProperties] getAllPropertiesURLValues]];
                [dictionaryOfFiles removeObjectsForKeys:@[@"image.id",@"image.name",@"image.mimeType",@"image.jpegCompression"]];
                
                NSDictionary* parameters = nil;
                if( [[self propertyContainer] getBoolPropertyValue:@"parse_parameters_as_object" defaultValue:YES] )
                {
                    parameters = [[self requestParameterProperties] getAllPropertiesObjectValues];
                }
                else
                {
                    parameters = [[self requestParameterProperties] getAllPropertiesStringValues];
                }
                
                NSString* imageControlRef = [[self fileAttachmentProperties] getStringPropertyValue:@"image.id" defaultValue:nil];
                IXImage* imageControl = [[[self sandbox] getAllControlsWithID:imageControlRef] firstObject];
                
                if( [[dictionaryOfFiles allKeys] count] > 0 || imageControl.defaultImage != nil )
                {
                    request = [[self httpClient] multipartFormRequestWithMethod:[self httpMethod] path:[self objectsPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        
                        if( [imageControl isKindOfClass:[IXImage class]] )
                        {
                            NSString* attachementImageName = [[self fileAttachmentProperties] getStringPropertyValue:@"image.name"
                                                                                                        defaultValue:nil];
                            NSString* imageMimeType = [[self fileAttachmentProperties] getStringPropertyValue:@"image.mimeType"
                                                                                                 defaultValue:nil];
                            
                            NSString* imageType = [[imageMimeType componentsSeparatedByString:@"/"] lastObject];
                            
                            NSData* imageData = nil;
                            if( [imageType isEqualToString:@"png"] )
                            {
                                imageData = UIImagePNGRepresentation(imageControl.defaultImage);
                            }
                            else if( [imageType isEqualToString:@"jpeg"] )
                            {
                                float imageJPEGCompression = [[self fileAttachmentProperties] getFloatPropertyValue:@"image.jpegCompression" defaultValue:0.5f];
                                imageData = UIImageJPEGRepresentation(imageControl.defaultImage, imageJPEGCompression);
                            }
                            
                            if( imageData && [attachementImageName length] > 0 && [imageMimeType length] > 0 && [imageType length] > 0 )
                            {
                                [formData appendPartWithFileData:imageData
                                                            name:attachementImageName
                                                        fileName:[NSString stringWithFormat:@"%@.%@",attachementImageName,imageType]
                                                        mimeType:imageMimeType];
                            }
                        }
                        
                        [dictionaryOfFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            if( [obj isKindOfClass:[NSURL class]] && [obj isFileURL] )
                            {
                                [formData appendPartWithFileURL:obj name:key error:nil];
                            }
                        }];
                    }];
                }
                else
                {
                    request = [[self httpClient] requestWithMethod:[self httpMethod]
                                                              path:[self objectsPath]
                                                        parameters:parameters];
                }
                [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues]];

                __weak typeof(self) weakSelf = self;
                
                IXAFXMLRequestOperation *xmlOperation = [[IXAFXMLRequestOperation alloc] initWithRequest:request];
                [xmlOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, RXMLElement* responseObject) {
                    
                    [weakSelf setLastResponseStatusCode:[[operation response] statusCode]];
                    
                    if( [responseObject isValid] )
                    {
                        [weakSelf setRawResponse:[operation responseString]];
                        [weakSelf setLastXMLResponse:responseObject];
                        [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                    }
                    else
                    {
                        [weakSelf setLastResponseErrorMessage:[NSError errorWithDomain:@"IXXMLDataProvider : Invalid XML" code:0 userInfo:nil]];
                        [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf setLastResponseStatusCode:[[operation response] statusCode]];
                    [weakSelf setLastResponseErrorMessage:[error description]];
                    [weakSelf setRawResponse:[operation responseString]];

                    RXMLElement* responseXMLElement = [(IXAFXMLRequestOperation*)operation rXMLElement];
                    if( [responseXMLElement isValid] )
                    {
                        [weakSelf setLastXMLResponse:responseXMLElement];
                    }
                    
                    [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                }];
                
                [self authenticateAndEnqueRequestOperation:xmlOperation];
            }
            else
            {
                NSString* dataPath = [self dataLocation];
                if( ![[self dataLocation] hasSuffix:@"/"] && ![[self objectsPath] hasPrefix:@"/"] )
                {
                    if( [self objectsPath].length )
                    {
                        dataPath = [NSString stringWithFormat:@"%@/%@",[self dataLocation],[self objectsPath]];
                    }
                }
                else
                {
                    dataPath = [[self dataLocation] stringByAppendingString:[self objectsPath]];
                }
                
                __weak typeof(self) weakSelf = self;
                [[IXDataGrabber sharedDataGrabber] grabXMLFromPath:dataPath
                                                            asynch:YES
                                                       shouldCache:NO
                                                   completionBlock:^(RXMLElement* rXMLElement, NSString* stringValue, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                                            if( [rXMLElement isValid] )
                                                            {
                                                                [weakSelf setRawResponse:stringValue];
                                                                [weakSelf setLastXMLResponse:rXMLElement];
                                                                [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                                                            }
                                                            else
                                                            {
                                                                [weakSelf setLastResponseErrorMessage:[error description]];
                                                                [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                                                            }
                                                        });
                                                    }];
            }
        }
        else
        {
            IX_LOG_ERROR(@"ERROR: 'data.baseurl' of control [%@] is %@; is 'data.baseurl' defined correctly in your data_provider?", self.ID, self.dataLocation);
        }
    }
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed shouldCacheResponse:(BOOL)shouldCacheResponse
{
    [self setDataRowCount:0];
    if( loadDidSucceed )
    {
        [self setDataRowCount:[[[self lastXMLResponse] childrenWithRootXPath:[self rowBaseDataPath]] count]];
    }
    [super fireLoadFinishedEvents:loadDidSucceed shouldCacheResponse:shouldCacheResponse];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = [super getReadOnlyPropertyValue:propertyName];
    if( returnValue == nil )
    {
        if( ![[self propertyContainer] propertyExistsForPropertyNamed:propertyName] )
        {
            RXMLElement* element = [[[self lastXMLResponse] childrenWithRootXPath:propertyName] firstObject];
            returnValue = [element text];
        }
    }
    return returnValue;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath
{
    NSString* returnValue = [super rowDataForIndexPath:rowIndexPath keyPath:keyPath];
    if( keyPath && rowIndexPath && [self dataRowCount] > rowIndexPath.row )
    {
        NSInteger keyPathRow = rowIndexPath.row + 1; // +1 because xpath is not 0 based.
        NSString* rootKeyPath = [NSString stringWithFormat:@"%@[%li]%@",[self rowBaseDataPath],keyPathRow,keyPath];
        
        RXMLElement* elementForKeyPath = [[[self lastXMLResponse] childrenWithRootXPath:rootKeyPath] firstObject];
        returnValue = [elementForKeyPath text];
    }
    return returnValue;
}

-(NSUInteger)rowCount
{
    return [self dataRowCount];
}

@end
