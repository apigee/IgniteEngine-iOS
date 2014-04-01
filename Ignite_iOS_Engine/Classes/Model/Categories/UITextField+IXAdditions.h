//
//  UITextField+IXAdditions.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (IXAdditions)

+(UITextAutocorrectionType)ix_booleanToTextAutocorrectionType:(BOOL)autoCorrect;
+(UIKeyboardAppearance)ix_stringToKeyboardAppearance:(NSString*)keyboardAppearanceString;
+(UIKeyboardType)ix_stringToKeyboardType:(NSString*)keyboardTypeString;
+(UIReturnKeyType)ix_stringToReturnKeyType:(NSString*)returnKeyTypeString;
+(NSTextAlignment)ix_textAlignmentFromString:(NSString*)textAlignmentString;

@end
