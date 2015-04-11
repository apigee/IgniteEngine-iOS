//
//  NSDictionary+IXAdditions.h
//  IgniteEngine
//
//  Created by Brandon on 4/9/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IXAdditions)

+(NSDictionary*)ix_dictionaryFromQueryParamsString:(NSString*)string;
+(NSDictionary*)ix_dictionaryWithParsedValuesFromDictionary:(NSDictionary*)dictionary;

@end
