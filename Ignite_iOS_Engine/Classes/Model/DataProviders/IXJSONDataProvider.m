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

@interface IXJSONDataProvider ()

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
    [self setRowBaseDataPath:[[self propertyContainer] getStringPropertyValue:@"row_data_base_path" defaultValue:nil]];
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
    
    [self setRawResponse:nil];
    [self setLastJSONResponse:nil];
    [self setLastResponseStatusCode:0];
    [self setLastResponseErrorMessage:nil];
    
    NSMutableURLRequest* request = [[self httpClient] requestWithMethod:[self httpMethod] path:[self objectsPath] parameters:[[self requestParameterProperties] getAllPropertiesStringValues]];
    [request setAllHTTPHeaderFields:[[self requestHeaderProperties] getAllPropertiesStringValues]];
    
    __weak typeof(self) weakSelf = self;
    IXAFJSONRequestOperation *operation = [IXAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [weakSelf setLastResponseStatusCode:[response statusCode]];
        
        NSError* jsonConvertError = nil;
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
            [self setLastResponseErrorMessage:[jsonConvertError description]];
            [weakSelf fireLoadFinishedEvents:NO];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {        

        [weakSelf setLastResponseStatusCode:[response statusCode]];
        [weakSelf setLastResponseErrorMessage:[error description]];
        
        NSError* jsonConvertError = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&jsonConvertError];
        if( jsonConvertError == nil && jsonData )
        {
            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [weakSelf setRawResponse:jsonString];
            [weakSelf setLastJSONResponse:JSON];
        }
        [weakSelf fireLoadFinishedEvents:NO];
    }];
    [[self httpClient] enqueueHTTPRequestOperation:operation];
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    [self setRowDataResults:nil];
    if( loadDidSucceed )
    {
        NSObject* jsonObject = [self objectForPath:[self rowBaseDataPath] container:[self lastJSONResponse]];
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
                    NSError* jsonConvertError = nil;
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

-(NSInteger)getRowCount
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
            NSError* jsonConvertError = nil;
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
    if ([jsonXPath hasPrefix:@"."]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:@"."] firstObject];
    NSObject *nextNode;
    // if dict -> get value
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = [currentDict objectForKey:currentKey];
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
        @catch (NSException *e) {
            NSLog(@"%@; attempted to retrieve index %@ from %@", e, currentKey, jsonXPath);
        }
    }
    
    // remove the currently processed key from the xpath like path
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:@""];    
    if( nextXPath == nil || [nextXPath isEqualToString:@""] )
    {
        return nextNode;
    }
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container: nextNode];
}

@end
