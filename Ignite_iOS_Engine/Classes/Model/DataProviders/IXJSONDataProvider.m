//
//  IXJSONDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXJSONDataProvider.h"

@implementation IXJSONDataProvider

-(void)applySettings
{
    [super applySettings];
}

- (NSObject *)objectForPath:(NSString *)jsonXPath container: (NSObject*) currentNode {
    
    if (currentNode == nil) {
        return nil;
    }
    
    // we cannot go any further
    if(![currentNode isKindOfClass:[NSDictionary class]] && ![currentNode isKindOfClass:[NSArray class]]) {
        return currentNode;
    }
    
    if ([jsonXPath hasPrefix:@"/"]) {
        jsonXPath = [jsonXPath substringFromIndex:1];
    }
    
    NSString *currentKey = [[jsonXPath componentsSeparatedByString:@"/"] firstObject];
    
    NSObject *nextNode;
    // if dict -> get value
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        NSDictionary *currentDict = (NSDictionary *) currentNode;
        nextNode = [currentDict objectForKey:currentKey];
    }
    
    if ([currentNode isKindOfClass:[NSArray class]]) {
        // current key must be an number
        NSArray * currentArray = (NSArray *) currentNode;
        nextNode = [currentArray objectAtIndex:[currentKey integerValue]];
    }
    
    // remove the currently processed key from the xpath like path
    NSString * nextXPath = [jsonXPath stringByReplacingCharactersInRange:NSMakeRange(0, [currentKey length]) withString:@""];
    
    // call recursively with the new xpath and the new Node
    return [self objectForPath:nextXPath container: nextNode];
    
}

@end
