//
//  IXProperty.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
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
        
        _originalString = rawValue;
        _rawValue = rawValue;
        _propertyName = propertyName;
        
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
    
    NSMutableString *returnString = [[NSMutableString alloc] initWithString:[self staticText]];
    
    if( [[self shortCodes] count] > 0 )
    {
        __block NSInteger newCharsAdded = 0;
        __block IXProperty* weakSelf = self;
        __weak NSMutableString* weakString = returnString;
        
        [[self shortCodes] enumerateObjectsUsingBlock:^(IXBaseShortCode *shortCode, NSUInteger idx, BOOL *stop) {
            
            NSRange shortCodeRange = [[[weakSelf shortCodeRanges] objectAtIndex:idx] rangeValue];
            NSString *shortCodesValue = [shortCode evaluate];
            if( shortCodesValue == nil )
            {
                shortCodesValue = @"";
            }            
            [weakString insertString:shortCodesValue atIndex:shortCodeRange.location + newCharsAdded];
            newCharsAdded += [shortCodesValue length] - shortCodeRange.length;
        }];
    }
    
    return returnString;
}

@end
