//
//  IXAFHTTPRequestOperation.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXAFHTTPRequestOperation.h"

static NSMutableSet* sJSONAcceptedContentTypes;

@implementation IXAFHTTPRequestOperation

+(void)load
{
    sJSONAcceptedContentTypes = [[NSMutableSet alloc] initWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
}

+(void)addAcceptedContentType:(NSString*)contentType
{
    if( [contentType length] > 0 && ![sJSONAcceptedContentTypes containsObject:contentType] )
    {
        [sJSONAcceptedContentTypes addObject:contentType];
    }
}

+ (NSSet *)acceptableContentTypes
{
    return sJSONAcceptedContentTypes;
}

@end
