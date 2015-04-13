
//
//  NSDictionary+IXAdditions.m
//  IgniteEngine
//
//  Created by Brandon on 4/9/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "NSDictionary+IXAdditions.h"
#import "NSString+IXAdditions.h"

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
        NSLog(@"NSDictionary: %@", returnObject);
    } else if ([object isKindOfClass:[NSArray class]]) {
        [[object allKeys] enumerateObjectsUsingBlock:^(id child, NSUInteger idx, BOOL *stop) {
            [returnObject setObject:[self deriveValueTypesRecursivelyForObject:child] atIndex:idx];
        }];
        NSLog(@"NSArray: %@", returnObject);
    } else {
        //This object is not a container you might be interested in it's value
        if ([object isKindOfClass:[NSString class]]) {
            @try {
                if ([object stringIsNumber]) {
                    returnObject = [NSDecimalNumber decimalNumberWithString:object];
                } else if ([object stringIsBOOL]) {
                    NSLog(@"%d", [object stringIsBOOL]);
                    returnObject = [NSNumber numberWithBool:[object boolValue]];
                }
            }
            @catch (NSException *exception) {
                
            }
        }
        NSLog(@"NSString: %@", returnObject);
    }
    return returnObject;
}
@end
