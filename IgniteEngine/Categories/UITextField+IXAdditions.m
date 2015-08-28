//
//  UITextField+IXAdditions.m
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

#import "UITextField+IXAdditions.h"
#import "IXConstants.h"

static NSString* const kIXTextAlignmentCenter = @"center";
static NSString* const kIXTextAlignmentLeft = @"left";
static NSString* const kIXTextAlignmentRight = @"right";
static NSString* const kIXTextAlignmentJustified = @"justified";
static NSString* const kIXTextAlignmentNatural = @"natural";

@implementation UITextField (IXAdditions)

+(UITextAutocorrectionType)ix_booleanToTextAutocorrectionType:(BOOL)autoCorrect
{
    UITextAutocorrectionType returnType = UITextAutocorrectionTypeDefault;
    if( !autoCorrect )
    {
        returnType = UITextAutocorrectionTypeNo;
    }
    return returnType;
}

+(UIKeyboardAppearance)ix_stringToKeyboardAppearance:(NSString*)keyboardAppearanceString
{
    UIKeyboardAppearance returnAppearance = UIKeyboardAppearanceDefault;
    if([keyboardAppearanceString isEqualToString:kIX_DEFAULT])
    {
        returnAppearance = UIKeyboardAppearanceDefault;
    }
    else if([keyboardAppearanceString isEqualToString:@"light"])
    {
        returnAppearance = UIKeyboardAppearanceLight;
    }
    else if([keyboardAppearanceString isEqualToString:@"dark"])
    {
        returnAppearance = UIKeyboardAppearanceDark;
    }
    return returnAppearance;
}

+(UIKeyboardType)ix_stringToKeyboardType:(NSString*)keyboardTypeString
{
    UIKeyboardType returnType = UIKeyboardTypeDefault;
    if([keyboardTypeString isEqualToString:kIX_DEFAULT])
    {
        returnType = UIKeyboardTypeDefault;
    }
    else if([keyboardTypeString isEqualToString:@"email"])
    {
        returnType = UIKeyboardTypeEmailAddress;
    }
    else if([keyboardTypeString isEqualToString:@"number"])
    {
        returnType = UIKeyboardTypeNumberPad;
    }
    else if([keyboardTypeString isEqualToString:@"phone"])
    {
        returnType = UIKeyboardTypePhonePad;
    }
    else if([keyboardTypeString isEqualToString:@"url"])
    {
        returnType = UIKeyboardTypeURL;
    }
    else if([keyboardTypeString isEqualToString:@"decimal"])
    {
        returnType = UIKeyboardTypeDecimalPad;
    }
    else if([keyboardTypeString isEqualToString:@"name_phone"])
    {
        returnType = UIKeyboardTypeNamePhonePad;
    }
    else if([keyboardTypeString isEqualToString:@"numbers_punctuation"])
    {
        returnType = UIKeyboardTypeNumbersAndPunctuation;
    }
    return returnType;
}

+(UIReturnKeyType)ix_stringToReturnKeyType:(NSString*)returnKeyTypeString
{
    UIReturnKeyType returnKeyType = UIReturnKeyDefault;
    if([returnKeyTypeString isEqualToString:kIX_DEFAULT])
    {
        returnKeyType = UIReturnKeyDefault;
    }
    else if([returnKeyTypeString isEqualToString:@"go"])
    {
        returnKeyType = UIReturnKeyGo;
    }
    else if([returnKeyTypeString isEqualToString:@"next"])
    {
        returnKeyType = UIReturnKeyNext;
    }
    else if([returnKeyTypeString isEqualToString:@"search"])
    {
        returnKeyType = UIReturnKeySearch;
    }
    else if([returnKeyTypeString isEqualToString:@"done"])
    {
        returnKeyType = UIReturnKeyDone;
    }
    else if([returnKeyTypeString isEqualToString:@"join"])
    {
        returnKeyType = UIReturnKeyJoin;
    }
    else if([returnKeyTypeString isEqualToString:@"send"])
    {
        returnKeyType = UIReturnKeySend;
    }
    else if([returnKeyTypeString isEqualToString:@"route"])
    {
        returnKeyType = UIReturnKeyRoute;
    }
    else if([returnKeyTypeString isEqualToString:@"emergency"])
    {
        returnKeyType = UIReturnKeyEmergencyCall;
    }
    else if([returnKeyTypeString isEqualToString:@"google"])
    {
        returnKeyType = UIReturnKeyGoogle;
    }
    else if([returnKeyTypeString isEqualToString:@"yahoo"])
    {
        returnKeyType = UIReturnKeyYahoo;
    }
    return returnKeyType;
}

+(NSTextAlignment)ix_textAlignmentFromString:(NSString*)textAlignmentString
{
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    if( [textAlignmentString isEqualToString:kIXTextAlignmentCenter] ) {
        textAlignment = NSTextAlignmentCenter;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentRight] ) {
        textAlignment = NSTextAlignmentRight;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentJustified] ) {
        textAlignment = NSTextAlignmentJustified;
    } else if( [textAlignmentString isEqualToString:kIXTextAlignmentNatural] ) {
        textAlignment = NSTextAlignmentNatural;
    }
    return textAlignment;
}

@end
