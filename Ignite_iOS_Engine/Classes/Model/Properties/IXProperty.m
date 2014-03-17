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
#import "IXLogger.h"

@interface IXProperty ()

@property (nonatomic,copy) NSString *propertyValue;

@end

@implementation IXProperty

+(instancetype)propertyWithPropertyName:(NSString *)propertyName rawValue:(NSString *)rawValue
{
    return [[[self class] alloc] initWithPropertyName:propertyName rawValue:rawValue];
}

-(instancetype)initWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue
{
    if( [propertyName length] <= 0 && [rawValue length] <= 0 )
    {
        return nil;
    }
    
    self = [super init];
    if( self != nil )
    {
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

+(instancetype)propertyWithPropertyName:(NSString*)propertyName jsonObject:(id)jsonObject
{
    IXProperty* property = nil;
    
    if( [jsonObject isKindOfClass:[NSString class]] )
    {
        property = [IXProperty propertyWithPropertyName:propertyName rawValue:jsonObject];
    }
    else if( [jsonObject isKindOfClass:[NSNumber class]] )
    {
        property = [IXProperty propertyWithPropertyName:propertyName rawValue:[jsonObject stringValue]];
    }
    else if( [jsonObject isKindOfClass:[NSDictionary class]] )
    {
        if( [[jsonObject allKeys] count] > 0 )
        {
            NSDictionary* propertyValueDict = (NSDictionary*)jsonObject;
            property = [IXProperty propertyWithPropertyName:propertyName jsonObject:propertyValueDict[@"value"]];
            
            [property setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:propertyValueDict[@"orientation"]]];
            [property setConditionalProperty:[IXProperty propertyWithPropertyName:nil jsonObject:propertyValueDict[@"if"]]];
        }
    }
    else if( jsonObject == nil || [jsonObject isKindOfClass:[NSNull class]] )
    {
        property = [IXProperty propertyWithPropertyName:propertyName rawValue:nil];
    }
    else
    {
        DDLogWarn(@"WARNING from %@ in %@ : Property value for %@ not a valid object %@",THIS_FILE,THIS_METHOD,propertyName,jsonObject);
    }
    return property;
}

+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueJSONArray:(NSArray*)propertyValueJSONArray
{
    NSMutableArray* propertyArray = nil;
    NSMutableString* commaSeperatedStringValueList = nil;
    for( id propertyValueObject in propertyValueJSONArray )
    {
        if( [propertyValueObject isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary* propertyValueDict = (NSDictionary*) propertyValueObject;
            IXProperty* property = [IXProperty propertyWithPropertyName:propertyName jsonObject:propertyValueDict];
            if( property != nil )
            {
                if( propertyArray == nil )
                {
                    propertyArray = [NSMutableArray array];
                }
                [propertyArray addObject:property];
            }
        }
        else if( [propertyValueObject isKindOfClass:[NSString class]] )
        {
            if( !commaSeperatedStringValueList ) {
                commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:propertyValueObject];
            } else {
                [commaSeperatedStringValueList appendFormat:@",%@",propertyValueObject];
            }
        }
        else if( [propertyValueObject isKindOfClass:[NSNumber class]] )
        {
            if( !commaSeperatedStringValueList ) {
                commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:propertyValueObject];
            } else {
                [commaSeperatedStringValueList appendFormat:@",%@",propertyValueObject];
            }
        }
        else
        {
            DDLogWarn(@"WARNING from %@ in %@ : Property value array for %@ does not have a dictionary objects",THIS_FILE,THIS_METHOD,propertyName);
        }
    }
    
    if( [commaSeperatedStringValueList length] > 0 )
    {
        IXProperty* commaSeperatedProperty = [IXProperty propertyWithPropertyName:propertyName rawValue:commaSeperatedStringValueList];
        if( commaSeperatedProperty )
        {
            if( propertyArray == nil )
            {
                propertyArray = [NSMutableArray array];
            }
            [propertyArray addObject:commaSeperatedProperty];
        }
    }
    return propertyArray;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXProperty *copiedProperty = [super copyWithZone:zone];
    [copiedProperty setPropertyName:[self propertyName]];
    [copiedProperty setOriginalString:[self originalString]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setPropertyValue:[self propertyValue]];
    if( [[self shortCodes] count] )
    {
        [copiedProperty setShortCodes:[[NSMutableArray alloc] initWithArray:[self shortCodes] copyItems:YES]];
        for( IXBaseShortCode* copiedShortCode in [copiedProperty shortCodes] )
        {
            [copiedShortCode setProperty:copiedProperty];
        }
    }
    return copiedProperty;
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    
    [[self conditionalProperty] setPropertyContainer:_propertyContainer];
    
    for( IXBaseShortCode *shortCode in [self shortCodes] )
    {
        for( IXProperty *property in [shortCode parameters] )
        {
            [property setPropertyContainer:_propertyContainer];
        }
    }
}

-(NSString*)getPropertyValue
{
    if( [self originalString] == nil || [[self originalString] length] == 0 )
        return @"";
    
    NSString* returnString = ([self staticText] == nil) ? @"" : [self staticText];
    
    if( [[self shortCodes] count] > 0 )
    {
        returnString = [[NSMutableString alloc] initWithString:returnString];
        
        __block NSInteger newCharsAdded = 0;
        __block NSMutableString* weakString = (NSMutableString*)returnString;
        
        [[self shortCodes] enumerateObjectsUsingBlock:^(IXBaseShortCode *shortCode, NSUInteger idx, BOOL *stop) {
            
            NSRange shortCodeRange = [shortCode rangeInPropertiesText];
            
            NSString *shortCodesValue = [shortCode evaluateAndApplyFunction];
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
