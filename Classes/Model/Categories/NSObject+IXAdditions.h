//
//  NSObject+IXAdditions.h
//  IgniteEngine
//
//  Created by Brandon on 4/13/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (IXAdditions)

-(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint;
+(id)ix_dictionaryFromJSONString:(NSString*)string;

@end
