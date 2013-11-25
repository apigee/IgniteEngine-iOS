//
//  IXFormatShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/24/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXFormatShortCode.h"

#import "IXProperty.h"

@implementation IXFormatShortCode

-(NSString*)evaluate
{
    NSString* returnString = [super evaluate];
    if( returnString != nil )
    {
        for( IXProperty* formatterProperty in [self formatters] )
        {
            NSString* formatterName = [formatterProperty getPropertyValue];
            if( [formatterName isEqualToString:@"to_uppercase"] )
            {
                returnString = [returnString uppercaseString];
            }
            else if( [formatterName isEqualToString:@"to_lowercase"] )
            {
                returnString = [returnString capitalizedString];
            }
            else if( [formatterName isEqualToString:@"capitalize"] )
            {
                returnString = [returnString capitalizedString];
            }
        }
    }
    return returnString;
}

@end
