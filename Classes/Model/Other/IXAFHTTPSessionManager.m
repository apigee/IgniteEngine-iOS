//
//  IXAFHTTPRequestOperation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXAFHTTPSessionManager.h"

//static NSMutableSet* sJSONAcceptedContentTypes;

@implementation IXAFHTTPSessionManager

+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// This wraps the completion handler with a shim that injects the responseObject into the error.
/*- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))originalCompletionHandler {
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        
                        // If there's an error, store the response in it if we've got one.
                        if (error && responseObject) {
                            if (error.userInfo) {  // Already has a dictionary, so we need to add to it.
                                NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                                userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] = responseObject;
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:[userInfo copy]];
                            } else {  // No dictionary, make a new one.
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:@{AFNetworkingOperationFailingURLResponseDataErrorKey: responseObject}];
                            }
                        }
                        
                        // Call the original handler.
                        if (originalCompletionHandler) {
                            originalCompletionHandler(response, responseObject, error);
                        }
                    }];
}*/

@end
