//
//  IXAFXMLRequestOperation.h
//  Ignite Engine
//
//  Created by Robert Walsh on 6/3/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@class RXMLElement;

@interface IXAFXMLRequestOperation : AFHTTPRequestOperation

@property (nonatomic,strong,readonly) RXMLElement* rXMLElement;

+ (instancetype)RXMLElementRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *rXMLElement))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *rXMLElement))failure;

+ (void)addAcceptedContentType:(NSString*)contentType;;

@end
