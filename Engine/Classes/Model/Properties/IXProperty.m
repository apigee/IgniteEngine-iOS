//
//  IXProperty.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXProperty.h"

#import "IXPropertyContainer.h"
#import "IXBaseVariable.h"
#import "IXLogger.h"
#import "NSString+IXAdditions.h"

static NSString* const kIXVariableRegexString = @"(\\[{2}(.+?)(?::(.+?)(?:\\((.+?)\\))?)?\\]{2}|\\{{2}([^\\}]+)\\}{2})";

// NSCoding Key Constants
static NSString* const kIXPropertyNameNSCodingKey = @"propertyName";
static NSString* const kIXOriginalStringNSCodingKey = @"originalString";
static NSString* const kIXStaticTextNSCodingKey = @"staticText";
static NSString* const kIXWasAnArrayNSCodingKey = @"wasAnArray";
static NSString* const kIXVariablesNSCodingKey = @"variables";

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
        if( [stringValue hasPrefix:kIX_IF] )
        {
            NSArray* conditionalComponents = [stringValue componentsSeparatedByString:kIX_DOUBLE_COLON_SEPERATOR];
            if (conditionalComponents.count > 1) {
                NSString* conditionalStatement = [conditionalComponents[1] trimLeadingAndTrailingWhitespace];
                NSString* valueIfTrue = [conditionalComponents[2] trimLeadingAndTrailingWhitespace];
                NSString* valueIfFalse = (conditionalComponents.count == 4) ? [conditionalComponents[3] trimLeadingAndTrailingWhitespace] : nil;

                conditionalProperty = [IXProperty propertyWithPropertyName:propertyName rawValue:valueIfTrue];
                [conditionalProperty setConditionalProperty:[IXProperty propertyWithPropertyName:nil rawValue:conditionalStatement]];
                if( [valueIfFalse length] > 0 ) {
                    [conditionalProperty setElseProperty:[IXProperty propertyWithPropertyName:nil rawValue:valueIfFalse]];
                }
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
        IX_LOG_WARN(@"WARNING from %@ in %@ : Property value for %@ not a valid object %@",THIS_FILE,THIS_METHOD,propertyName,jsonObject);
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
                    [commaSeperatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,propertyValueObject];
                }
            }
        }
        else if( [propertyValueObject isKindOfClass:[NSNumber class]] )
        {
            NSString* stringValue = [propertyValueObject stringValue];
            if( !commaSeperatedStringValueList ) {
                commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:stringValue];
            } else {
                [commaSeperatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,stringValue];
            }
        }
        else
        {
            IX_LOG_WARN(@"WARNING from %@ in %@ : Property value array for %@ does not have a dictionary objects",THIS_FILE,THIS_METHOD,propertyName);
        }
    }
    
    if( [commaSeperatedStringValueList length] > 0 )
    {
        IXProperty* commaSeperatedProperty = [IXProperty propertyWithPropertyName:propertyName rawValue:commaSeperatedStringValueList];
        [commaSeperatedProperty setWasAnArray:YES];
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

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self propertyName] forKey:kIXPropertyNameNSCodingKey];
    [aCoder encodeObject:[self originalString] forKey:kIXOriginalStringNSCodingKey];
    [aCoder encodeObject:[self staticText] forKey:kIXStaticTextNSCodingKey];
    [aCoder encodeBool:[self wasAnArray] forKey:kIXWasAnArrayNSCodingKey];
    if( [[self variables] count] )
    {
        [aCoder encodeObject:[self variables] forKey:kIXVariablesNSCodingKey];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setPropertyName:[aDecoder decodeObjectForKey:kIXPropertyNameNSCodingKey]];
        [self setOriginalString:[aDecoder decodeObjectForKey:kIXOriginalStringNSCodingKey]];
        [self setStaticText:[aDecoder decodeObjectForKey:kIXStaticTextNSCodingKey]];
        [self setWasAnArray:[aDecoder decodeBoolForKey:kIXWasAnArrayNSCodingKey]];
        
        [self setVariables:[aDecoder decodeObjectForKey:kIXVariablesNSCodingKey]];
        for( IXBaseVariable* variable in [self variables] )
        {
            [variable setProperty:self];
        }
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXProperty *copiedProperty = [super copyWithZone:zone];
    [copiedProperty setPropertyName:[self propertyName]];
    [copiedProperty setOriginalString:[self originalString]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setWasAnArray:[self wasAnArray]];
    if( [[self variables] count] )
    {
        [copiedProperty setVariables:[[NSMutableArray alloc] initWithArray:[self variables] copyItems:YES]];
        for( IXBaseVariable* copiedVariable in [copiedProperty variables] )
        {
            [copiedVariable setProperty:copiedProperty];
        }
    }
    return copiedProperty;
}

-(void)parseProperty
{
    NSString* propertiesStaticText = [[self originalString] copy];
    if( [propertiesStaticText length] > 0 )
    {
        static NSRegularExpression *variableMainComponentsRegex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError* __autoreleasing error = nil;
            variableMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXVariableRegexString
                                                                                options:NSRegularExpressionDotMatchesLineSeparators
                                                                                  error:&error];
            if( error )
                IX_LOG_ERROR(@"Critical Error!!! Variable regex invalid with error: %@.",[error description]);
        });
        
        NSArray* matchesInStaticText = [variableMainComponentsRegex matchesInString:propertiesStaticText
                                                                             options:0
                                                                               range:NSMakeRange(0, [propertiesStaticText length])];
        if( [matchesInStaticText count] )
        {
            __block NSUInteger numberOfCharactersRemoved = 0;
            __block NSMutableArray* propertiesVariables = nil;
            __block NSMutableString* mutableStaticText = [[NSMutableString alloc] initWithString:propertiesStaticText];
            
            for( NSTextCheckingResult* matchInVariableString in matchesInStaticText )
            {
                IXBaseVariable* variable = [IXBaseVariable variableFromString:propertiesStaticText
                                                               textCheckingResult:matchInVariableString];
                if( variable )
                {
                    [variable setProperty:self];
                    
                    if( !propertiesVariables )
                    {
                        propertiesVariables = [[NSMutableArray alloc] init];
                    }
                    
                    [propertiesVariables addObject:variable];
                    
                    NSRange variableRange = [matchInVariableString rangeAtIndex:0];
                    variableRange.location = variableRange.location - numberOfCharactersRemoved;
                    [mutableStaticText replaceCharactersInRange:variableRange withString:kIX_EMPTY_STRING];
                    numberOfCharactersRemoved += variableRange.length;
                }
            }
            
            [self setStaticText:mutableStaticText];
            [self setVariables:propertiesVariables];
        }
        else
        {
            [self setStaticText:propertiesStaticText];
            [self setVariables:nil];
        }
    }
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    _propertyContainer = propertyContainer;
    
    [[self conditionalProperty] setPropertyContainer:_propertyContainer];
    [[self elseProperty] setPropertyContainer:_propertyContainer];
    
    for( IXBaseVariable *variable in [self variables] )
    {
        for( IXProperty *property in [variable parameters] )
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
    
    if( [[self variables] count] > 0 )
    {
        returnString = [[NSMutableString alloc] initWithString:returnString];
        
        __block NSInteger newCharsAdded = 0;
        __block NSMutableString* weakString = (NSMutableString*)returnString;
        
        [[self variables] enumerateObjectsUsingBlock:^(IXBaseVariable *variable, NSUInteger idx, BOOL *stop) {
            
            NSRange variableRange = [variable rangeInPropertiesText];
            
            NSString *variablesValue = [variable evaluateAndApplyFunction];
            if( variablesValue == nil )
            {
                variablesValue = kIX_EMPTY_STRING;
            }            
            [weakString insertString:variablesValue atIndex:variableRange.location + newCharsAdded];
            newCharsAdded += [variablesValue length] - variableRange.length;
        }];
    }
    
    return returnString;
}

@end
