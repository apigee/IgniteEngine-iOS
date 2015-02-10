//
//  UIFont+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Brandon on 2/9/15.
//  Copyright (c) 2015 Ignite. All rights reserved.
//

#import "UIFont+IXAdditions.h"
#import "IXConstants.h"

@implementation UIFont (IXAdditions)

+ (UIFont*)ix_fontFromString:(NSString*)string {
    NSArray* fontComponents = [string componentsSeparatedByString:kIX_COLON_SEPERATOR];
    
    NSString* fontName = [fontComponents firstObject];
    CGFloat fontSize = [[fontComponents lastObject] floatValue] ?: 12.0;
    
    if( fontName )
    {
        return [UIFont fontWithName:fontName size:fontSize];
    }
    else
    {
        return nil;
    }
}

@end
