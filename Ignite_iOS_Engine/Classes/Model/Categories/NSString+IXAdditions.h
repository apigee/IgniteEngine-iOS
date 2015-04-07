//
//  NSString+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
+(NSString*)ix_stripHtml:(NSString *)string;
-(NSString*)trimLeadingAndTrailingWhitespace;
-(BOOL)containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

// Added in iOS 8, retrofitted for iOS 7
- (BOOL)containsString:(NSString *)aString;

#endif

@end