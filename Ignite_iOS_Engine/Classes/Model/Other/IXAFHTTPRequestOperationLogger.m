//
//  IXAFHTTPRequestOperationLogger.m
//  Ignite Engine
//
//  Created by Robert Walsh on 9/30/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXAFHTTPRequestOperationLogger.h"
#import "AFHTTPRequestOperation.h"
#import <objc/runtime.h>

@interface AFHTTPRequestOperationLogger ()
- (void)HTTPOperationDidStart:(NSNotification *)notification;
@end

@implementation IXAFHTTPRequestOperationLogger

- (void)HTTPOperationDidStart:(NSNotification *)notification {

    [super HTTPOperationDidStart:notification];

    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];

    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }

    __block NSString *headersString = nil;

    switch (self.level) {
        case AFLoggerLevelDebug: {

            // <CURL Logging>
            [[operation.request allHTTPHeaderFields] enumerateKeysAndObjectsUsingBlock:^(NSString* headersStringKey, id headersStringValue, BOOL *stop) {

                if ([headersStringKey length] != 0) {

                    NSString* headersStringKeypair = [NSString stringWithFormat:@"-H \"%@: %@\"", headersStringKey, headersStringValue];

                    if ([headersStringKeypair length] != 0) {
                        if ([headersString length] == 0) {
                            headersString = headersStringKeypair;
                        } else {
                            headersString = [NSString stringWithFormat:@"%@%@", headersString, headersStringKeypair];
                        }
                    }
                }
            }];

            NSString *curlString = [NSString stringWithFormat:@"curl -X %@ '%@' ", [operation.request HTTPMethod], [[operation.request URL] absoluteString]];

            if ([headersString length] > 0) {
                curlString = [NSString stringWithFormat:@"%@%@", curlString, headersString];
            }

            if ([operation.request HTTPBody]) {
                NSString *body = [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSUTF8StringEncoding];
                curlString = [NSString stringWithFormat:@"%@ -d \"%@\"", curlString, body];
            }

            NSLog(@"%@", curlString);
            break;
        }
        default:
            break;
    }
}

@end
