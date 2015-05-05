//
//  IXAFNetworkActivityLogger.m
//  Ignite Engine
//
//  Created by Robert Walsh on 9/30/14.
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

#import "IXAFNetworkActivityLogger.h"
#import "AFHTTPRequestOperation.h"
#import <objc/runtime.h>

@interface AFNetworkActivityLogger ()
- (void)HTTPOperationDidStart:(NSNotification *)notification;
@end

@implementation IXAFNetworkActivityLogger

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
