//
//  NSString+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
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
+(NSString*)ix_stripHtml:(NSString*)string;
+(NSString*)ix_jsonStringWithPrettyPrint:(BOOL)prettyPrint fromObject:(NSObject *)object;

-(BOOL)isBOOL;
-(BOOL)isNumeric;

-(NSString*)trimLeadingAndTrailingWhitespace;
-(BOOL)containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

// Added in iOS 8, retrofitted for iOS 7
- (BOOL)containsString:(NSString *)aString;

#endif

@end