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
#import "IXLogger.h"

static NSString* const kIXIfRegexString = @"^if *:: *(.*) *:: *(.*$)";
static NSString* const kIXShortcodeRegexString = @"(\\[{2}(.+?)(?::(.+?)(?:\\((.+?)\\))?)?\\]{2}|\\{{2}([^\\}]+)\\}{2})";

@interface IXProperty ()

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
        
        [self parseProperty];
    }
    return self;
}

+(instancetype)conditionalPropertyWithPropertyName:(NSString*)propertyName jsonObject:(id)jsonObject
{
    IXProperty* conditionalProperty = nil;
    if( [jsonObject isKindOfClass:[NSString class]] )
    {
        NSString* stringValue = (NSString*)jsonObject;
        if( [stringValue length] )
        {
            static NSRegularExpression *sIXIfRegex = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSError* __autoreleasing error = nil;
                sIXIfRegex = [[NSRegularExpression alloc] initWithPattern:kIXIfRegexString
                                                                  options:NSRegularExpressionDotMatchesLineSeparators
                                                                    error:&error];
                if( error )
                    DDLogError(@"Critical Error!!! IF REGEX %@ invalid with error: %@.",kIXIfRegexString,[error description]);
            });
            
            NSTextCheckingResult* conditionalMatch = [sIXIfRegex firstMatchInString:stringValue
                                                                            options:0
                                                                              range:NSMakeRange(0, [stringValue length])];
            
            NSUInteger rangeCount = [conditionalMatch numberOfRanges];
            if( rangeCount > 2 )
            {
                conditionalProperty = [IXProperty propertyWithPropertyName:propertyName
                                                                  rawValue:[stringValue substringWithRange:[conditionalMatch rangeAtIndex:2]]];
                
                [conditionalProperty setConditionalProperty:[IXProperty propertyWithPropertyName:nil
                                                                                        rawValue:[stringValue substringWithRange:[conditionalMatch rangeAtIndex:1]]]];
            }
        }
    }
    else if( [jsonObject isKindOfClass:[NSDictionary class]] && [[jsonObject allKeys] count] > 0 )
    {
        NSDictionary* propertyValueDict = (NSDictionary*)jsonObject;
        conditionalProperty = [IXProperty propertyWithPropertyName:propertyName jsonObject:propertyValueDict[kIX_VALUE]];
            
        [conditionalProperty setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:propertyValueDict[kIX_ORIENTATION]]];
        [conditionalProperty setConditionalProperty:[IXProperty propertyWithPropertyName:nil jsonObject:propertyValueDict[kIX_IF]]];
    }
    return conditionalProperty;
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
        property = [IXProperty conditionalPropertyWithPropertyName:propertyName jsonObject:jsonObject];
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
            IXProperty* conditionalProperty = [IXProperty conditionalPropertyWithPropertyName:propertyName jsonObject:propertyValueObject];
            if( conditionalProperty )
            {
                if( propertyArray == nil )
                {
                    propertyArray = [NSMutableArray array];
                }
                [propertyArray addObject:conditionalProperty];
            }
            else
            {
                if( !commaSeperatedStringValueList ) {
                    commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:propertyValueObject];
                } else {
                    [commaSeperatedStringValueList appendFormat:@",%@",propertyValueObject];
                }
            }
        }
        else if( [propertyValueObject isKindOfClass:[NSNumber class]] )
        {
            NSString* stringValue = [propertyValueObject stringValue];
            if( !commaSeperatedStringValueList ) {
                commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:stringValue];
            } else {
                [commaSeperatedStringValueList appendFormat:@",%@",stringValue];
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

-(void)parseProperty
{
    NSString* propertiesStaticText = [[self originalString] copy];
    if( [propertiesStaticText length] > 0 )
    {
        static NSRegularExpression *shortCodeMainComponentsRegex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError* __autoreleasing error = nil;
            shortCodeMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXShortcodeRegexString
                                                                                options:NSRegularExpressionDotMatchesLineSeparators
                                                                                  error:&error];
            if( error )
                DDLogError(@"Critical Error!!! Shortcode regex invalid with error: %@.",[error description]);
        });
        
        NSArray* matchesInStaticText = [shortCodeMainComponentsRegex matchesInString:propertiesStaticText
                                                                             options:0
                                                                               range:NSMakeRange(0, [propertiesStaticText length])];
        if( [matchesInStaticText count] )
        {
            __block NSUInteger numberOfCharactersRemoved = 0;
            __block NSMutableArray* propertiesShortCodes = nil;
            __block NSMutableString* mutableStaticText = [[NSMutableString alloc] initWithString:propertiesStaticText];
            
            for( NSTextCheckingResult* matchInShortCodeString in matchesInStaticText )
            {
                IXBaseShortCode* shortCode = [IXBaseShortCode shortCodeFromString:propertiesStaticText
                                                               textCheckingResult:matchInShortCodeString];
                if( shortCode )
                {
                    [shortCode setProperty:self];
                    
                    if( !propertiesShortCodes )
                    {
                        propertiesShortCodes = [[NSMutableArray alloc] init];
                    }
                    
                    [propertiesShortCodes addObject:shortCode];
                    
                    NSRange shortCodeRange = [matchInShortCodeString rangeAtIndex:0];
                    shortCodeRange.location = shortCodeRange.location - numberOfCharactersRemoved;
                    [mutableStaticText replaceCharactersInRange:shortCodeRange withString:kIX_EMPTY_STRING];
                    numberOfCharactersRemoved += shortCodeRange.length;
                }
            }
            
            [self setStaticText:mutableStaticText];
            [self setShortCodes:propertiesShortCodes];
        }
        else
        {
            [self setStaticText:propertiesStaticText];
            [self setShortCodes:nil];
        }
    }
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
        return kIX_EMPTY_STRING;
    
    NSString* returnString = ([self staticText] == nil) ? kIX_EMPTY_STRING : [self staticText];
    
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
                shortCodesValue = kIX_EMPTY_STRING;
            }            
            [weakString insertString:shortCodesValue atIndex:shortCodeRange.location + newCharsAdded];
            newCharsAdded += [shortCodesValue length] - shortCodeRange.length;
        }];
    }
    
    return returnString;
}

@end
