//
//  NSObject+IXAdditions.m
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
