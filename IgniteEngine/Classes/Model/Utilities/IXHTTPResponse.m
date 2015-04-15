//
//  IXResponseObject.m
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXHTTPResponse.h"
#import "IXConstants.h"
#import "NSObject+IXAdditions.h"

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
        IX_LOG_DEBUG(@"Error stringifying response body. Is response object valid JSON or text? \n%@", [object description]);
    }
    _responseString = string;
}

-(void)setResponseTime
{
    
    CFTimeInterval elapsedTime = (_requestEndTime - _requestStartTime) * 1000;
    _responseTime = elapsedTime;
}
@end
