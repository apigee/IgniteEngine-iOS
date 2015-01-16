//
//  IXXMLDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/3/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXXMLDataProvider.h"

#import "IXAFXMLRequestOperation.h"
#import "IXDataGrabber.h"

#import "RXMLElement.h"

@interface IXXMLDataProvider ()

@property (nonatomic,strong) RXMLElement* lastXMLResponse;

@end

@implementation IXXMLDataProvider

-(void)applySettings
{
    [super applySettings];
    
    if( [self dataBaseURL] == nil )
        return;
    
    if( [self acceptedContentType] )
    {
        [IXAFXMLRequestOperation addAcceptedContentType:[self acceptedContentType]];
    }
}

-(void)fireLoadFinishedEventsFromCachedResponse
{
    RXMLElement* xmlElement = [RXMLElement elementFromXMLString:[self responseRawString] encoding:NSUTF8StringEncoding];
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
        [self setResponseRawString:nil];
        [self setLastXMLResponse:nil];
        [self setResponseStatusCode:0];
        [self setResponseErrorMessage:nil];
        
        if ( [self dataBaseURL] != nil )
        {
            if( ![self isPathLocal] )
            {
                __weak typeof(self) weakSelf = self;
                IXAFXMLRequestOperation *xmlOperation = [[IXAFXMLRequestOperation alloc] initWithRequest:[self createURLRequest]];
                [xmlOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, RXMLElement* responseObject) {
                    
                    [weakSelf setResponseStatusCode:[[operation response] statusCode]];
                    
                    if( [responseObject isValid] )
                    {
                        [weakSelf setResponseRawString:[operation responseString]];
                        [weakSelf setLastXMLResponse:responseObject];
                        [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                    }
                    else
                    {
                        [weakSelf setResponseErrorMessage:@"IXXMLDataProvider : Invalid XML"];
                        [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf setResponseStatusCode:[[operation response] statusCode]];
                    [weakSelf setResponseErrorMessage:[error description]];
                    [weakSelf setResponseRawString:[operation responseString]];

                    RXMLElement* responseXMLElement = [(IXAFXMLRequestOperation*)operation rXMLElement];
                    if( [responseXMLElement isValid] )
                    {
                        [weakSelf setLastXMLResponse:responseXMLElement];
                    }
                    
                    [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                }];
                
                [[self httpClient] enqueueHTTPRequestOperation:xmlOperation];
            }
            else
            {
                __weak typeof(self) weakSelf = self;
                [[IXDataGrabber sharedDataGrabber] grabXMLFromPath:[self fullDataLocation]
                                                            asynch:YES
                                                       shouldCache:NO
                                                   completionBlock:^(RXMLElement* rXMLElement, NSString* stringValue, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                                            if( [rXMLElement isValid] )
                                                            {
                                                                [weakSelf setResponseRawString:stringValue];
                                                                [weakSelf setLastXMLResponse:rXMLElement];
                                                                [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                                                            }
                                                            else
                                                            {
                                                                [weakSelf setResponseErrorMessage:[error description]];
                                                                [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                                                            }
                                                        });
                                                    }];
            }
        }
        else
        {
            IX_LOG_ERROR(@"ERROR: 'data.baseurl' of control [%@] is %@; is 'data.baseurl' defined correctly in your data_provider?", self.ID, self.dataBaseURL);
        }
    }
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

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath dataRowBasePath:(NSString *)dataRowBasePath
{
    if( [dataRowBasePath length] <= 0 )
    {
        dataRowBasePath = [self dataRowBasePath];
    }

    NSString* returnValue = [super rowDataForIndexPath:rowIndexPath keyPath:keyPath dataRowBasePath:dataRowBasePath];
    if( keyPath && rowIndexPath && [[[self lastXMLResponse] childrenWithRootXPath:dataRowBasePath] count] > rowIndexPath.row )
    {
        NSString* rowXPath = keyPath;
        if( ![rowXPath hasPrefix:@"/"] )
        {
            rowXPath = [@"/" stringByAppendingString:keyPath];
        }
        
        NSInteger xPathRow = rowIndexPath.row + 1; // +1 because xpath is not 0 based.
        NSString* rootXPath = [NSString stringWithFormat:@"%@[%li]%@",dataRowBasePath,(long)xPathRow,rowXPath];
        
        RXMLElement* elementForKeyPath = [[[self lastXMLResponse] childrenWithRootXPath:rootXPath] firstObject];
        returnValue = [elementForKeyPath text];
    }
    return returnValue;
}

-(NSUInteger)rowCount:(NSString *)dataRowBasePath
{
    if( [dataRowBasePath length] <= 0 )
    {
        dataRowBasePath = [self dataRowBasePath];
    }

    return [[[self lastXMLResponse] childrenWithRootXPath:dataRowBasePath] count];
}

@end
