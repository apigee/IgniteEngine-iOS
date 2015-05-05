
//
//  NSDictionary+IXAdditions.m
//  IgniteEngine
//
//  Created by Brandon on 4/9/15.
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

#import "NSDictionary+IXAdditions.h"
#import "NSString+IXAdditions.h"

static NSString *urlEncode(id object) {
    NSString *string = [NSString stringWithFormat: @"%@", object];
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@implementation NSDictionary (IXAdditions)

+(NSDictionary*)ix_dictionaryFromQueryParamsString:(NSString *)string
{
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSString *qs in [string componentsSeparatedByString:@"&"]) {
        // Get the parameter name
        NSString *key = [[qs componentsSeparatedByString:@"="] objectAtIndex:0];
        // Get the parameter value
        NSString *value = [[qs componentsSeparatedByString:@"="] objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        queryStrings[key] = value;
    }
    return queryStrings;
}

+(NSDictionary*)ix_dictionaryWithParsedValuesFromDictionary:(NSDictionary *)dictionary {
    return [self deriveValueTypesRecursivelyForObject:(NSMutableDictionary*)[dictionary mutableCopy]];
}

// internal helpers

+(id)deriveValueTypesRecursivelyForObject:(id)object {
    id returnObject = [object mutableCopy];
    if ([object isKindOfClass:[NSDictionary class]]) {
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id child, BOOL *stop) {
            [returnObject setObject:[self deriveValueTypesRecursivelyForObject:child] forKey:key];
        }];
    } else if ([object isKindOfClass:[NSArray class]]) {
        [[object allKeys] enumerateObjectsUsingBlock:^(id child, NSUInteger idx, BOOL *stop) {
            [returnObject setObject:[self deriveValueTypesRecursivelyForObject:child] atIndex:idx];
        }];
    } else {
        //This object is not a container you might be interested in it's value
        if ([object isKindOfClass:[NSString class]]) {
            @try {
                if ([object isNumeric]) {
                    returnObject = [NSDecimalNumber decimalNumberWithString:object];
                } else if ([object isBOOL]) {
                    returnObject = [NSNumber numberWithBool:[object boolValue]];
                }
            }
            @catch (NSException *exception) {
                
            }
        }
    }
    return returnObject;
}

+(NSString*)ix_urlEncodedQueryParamsStringFromDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [dictionary objectForKey:key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end
