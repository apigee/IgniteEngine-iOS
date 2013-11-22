//
//  IXProperty.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXProperty.h"

#import "IXPropertyContainer.h"
#import "IXBaseShortCode.h"
#import "IXPropertyParser.h"

@interface IXProperty ()

@property (nonatomic,copy) NSString *propertyValue;

@end

@implementation IXProperty

-(instancetype)init
{
    return [self initWithPropertyName:nil rawValue:nil];
}

+(instancetype)propertyWithPropertyName:(NSString *)propertyName rawValue:(NSString *)rawValue
{
    return [[[self class] alloc] initWithPropertyName:propertyName rawValue:rawValue];
}

-(instancetype)initWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue
{
    self = [super init];
    if( self != nil )
    {
        _readonly = NO;
        _propertyContainer = nil;
        
        _originalString = [rawValue copy];
        _rawValue = [rawValue copy];
        _propertyName = [propertyName copy];
        
        [IXPropertyParser parseIXPropertyIntoComponents:self];
    }
    return self;
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    
    for( IXBaseShortCode *shortCode in [self shortCodes] )
    {
        for( IXProperty *property in [shortCode parameters] )
        {
            [property setPropertyContainer:propertyContainer];
        }
    }
}

-(id)copyWithZone:(NSZone *)zone
{
    IXProperty *copiedProperty = [[[self class] allocWithZone:zone] init];
    
    [copiedProperty setPropertyContainer:[self propertyContainer]];
    [copiedProperty setRawValue:[self rawValue]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setPropertyValue:[self propertyValue]];
    [copiedProperty setShortCodes:[[NSMutableArray alloc] initWithArray:[self shortCodes] copyItems:YES]];

    return copiedProperty;
}

-(NSString*)getPropertyValue
{
    if( [self rawValue] == nil || [[self rawValue] length] == 0 )
        return @"";
    
    __block NSMutableString *returnString = [NSMutableString stringWithString:[self staticText]];
    
    if( [[self shortCodes] count] > 0 )
    {
        __block NSInteger newCharsAdded = 0;
        [[self shortCodes] enumerateObjectsUsingBlock:^(IXBaseShortCode *shortCode, NSUInteger idx, BOOL *stop) {
            NSRange shortCodeRange = [[[self shortCodeRanges] objectAtIndex:idx] rangeValue];
            NSString *shortCodesValue = [shortCode evaluate];
            [returnString insertString:shortCodesValue atIndex:shortCodeRange.location + newCharsAdded];
            newCharsAdded += [shortCodesValue length] - shortCodeRange.length;
        }];
    }
    
    return returnString;
}

@end
