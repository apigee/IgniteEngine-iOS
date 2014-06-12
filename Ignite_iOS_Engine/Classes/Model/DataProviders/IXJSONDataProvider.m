//
//  IXJSONDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXJSONDataProvider.h"

#import "AFHTTPClient.h"
#import "AFOAuth2Client.h"

#import "IXAFJSONRequestOperation.h"
#import "IXAppManager.h"
#import "IXDataGrabber.h"
#import "IXLogger.h"

@interface IXJSONDataProvider ()

@property (nonatomic,strong) NSArray* rowDataResults;
@property (nonatomic,strong) id lastJSONResponse;

@end

@implementation IXJSONDataProvider

-(void)applySettings
{
    [super applySettings];
 
    if( [self acceptedContentType] )
    {
        [IXAFJSONRequestOperation addAcceptedContentType:[self acceptedContentType]];
    }
}

-(void)fireLoadFinishedEventsFromCachedResponse
{
    NSString* rawResponseString = [self rawResponse];
    NSData* rawResponseData = [rawResponseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* __autoreleasing error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:rawResponseData options:0 error:&error];
    if( jsonObject )
    {
        [self setLastJSONResponse:jsonObject];
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
        [self setLastJSONResponse:nil];
        [self setLastResponseStatusCode:0];
        [self setLastResponseErrorMessage:nil];
        
        if ( [self dataLocation] != nil )
        {
            if( ![self isLocalPath] )
            {
                __weak typeof(self) weakSelf = self;
                IXAFJSONRequestOperation* jsonRequestOperation = [[IXAFJSONRequestOperation alloc] initWithRequest:[self urlRequest]];
                [jsonRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [weakSelf setLastResponseStatusCode:[[operation response] statusCode]];
                    
                    if( [NSJSONSerialization isValidJSONObject:responseObject] )
                    {
                        [weakSelf setRawResponse:[operation responseString]];
                        [weakSelf setLastJSONResponse:responseObject];
                        [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                    }
                    else
                    {
                        [weakSelf setLastResponseErrorMessage:[[operation error] description]];
                        [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf setLastResponseStatusCode:[[operation response] statusCode]];
                    [weakSelf setLastResponseErrorMessage:[error description]];
                    [weakSelf setRawResponse:[operation responseString]];

                    id responseJSONObject = [(IXAFJSONRequestOperation*)operation responseJSON];
                    if( [NSJSONSerialization isValidJSONObject:responseJSONObject] )
                    {
                        [weakSelf setLastJSONResponse:responseJSONObject];
                    }

                    [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                }];
                
                [self authenticateAndEnqueRequestOperation:jsonRequestOperation];
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
                [[IXDataGrabber sharedDataGrabber] grabJSONFromPath:dataPath
                                                             asynch:YES
                                                        shouldCache:NO
                                                    completionBlock:^(id jsonObject, NSString* stringValue, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                                                            
                                                            
                                                            if( [NSJSONSerialization isValidJSONObject:jsonObject] )
                                                            {
                                                                [weakSelf setRawResponse:stringValue];
                                                                [weakSelf setLastJSONResponse:jsonObject];
                                                                IX_dispatch_main_sync_safe(^{
                                                                    [weakSelf fireLoadFinishedEvents:YES shouldCacheResponse:YES];
                                                                });
                                                            }
                                                            else
                                                            {
                                                                [weakSelf setLastResponseErrorMessage:[error description]];
                                                                IX_dispatch_main_sync_safe(^{
                                                                    [weakSelf fireLoadFinishedEvents:NO shouldCacheResponse:NO];
                                                                });
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
    [self setRowDataResults:nil];
    if( loadDidSucceed )
    {
        NSObject* jsonObject = nil;
        if( [self dataRowBasePath].length <= 0 && [[self lastJSONResponse] isKindOfClass:[NSArray class]] )
        {
            jsonObject = [self lastJSONResponse];
        }
        else
        {
            jsonObject = [self objectForPath:[self dataRowBasePath] container:[self lastJSONResponse]];
        }

        NSArray* rowDataResults = nil;
        if( [jsonObject isKindOfClass:[NSArray class]] )
        {
            rowDataResults = (NSArray*)jsonObject;
        }
        if( rowDataResults )
        {
            NSPredicate* predicate = [self predicate];
            if( predicate )
            {
                rowDataResults = [rowDataResults filteredArrayUsingPredicate:predicate];
            }
            NSSortDescriptor* sortDescriptor = [self sortDescriptor];
            if( sortDescriptor )
            {
                rowDataResults = [rowDataResults sortedArrayUsingDescriptors:@[sortDescriptor]];
            }
            [self setRowDataResults:rowDataResults];
        }
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
            NSObject* jsonObject = [self objectForPath:propertyName container:[self lastJSONResponse]];
            if( jsonObject )
            {
                if( [jsonObject isKindOfClass:[NSString class]] )
                {
                    returnValue = (NSString*)jsonObject;
                }
                else if( [jsonObject isKindOfClass:[NSNumber class]] )
                {
                    returnValue = [(NSNumber*)jsonObject stringValue];
                }
                else if( [NSJSONSerialization isValidJSONObject:jsonObject] )
                {
                    NSError* __autoreleasing jsonConvertError = nil;
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
                    if( jsonConvertError == nil && jsonData )
                    {
                        returnValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    }
                }
            }
        }
    }
    return returnValue;
}

-(NSString*)rowDataRawJSONResponse
{
    NSString* returnValue = nil;
    if( [[self rowDataResults] count] > 0 )
    {
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self rowDataResults]
                                                           options:0
                                                             error:&error];
        if( [jsonData length] > 0 && error == nil )
        {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            returnValue = jsonString;
        }
    }
    return returnValue;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath
{
    NSString* returnValue = [super rowDataForIndexPath:rowIndexPath keyPath:keyPath];
    if( keyPath && rowIndexPath )
    {
        NSString* jsonKeyPath = [NSString stringWithFormat:@"%li.%@",(long)rowIndexPath.row,keyPath];
        returnValue = [self stringForPath:jsonKeyPath container:[self rowDataResults]];
    }
    return returnValue;
}

-(NSUInteger)rowCount
{
    return [[self rowDataResults] count];
}

-(NSString*)stringForPath:(NSString*)jsonXPath container:(NSObject*)container
{
    NSString* returnValue = nil;
    NSObject* jsonObject = [self objectForPath:jsonXPath container:container];
    if( jsonObject )
    {
        if( [jsonObject isKindOfClass:[NSString class]] )
        {
            returnValue = (NSString*)jsonObject;
        }
        else if( [jsonObject isKindOfClass:[NSNumber class]] )
        {
            returnValue = [((NSNumber*)jsonObject) stringValue];
        }
        else if( [jsonObject isKindOfClass:[NSNull class]] )
        {
            returnValue = nil;
        }
        else
        {
            NSError* __autoreleasing jsonConvertError = nil;
            if( [NSJSONSerialization isValidJSONObject:jsonObject] )
            {
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&jsonConvertError];
                if( jsonConvertError == nil && jsonData )
                {
                    returnValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                else
                {
                    IX_LOG_WARN(@"WARNING from %@ in %@ : Error Converting JSON object : %@",THIS_FILE,THIS_METHOD,[jsonConvertError description]);
                }
            }
            else
            {
                IX_LOG_WARN(@"WARNING from %@ in %@ : Invalid JSON Object : %@",THIS_FILE,THIS_METHOD,[jsonObject description]);
            }
        }
    }
    return returnValue;
}

- (NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*) currentNode
{
    if (currentNode == nil) {
        return nil;
    }
    
    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
        return currentNode;
    }
    if ([jsonXPath hasPrefix:kIX_PERIOD_SEPERATOR]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:kIX_PERIOD_SEPERATOR] firstObject];
    NSObject *nextNode;
    // if dict -> get value
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = currentDict[jsonXPath];
        if( nextNode != nil )
        {
            return nextNode;
        }
        else
        {
            nextNode = currentDict[currentKey];
        }
    }
    
    if ([currentNode isKindOfClass:[NSArray class]]) {
        // current key must be an number
        NSArray * currentArray = (NSArray *) currentNode;
        @try {
            if( [currentKey isEqualToString:@"$count"] || [currentKey isEqualToString:@".$count"] )
            {
                return [NSString stringWithFormat:@"%lu",(unsigned long)[currentArray count]];
            }
            else if ([currentArray count] > 0)
            {
                nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
            }
            else
            {
                @throw [NSException exceptionWithName:@"NSRangeException"
                                               reason:@"Specified array index is out of bounds"
                                             userInfo:nil];
            }
        }
        @catch (NSException *exception) {
            IX_LOG_ERROR(@"ERROR : %@ Exception in %@ : %@; attempted to retrieve index %@ from %@",THIS_FILE,THIS_METHOD,exception,currentKey, jsonXPath);
        }
    }
    
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:kIX_EMPTY_STRING];
    if( nextXPath.length <= 0 )
    {
        return nextNode;
    }
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container: nextNode];
}

@end
