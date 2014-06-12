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

@property (nonatomic,assign) BOOL isLocalPath;

@property (nonatomic,assign) NSUInteger dataRowCount;
@property (nonatomic,strong) RXMLElement* lastXMLResponse;

@end

@implementation IXXMLDataProvider

-(void)applySettings
{
    [super applySettings];
    
    if( [self dataLocation] == nil )
        return;
    
    if( [self acceptedContentType] )
    {
        [IXAFXMLRequestOperation addAcceptedContentType:[self acceptedContentType]];
    }
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
                __weak typeof(self) weakSelf = self;
                IXAFXMLRequestOperation *xmlOperation = [[IXAFXMLRequestOperation alloc] initWithRequest:[self urlRequest]];
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
                if( ![[self dataLocation] hasSuffix:@"/"] && ![[self dataPath] hasPrefix:@"/"] )
                {
                    if( [self dataPath].length )
                    {
                        dataPath = [NSString stringWithFormat:@"%@/%@",[self dataLocation],[self dataPath]];
                    }
                }
                else
                {
                    dataPath = [[self dataLocation] stringByAppendingString:[self dataPath]];
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
        [self setDataRowCount:[[[self lastXMLResponse] childrenWithRootXPath:[self dataRowBasePath]] count]];
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
        NSString* rowXPath = keyPath;
        if( ![rowXPath hasPrefix:@"/"] )
        {
            rowXPath = [@"/" stringByAppendingString:keyPath];
        }
        
        NSInteger xPathRow = rowIndexPath.row + 1; // +1 because xpath is not 0 based.
        NSString* rootXPath = [NSString stringWithFormat:@"%@[%li]%@",[self dataRowBasePath],xPathRow,rowXPath];
        
        RXMLElement* elementForKeyPath = [[[self lastXMLResponse] childrenWithRootXPath:rootXPath] firstObject];
        returnValue = [elementForKeyPath text];
    }
    return returnValue;
}

-(NSUInteger)rowCount
{
    return [self dataRowCount];
}

@end
