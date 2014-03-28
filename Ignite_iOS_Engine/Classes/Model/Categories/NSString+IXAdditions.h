//
//  NSString+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IXAdditions)

+(NSString*)ix_stringFromBOOL:(BOOL)boolean;
+(NSString*)ix_stringFromFloat:(float)floatValue;
+(NSString*)ix_truncateString:(NSString*)string toIndex:(NSInteger)index;
+(NSString*)ix_monogramString:(NSString*)string;
+(BOOL)ix_string:(NSString*)string containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options;

@end
