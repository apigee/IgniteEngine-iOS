//
//  IXResponseObject.m
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
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

#import "IXHTTPResponse.h"
#import "IXConstants.h"
#import "NSObject+IXAdditions.h"
#import "IXAttributeContainer.h"
#import "IXAppManager.h"
#import "IXJSONUtils.h"

@implementation IXHTTPResponse

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        [self setRequestStartTime:CFAbsoluteTimeGetCurrent()];
    }
    return self;
}

-(void)setResponseStringFromObject:(NSObject*)object
{
    NSString* string = nil;
    @try {
        if ([object isKindOfClass:[NSDictionary class]]) {
            string = [object jsonStringWithPrettyPrint:YES];
        } else if ([object isKindOfClass:[NSData class]]) {
            string = [[NSString alloc] initWithData:(NSData*)object encoding:NSUTF8StringEncoding];
        }
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"Error stringifying response body. Is response object valid JSON or text? \n%@\nException: %@", [object description], exception);
    }
    _responseString = string;
}

-(void)setResponseTime
{
    
    CFTimeInterval elapsedTime = (_requestEndTime - _requestStartTime) * 1000;
    _responseTime = elapsedTime;
}



@end
