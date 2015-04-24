//
//  NSURL+IXAdditions.m
//  Ignite Engine
//
//  Created by Robert Walsh on 11/23/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "NSURL+IXAdditions.h"

@implementation NSURL (IXAdditions)

-(NSDictionary*)ix_parseQueryStringToParamsDict
{
    NSMutableDictionary* queryParmasDict = nil;
    if( [[self query] length] > 0 ) {
        queryParmasDict = [NSMutableDictionary dictionary];
        NSArray *pairs = [[self query] componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if( [elements count] > 1 )
            {
                NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [queryParmasDict setObject:val forKey:key];
            }
        }
    }
    return queryParmasDict;
}

@end
