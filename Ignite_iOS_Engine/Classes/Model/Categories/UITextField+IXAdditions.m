//
//  UITextField+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "UITextField+IXAdditions.h"

@implementation UITextField (IXAdditions)

+(UIKeyboardAppearance)stringToKeyboardAppearance:(NSString*)keyboardAppearanceString
{
    UIKeyboardAppearance returnAppearance = UIKeyboardAppearanceDefault;
    if([keyboardAppearanceString isEqualToString:@"default"])
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

+(UIKeyboardType)stringToKeyboardType:(NSString*)keyboardTypeString
{
    UIKeyboardType returnType = UIKeyboardTypeDefault;
    if([keyboardTypeString isEqualToString:@"default"])
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

+(UIReturnKeyType)stringToReturnKeyType:(NSString*)returnKeyTypeString
{
    UIReturnKeyType returnKeyType = UIReturnKeyDefault;
    if([returnKeyTypeString isEqualToString:@"default"])
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

@end
