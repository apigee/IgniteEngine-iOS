//
//  NSString+IXAdditions.m
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

#import "NSString+IXAdditions.h"

#import "IXConstants.h"
#import "YLMoment.h"
#import "YLMoment+IXAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "NSObject+IXAdditions.h"

static NSString* const kIXFloatFormat = @"%f";

@implementation NSString (IXAdditions)

+(NSString*)ix_stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? kIX_TRUE : kIX_FALSE;
}

+(NSString*)ix_stringFromFloat:(float)floatValue
{
    return [NSString stringWithFormat:kIXFloatFormat,floatValue];
}

+(NSString*)ix_truncateString:(NSString*)string toIndex:(NSInteger)index
{
    if (index > 0 && string.length > index)
        return [NSString stringWithFormat:@"%@...", [string substringToIndex:MIN(index, string.length)]];
    else
        return string;
}

+(NSString*)ix_monogramString:(NSString *)string ifLengthIsGreaterThan:(NSInteger)length
{
    if (string.length > 0)
    {
        if (length > 0 && string.length > length)
            return [NSString stringWithFormat:@"%@.", [string substringToIndex:1]];
        else if (length == 0)
            return [NSString stringWithFormat:@"%@.", [string substringToIndex:1]];
        else
            return string;
    }
    else
        return string;
}

+(NSString*)ix_toBase64String:(NSString *)string
{
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)] && string)
    {
        NSData *utf8data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [utf8data base64EncodedStringWithOptions:0];
        return base64String;
    }
    else
    {
        //todo: need a fall back for < iOS7
        return string;
    }
}

+(NSString*)ix_fromBase64String:(NSString *)string
{
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)] && string)
    {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        return decodedString;
    }
    else
    {
        //todo: need a fall back for < iOS7
        return string;
    }
}

+(NSString*)ix_toMD5String:(NSString *)string
{
    if (string) {
        const char *cStr = [string UTF8String];
        unsigned char digest[16];
        CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];
        
        return output;
    }
    else
        return string;
}

+(NSString*)ix_formatDateString:(NSString *)string fromDateFormat:(NSString*)fromDateFormat toDateFormat:(NSString*)toDateFormat
{
    if (string.length > 0 && toDateFormat.length > 0)
    {
        BOOL fromNow = ([toDateFormat isEqualToString:@"fromNow"]);
        
        YLMoment* moment = nil;
        if ( [fromDateFormat length] > 0)
        {
            if ([fromDateFormat isEqualToString:@"unix"])
                moment = [YLMoment momentFromUnix:string];
            else if ([fromDateFormat isEqualToString:@"js"])
                moment = [YLMoment momentFromJS:string];
            else
                moment = [YLMoment momentWithDateAsString:string format:fromDateFormat];
        }
        else
        {
            moment = [YLMoment momentWithDateAsString:string format:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        }
        
        if ([toDateFormat isEqualToString:@"unix"])
        {
            return [NSString stringWithFormat:@"%0.f", [YLMoment momentToUnix:moment]];
        }
        else if ([toDateFormat isEqualToString:@"js"])
        {
            return [NSString stringWithFormat:@"%0.f", [YLMoment momentToJS:moment]];
        }
        else
        {
            if (fromNow) {
                return [moment fromNow];
            } else {
                return [moment format:toDateFormat];
            }
        }
    }
    else
        return string;
}

+(NSString*)ix_jsonStringWithPrettyPrint:(BOOL)prettyPrint fromObject:(NSObject *)object {
    return [object jsonStringWithPrettyPrint:prettyPrint];
}

+ (NSString*)ix_stripHtml:(NSString*)string {
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                     documentAttributes:nil
                                                                  error:nil];
    return [attr string];
}

- (NSString*)trimLeadingAndTrailingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL)containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options
{
    return [self rangeOfString:substring options:options].location != NSNotFound;
}

-(BOOL)isNumeric {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return ([scanner scanDouble:NULL] && [scanner isAtEnd]);
}

-(BOOL)isBOOL {
    return ([self caseInsensitiveCompare:@"yes"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@"true"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@"no"] == NSOrderedSame ||
            [self caseInsensitiveCompare:@"false"] == NSOrderedSame);
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

+ (void)load {
    @autoreleasepool {
        [self ix_modernizeSelector:NSSelectorFromString(@"containsString:") withSelector:@selector(ix_containsString:)];
    }
}

+ (void)ix_modernizeSelector:(SEL)originalSelector withSelector:(SEL)newSelector {
    if (![NSString instancesRespondToSelector:originalSelector]) {
        Method newMethod = class_getInstanceMethod(self, newSelector);
        class_addMethod(self, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    }
}

// containsString: has been added in iOS 8. We dynamically add this if we run on iOS 7.
- (BOOL)ix_containsString:(NSString *)aString {
    return [self rangeOfString:aString].location != NSNotFound;
}

- (BOOL)containsString:(NSString *)aString
{
    return [self ix_containsString:aString];
}

#endif

@end
