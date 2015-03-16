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
+(NSString*)ix_monogramString:(NSString*)string ifLengthIsGreaterThan:(NSInteger)length;
+(NSString*)ix_formatDateString:(NSString *)string fromDateFormat:(NSString*)fromDateFormat toDateFormat:(NSString*)toDateFormat;
+(NSString*)ix_toBase64String:(NSString*)string;
+(NSString*)ix_fromBase64String:(NSString*)string;
+(NSString*)ix_toMD5String:(NSString *)string;
-(NSString*)trimLeadingAndTrailingWhitespace;
-(BOOL)containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

- (BOOL)containsString:(NSString *)aString;

#endif

@end
