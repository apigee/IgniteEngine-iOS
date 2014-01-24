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
        _propertyName = propertyName;
        
        if( rawValue != nil )
        {
            [IXPropertyParser parseIXPropertyIntoComponents:self];
        }
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXProperty *copiedProperty = [super copyWithZone:zone];
    [copiedProperty setReadonly:[self isReadonly]];
    [copiedProperty setPropertyName:[self propertyName]];
    [copiedProperty setOriginalString:[self originalString]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setPropertyValue:[self propertyValue]];
    [copiedProperty setShortCodes:[[NSMutableArray alloc] initWithArray:[self shortCodes] copyItems:YES]];
    for( IXBaseShortCode* copiedShortCode in [copiedProperty shortCodes] )
    {
        [copiedShortCode setProperty:copiedProperty];
    }
    [copiedProperty setShortCodeRanges:[[NSMutableArray alloc] initWithArray:[self shortCodeRanges] copyItems:YES]];
    return copiedProperty;
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    for( IXBaseShortCode *shortCode in [self shortCodes] )
    {
        for( IXProperty *property in [shortCode parameters] )
        {
            [property setPropertyContainer:_propertyContainer];
        }
    }
}

-(NSString*)getPropertyValue:(IXSandbox*)sandbox
{
    if( [self originalString] == nil || [[self originalString] length] == 0 )
        return @"";
    
    NSString* returnString = ([self staticText] == nil) ? @"" : [self staticText];
    
    if( [[self shortCodes] count] > 0 )
    {
        returnString = [[NSMutableString alloc] initWithString:returnString];
        
        __block NSInteger newCharsAdded = 0;
        __block IXProperty* weakSelf = self;
        __weak NSMutableString* weakString = (NSMutableString*)returnString;
        
        [[self shortCodes] enumerateObjectsUsingBlock:^(IXBaseShortCode *shortCode, NSUInteger idx, BOOL *stop) {
            
            NSRange shortCodeRange = [[[weakSelf shortCodeRanges] objectAtIndex:idx] rangeValue];
            NSString *shortCodesValue = [shortCode evaluate:sandbox];
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
