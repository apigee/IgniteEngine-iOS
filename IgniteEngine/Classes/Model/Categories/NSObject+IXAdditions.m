//
//  NSObject+IXAdditions.m
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "NSObject+IXAdditions.h"

@implementation NSObject (IXAdditions)

-(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing JSON from NSObject: %@", error.localizedDescription);
        return [NSString stringWithFormat:@"{\n%*serror: %@\n};", 4, "", error.localizedDescription];
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
