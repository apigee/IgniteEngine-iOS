//
//  IXDataGrabber.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXDataGrabber.h"

#import "IXAppManager.h"
#import "IXAFJSONRequestOperation.h"
#import "IXAFXMLRequestOperation.h"
#import "IXPathHandler.h"
#import "IXLogger.h"

#import "RXMLElement.h"

@interface IXDataGrabber ()

@property (nonatomic,strong) NSCache* grabCache;

@end

@implementation IXDataGrabber

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

+(IXDataGrabber*)sharedDataGrabber
{
    static IXDataGrabber *sharedJSONGrabber = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJSONGrabber = [[IXDataGrabber alloc] init];
    });
    return sharedJSONGrabber;
}

-(void)grabXMLFromPath:(NSString*)path
                asynch:(BOOL)asynch
           shouldCache:(BOOL)shouldCache
       completionBlock:(IXXMLGrabCompletedBlock)grabCompletionBlock;
{
    if( [path length] <= 0 )
    {
        grabCompletionBlock(nil,nil,[NSError errorWithDomain:@"Path Parameter is nil" code:0 userInfo:nil]);
        return;
    }
    else
    {
        path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSData* cachedObject = [[self grabCache] objectForKey:path];
        if( [cachedObject isKindOfClass:[NSData class]] )
        {
            RXMLElement* rXMLElement = [RXMLElement elementFromXMLData:cachedObject];
            NSString *xmlString = [[NSString alloc] initWithData:cachedObject encoding:NSUTF8StringEncoding];
            if( grabCompletionBlock ) {
                grabCompletionBlock(rXMLElement,xmlString,nil);
            }
        }
        else
        {
            NSURL* url = nil;
            if( [IXPathHandler pathIsLocal:path] )
            {
                url = [NSURL fileURLWithPath:path];
            }
            else
            {
                url = [NSURL URLWithString:path];
            }
            
            if( asynch )
            {
                __weak typeof(self) weakSelf = self;
                IXAFXMLRequestOperation* xmlRequestOperation = [[IXAFXMLRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
                [xmlRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, RXMLElement* responseObject) {
                    
                    if( [responseObject isValid] )
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
                    else if( grabCompletionBlock )
                    {
                        grabCompletionBlock(nil,[operation responseString],[NSError errorWithDomain:@"IXDataGrabber Invalid XML." code:0 userInfo:nil]);
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    if( grabCompletionBlock ) {
                        grabCompletionBlock(nil,[operation responseString],error);
                    }
                    
                }];
                
                [xmlRequestOperation start];
            }
            else
            {
                NSData* xmlData = [NSData dataWithContentsOfURL:url];
                if( xmlData == nil )
                {
                    grabCompletionBlock(nil,nil,[NSError errorWithDomain:@"No Data found at XML path" code:0 userInfo:nil]);
                }
                else
                {
                    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
                    RXMLElement* rXMLElement = [RXMLElement elementFromXMLData:xmlData];
                    if( [rXMLElement isValid] )
                    {
                        __weak typeof(self) weakSelf = self;
                        if( shouldCache )
                        {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[weakSelf grabCache] setObject:xmlData forKey:path];
                            });
                        }
                        grabCompletionBlock(rXMLElement,xmlString,nil);
                    }
                    else
                    {
                        grabCompletionBlock(nil,xmlString,[NSError errorWithDomain:@"IXDataGrabber Invalid XML." code:0 userInfo:nil]);
                    }
                }
            }
        }
    }
}

-(void)grabJSONFromPath:(NSString*)path
                 asynch:(BOOL)asynch
            shouldCache:(BOOL)shouldCache
        completionBlock:(IXJSONGrabCompletedBlock)grabCompletionBlock
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
            NSURL* url = nil;
            if( [IXPathHandler pathIsLocal:path] )
            {
                url = [NSURL fileURLWithPath:path];
            }
            else
            {
                url = [NSURL URLWithString:path];
            }
            
            if( asynch )
            {
                __weak typeof(self) weakSelf = self;
                IXAFJSONRequestOperation* jsonRequestOperation = [[IXAFJSONRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
                [jsonRequestOperation setJSONReadingOptions:NSJSONReadingMutableContainers];
                [jsonRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
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
                            grabCompletionBlock(nil,[operation responseString],[(IXAFJSONRequestOperation*)operation error]);
                        }
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    if( grabCompletionBlock ) {
                        grabCompletionBlock(nil,[operation responseString],error);
                    }
                    
                }];
                
                [jsonRequestOperation start];
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
                            grabCompletionBlock(jsonObject,jsonString,nil);
                        }
                    }
                    else
                    {
                        if( grabCompletionBlock ) {
                            grabCompletionBlock(nil,jsonString,error);
                        }
                    }
                }
            }
        }
    }
}

+(void)clearCache
{
    [[[IXDataGrabber sharedDataGrabber] grabCache] removeAllObjects];
}

@end
