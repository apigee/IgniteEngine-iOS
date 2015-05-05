//
//  IXDataLoader.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
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

#import "IXDataLoader.h"
#import "IXAppManager.h"
#import "AFNetworking.h"
#import "IXPathHandler.h"
#import "IXLogger.h"

@interface IXDataLoader ()

@property (nonatomic,strong) NSCache* grabCache;

@end

@implementation IXDataLoader

-(id)init
{
    self = [super init];
    if( self )
    {
        _grabCache = [[NSCache alloc] init];
        [_grabCache setName:@"com.ignite.IXDataGrabberCache"];
    }
    return self;
}

+(IXDataLoader*)sharedDataLoader
{
    static IXDataLoader *sharedJSONLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJSONLoader = [[IXDataLoader alloc] init];
    });
    return sharedJSONLoader;
}

-(void)loadJSONFromPath:(NSString*)path
                 async:(BOOL)async
            shouldCache:(BOOL)shouldCache
        completion:(IXJSONGrabCompletedBlock)grabCompletionBlock
{
    if( [path length] <= 0 )
    {
        if( grabCompletionBlock ) {
            grabCompletionBlock(nil,nil,[NSError errorWithDomain:@"Path Parameter is nil" code:0 userInfo:nil]);
        }
    }
    else
    {
        path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        id jsonObject = [[self grabCache] objectForKey:path];
        if( [NSJSONSerialization isValidJSONObject:jsonObject] )
        {
            NSError* __autoreleasing error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                               options:0
                                                                 error:&error];
            if( [jsonData length] > 0 && error == nil )
            {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if( grabCompletionBlock ) {
                    grabCompletionBlock(jsonObject,jsonString,nil);
                }
            }
        }
        else
        {
            NSURL* url = ( [IXPathHandler pathIsLocal:path] ) ? [NSURL fileURLWithPath:path] : [NSURL URLWithString:path];
            
            if( async )
            {
                __weak typeof(self) weakSelf = self;
                __block NSString* responseString;
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                operation.responseSerializer = [AFJSONResponseSerializer serializer];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    responseString = operation.responseString;
                    if( [NSJSONSerialization isValidJSONObject:responseObject] )
                    {
                        if( shouldCache )
                        {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[weakSelf grabCache] setObject:[operation responseData] forKey:path];
                            });
                        }
                        
                        if( grabCompletionBlock ) {
                            grabCompletionBlock(responseObject,[operation responseString],nil);
                        }
                    }
                    else
                    {
                        if( grabCompletionBlock ) {
                            grabCompletionBlock(nil, responseString, [(AFHTTPRequestOperation*)operation error]);
                        }
                    }
                } failure:^(AFHTTPRequestOperation *request, NSError *error){
                    responseString = operation.responseString;
                    if( grabCompletionBlock ) {
                        grabCompletionBlock(nil, responseString, error);
                    }
                }];
                [operation start];
            }
            else
            {
                NSData* jsonData = [NSData dataWithContentsOfURL:url];
                if( jsonData == nil )
                {
                    grabCompletionBlock(nil,nil,[NSError errorWithDomain:@"No Data found at JSON path" code:0 userInfo:nil]);
                }
                else
                {
                    NSString *jsonString = nil;
                    if( [jsonData length] > 0 )
                    {
                        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    }
                    
                    NSError* __autoreleasing error = nil;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                    if( [NSJSONSerialization isValidJSONObject:jsonObject] && error == nil )
                    {
                        if( shouldCache )
                        {
                            __weak typeof(self) weakSelf = self;
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[weakSelf grabCache] setObject:jsonData forKey:path];
                            });
                        }
                        
                        if( grabCompletionBlock ) {
                            grabCompletionBlock(jsonObject, jsonString, nil);
                        }
                    }
                    else
                    {
                        if( grabCompletionBlock ) {
                            grabCompletionBlock(nil, jsonString, error);
                        }
                    }
                }
            }
        }
    }
}

+(void)clearCache
{
    [[[IXDataLoader sharedDataLoader] grabCache] removeAllObjects];
}

@end
