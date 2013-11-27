//
//  IXJSONGrabber.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXJSONGrabber.h"

#import "IXAppManager.h"
#import "IXAFJSONRequestOperation.h"

@interface IXJSONGrabber ()

@property (nonatomic,strong) NSCache* jsonCache;

@end

@implementation IXJSONGrabber

-(id)init
{
    self = [super init];
    if( self )
    {
        _jsonCache = [[NSCache alloc] init];
        [_jsonCache setName:@"com.ignite.JSONCache"];
    }
    return self;
}

+(IXJSONGrabber*)sharedJSONGrabber
{
    static IXJSONGrabber *sharedJSONGrabber = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJSONGrabber = [[IXJSONGrabber alloc] init];
    });
    return sharedJSONGrabber;
}

-(void)grabJSONFromPath:(NSString*)path
                 asynch:(BOOL)asynch
        completionBlock:(IXJSONGrabCompletedBlock)grabCompletionBlock
{
    if( [path length] <= 0 )
    {
        grabCompletionBlock(nil,[NSError errorWithDomain:@"Path Parameter is nil" code:0 userInfo:nil]);
        return;
    }
    
    id jsonObject = [[self jsonCache] objectForKey:path];
    if( jsonObject )
    {
        grabCompletionBlock(jsonObject,nil);
    }
    else
    {
        NSURL* url = nil;
        if( [IXAppManager pathIsLocal:path] )
        {
            url = [NSURL fileURLWithPath:path];
        }
        else
        {
            url = [NSURL URLWithString:path];
        }
        
        if( asynch )
        {            
            IXAFJSONRequestOperation *operation = [IXAFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[self jsonCache] setObject:JSON forKey:path];
                });
                grabCompletionBlock(JSON,nil);
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                grabCompletionBlock(nil,error);
            }];
            
            [operation start];
        }
        else
        {
            NSData* jsonData = [NSData dataWithContentsOfURL:url];
            NSError* error = nil;
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            
            if( jsonObject )
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[self jsonCache] setObject:jsonObject forKey:path];
                });
                grabCompletionBlock(jsonObject,nil);
            }
            else
            {
                grabCompletionBlock(nil,error);
            }            
        }
    }
}

@end
