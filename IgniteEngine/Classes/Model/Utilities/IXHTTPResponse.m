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
        }
    }
    @catch (NSException *exception) {
        IX_LOG_DEBUG(@"Error stringifying response body to JSON string. Is response object valid JSON? \n%@", [object description]);
    }
    _responseString = string;
}

-(void)setResponseTime
{
    
    CFTimeInterval elapsedTime = (_requestEndTime - _requestStartTime) * 1000;
    _responseTime = elapsedTime;
}
@end
