//
//  IXAFXMLRequestOperation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 6/3/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXAFXMLRequestOperation.h"

#import "RXMLElement.h"

static NSMutableSet* sXMLAcceptedContentTypes;

static dispatch_queue_t ix_rapture_xml_request_operation_processing_queue() {
    static dispatch_queue_t af_xml_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_xml_request_operation_processing_queue = dispatch_queue_create("com.ignite.networking.rapture.xml-request.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return af_xml_request_operation_processing_queue;
}

@interface IXAFXMLRequestOperation ()
@property (readwrite, nonatomic, strong) RXMLElement* rXMLElement;
@end

@implementation IXAFXMLRequestOperation

+(void)load
{
    sXMLAcceptedContentTypes = [NSMutableSet setWithObjects:@"application/xml", @"text/xml", nil];
}

+(void)addAcceptedContentType:(NSString*)contentType
{
    if( [contentType length] > 0 && ![sXMLAcceptedContentTypes containsObject:contentType] )
    {
        [sXMLAcceptedContentTypes addObject:contentType];
    }
}

+ (NSSet *)acceptableContentTypes
{
    return sXMLAcceptedContentTypes;
}

+ (instancetype)RXMLElementRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *rXMLElement))success
                                               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *rXMLElement))failure
{
    IXAFXMLRequestOperation *requestOperation = [[[self class] alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(IXAFXMLRequestOperation *)operation rXMLElement]);
        }
    }];
    
    return requestOperation;
}

-(RXMLElement *)rXMLElement
{
    if (!_rXMLElement && [self.responseData length] > 0 && [self isFinished]) {
        self.rXMLElement = [RXMLElement elementFromXMLData:[self responseData]];
    }
    return _rXMLElement;
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
    self.completionBlock = ^ {
        dispatch_async(ix_rapture_xml_request_operation_processing_queue(), ^(void) {
            RXMLElement *rXMLElement = self.rXMLElement;
            
            if (self.error) {
                if (failure) {
                    dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                        failure(self, self.error);
                    });
                }
            } else {
                if (success) {
                    dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                        success(self, rXMLElement);
                    });
                }
            }
        });
    };
#pragma clang diagnostic pop
}

@end
