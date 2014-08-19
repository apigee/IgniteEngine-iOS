//
//  Formatters.m
//  NegotiatorApp
//
//  Created by Michael Atwood on 12/1/11.
//  Copyright (c) 2011 Michael Atwood. All rights reserved.
//

#import "Formatter.h"

@implementation Formatters

// MARK: -
// MARK: Formatters
+(NSNumberFormatter*) currencyFormatter{
	NSNumberFormatter* currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setLocale:[NSLocale currentLocale]];
	
	return currencyFormatter;
}

+(NSNumberFormatter*) currencyFormatterWithNoFraction{
	NSNumberFormatter* currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setLocale:[NSLocale currentLocale]];
    [currencyFormatter setMaximumFractionDigits:0];
	
	return currencyFormatter;
}

+(NSNumberFormatter*) percentFormatter{
	NSNumberFormatter* percentFormatter = [[NSNumberFormatter alloc] init];
	[percentFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	[percentFormatter setLocale:[NSLocale currentLocale]];
	[percentFormatter setMinimumFractionDigits:2];
    
	return percentFormatter;
}

+(NSNumberFormatter*) basicFormatter{
    NSNumberFormatter* basicFormatter = [[NSNumberFormatter alloc] init];
    [basicFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    
    return basicFormatter;
}

@end