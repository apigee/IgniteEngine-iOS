//
//  IXJSONDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXJSONDataProvider.h"

#import "AFHTTPClient.h"

#import "IXAFJSONRequestOperation.h"
#import "IXAppManager.h"
#import "IXJSONGrabber.h"
#import "IXPathHandler.h"
#import "IXLogger.h"

@interface IXJSONDataProvider ()

@property (nonatomic,assign) BOOL isLocalPath;

@property (nonatomic,strong) AFHTTPClient* httpClient;

@property (nonatomic,copy) NSString* httpMethod;
@property (nonatomic,copy) NSString* httpBody;
@property (nonatomic,copy) NSString* rowBaseDataPath;
@property (nonatomic,strong) NSArray* rowDataResults;

@property (nonatomic,strong) id lastJSONResponse;

@end

@implementation IXJSONDataProvider

-(void)applySettings
{
    [super applySettings];
 
    if( [self dataLocation] == nil )
        return;
    
    [self setRowBaseDataPath:[[self propertyContainer] getStringPropertyValue:@"datarow.basepath" defaultValue:nil]];
    [self setIsLocalPath:[IXPathHandler pathIsLocal:[self dataLocation]]];
    
    if( ![self isLocalPath] )
    {
        if( [self httpClient] == nil || ![[[[self httpClient] baseURL] absoluteString] isEqualToString:[self dataLocation]] )
        {
            [self setHttpClient:[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[self dataLocation]]]];
            [[self httpClient] setParameterEncoding:AFJSONParameterEncoding];
        }
        
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
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    if (forceGet == NO)
    {
        __weak typeof(self) weakSelf = self;
        weakSelf.lastJSONResponse = self.lastJSONResponse;
        weakSelf.lastResponseStatusCode = self.lastResponseStatusCode;
        weakSelf.lastResponseErrorMessage = self.lastResponseErrorMessage;
        [weakSelf fireLoadFinishedEvents:YES];
    }
    else
    {
        [self setRawResponse:nil];
        [self setLastJSONResponse:nil];
        [self setLastResponseStatusCode:0];
        [self setLastResponseErrorMessage:nil];
        
        if (!!self.dataLocation)
        {
            if( ![self isLocalPath] )
            {
                NSMutableURLRequest* request = [[self httpClient] requestWithMethod:[self httpMethod] path:[self objectsPath] parameters:[[self requestParameterProperties] getAllPropertiesStringValues]];
                [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues]];
                
                __weak typeof(self) weakSelf = self;
                IXAFJSONRequestOperation *operation = [IXAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    
                    [weakSelf setLastResponseStatusCode:[response statusCode]];
                    
                    NSError* __autoreleasing jsonConvertError = nil;
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
                    if( jsonConvertError == nil && jsonData )
                    {
                        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [weakSelf setRawResponse:jsonString];
                        [weakSelf setLastJSONResponse:JSON];
                        [weakSelf fireLoadFinishedEvents:YES];
                    }
                    else
                    {
                        [weakSelf setLastResponseErrorMessage:[jsonConvertError description]];
                        [weakSelf fireLoadFinishedEvents:NO];
                    }
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    
                    [weakSelf setLastResponseStatusCode:[response statusCode]];
                    [weakSelf setLastResponseErrorMessage:[error description]];
                    
                    @try {
                        NSError* __autoreleasing jsonConvertError = nil;
                        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
                        if( jsonConvertError == nil && jsonData )
                        {
                            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            [weakSelf setRawResponse:jsonString];
                            [weakSelf setLastJSONResponse:JSON];
                        }
                    }
                    @catch (NSException *exception) {
                        DDLogError(@"ERROR : %@ Exception in %@ : %@",THIS_FILE,THIS_METHOD,exception);
                    }
                    [weakSelf fireLoadFinishedEvents:NO];
                }];
                [[self httpClient] enqueueHTTPRequestOperation:operation];
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
                [[IXJSONGrabber sharedJSONGrabber] grabJSONFromPath:dataPath
                                                             asynch:YES
                                                        shouldCache:YES
                                                    completionBlock:^(id jsonObject, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                            NSError* jsonError = error;
                                                            NSData* jsonData = nil;
                                                            if( jsonObject )
                                                            {
                                                                NSError* __autoreleasing jsonConvertError = nil;
                                                                jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
                                                                if( jsonConvertError != nil )
                                                                {
                                                                    jsonError = jsonConvertError;
                                                                }
                                                            }
                                                            if( jsonData )
                                                            {
                                                                NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                [weakSelf setRawResponse:jsonString];
                                                                [weakSelf setLastJSONResponse:jsonObject];
                                                                IX_dispatch_main_sync_safe(^{
                                                                    [weakSelf fireLoadFinishedEvents:YES];
                                                                });
                                                            }
                                                            else
                                                            {
                                                                [weakSelf setLastResponseErrorMessage:[jsonError description]];
                                                                IX_dispatch_main_sync_safe(^{
                                                                    [weakSelf fireLoadFinishedEvents:NO];
                                                                });
                                                            }
                                                        });
                }];
            }
        }
        else
        {
            DDLogError(@"ERROR: 'data.baseurl' of control [%@] is %@; is 'data.baseurl' defined correctly in your data_provider?", self.ID, self.dataLocation);
        }
    }
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    [self setRowDataResults:nil];
    if( loadDidSucceed )
    {
        NSObject* jsonObject = nil;
        if( [self rowBaseDataPath].length <= 0 && [[self lastJSONResponse] isKindOfClass:[NSArray class]] )
        {
            jsonObject = [self lastJSONResponse];
        }
        else
        {
            jsonObject = [self objectForPath:[self rowBaseDataPath] container:[self lastJSONResponse]];
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
    [super fireLoadFinishedEvents:loadDidSucceed];
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
                else
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

-(NSUInteger)getRowCount
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
        else
        {
            NSError* __autoreleasing jsonConvertError = nil;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
            if( jsonConvertError == nil && jsonData )
            {
                returnValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
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
        nextNode = currentDict[currentKey];
    }
    
    if ([currentNode isKindOfClass:[NSArray class]]) {
        // current key must be an number
        @try {
            NSArray * currentArray = (NSArray *) currentNode;
            if ([currentArray count] > 0)
                nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
            else
                @throw [NSException
                        exceptionWithName:@"NSRangeException"
                        reason:@"Specified array index is out of bounds"
                        userInfo:nil];
        }
        @catch (NSException *exception) {
            DDLogError(@"ERROR : %@ Exception in %@ : %@; attempted to retrieve index %@ from %@",THIS_FILE,THIS_METHOD,exception,currentKey, jsonXPath);
        }
    }
    
    // remove the currently processed key from the xpath like path
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:kIX_EMPTY_STRING];
    if( nextXPath.length <= 0 )
    {
        return nextNode;
    }
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container: nextNode];
}

@end
