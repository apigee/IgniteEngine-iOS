//
//  IXAFJSONRequestOperation.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXAFJSONRequestOperation.h"

@implementation IXAFJSONRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
}

@end
