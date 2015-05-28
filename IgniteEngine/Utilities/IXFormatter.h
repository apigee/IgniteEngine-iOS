//
//  IXFormatter.h
//  NegotiatorApp
//
//  Created by Michael Atwood on 12/1/11.
//  Copyright (c) 2011 Michael Atwood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXFormatter : NSObject

//data formats
+(NSNumberFormatter*) currencyFormatter;
+(NSNumberFormatter*) currencyFormatterWithNoFraction;
+(NSNumberFormatter*) percentFormatter;
+(NSNumberFormatter*) basicFormatter;

@end
