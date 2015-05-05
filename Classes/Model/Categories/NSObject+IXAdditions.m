//
//  NSObject+IXAdditions.m
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "NSObject+IXAdditions.h"
#import "IXConstants.h"

@implementation NSObject (IXAdditions)

-(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint
{
    NSError* __autoreleasing error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if( [jsonData length] > 0 && error == nil ) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        IX_LOG_ERROR(@"Error serializing JSON from NSObject:\n%@", error.localizedDescription);
        return [NSString stringWithFormat:@"{\n%*serror: %@\n};", 4, "", error.localizedDescription];
    }
}

+(id)ix_dictionaryFromJSONString:(NSString*)string {
    NSError* __autoreleasing error;
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if( jsonDict != nil && error == nil ) {
        return jsonDict;
    } else {
        IX_LOG_ERROR(@"Error decoding NSObject from JSON string:\n%@\nString: %@", error.localizedDescription, string);
        return nil;
    }
}

@end
