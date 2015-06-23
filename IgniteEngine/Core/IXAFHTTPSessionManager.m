//
//  IXAFHTTPRequestOperation.m
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
