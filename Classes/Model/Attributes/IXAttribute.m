//
//  IXAttribute.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXAttribute.h"

#import "IXAttributeContainer.h"
#import "IXBaseEvaluation.h"
#import "IXLogger.h"
#import "NSString+IXAdditions.h"

static NSString* const kIXEvaluationRegexString = @"(\\[{2}(.+?)(?::(.+?)(?:\\((.+?)\\))?)?\\]{2}|\\{{2}([^\\}]+)\\}{2})";

// NSCoding Key Constants
static NSString* const kIXAttributeNameNSCodingKey = @"attributeName";
static NSString* const kIXOriginalStringNSCodingKey = @"originalString";
static NSString* const kIXStaticTextNSCodingKey = @"staticText";
static NSString* const kIXWasAnArrayNSCodingKey = @"wasAnArray";
static NSString* const kIXEvaluationsNSCodingKey = @"evaluations";

@interface IXAttribute ()

@end

@implementation IXAttribute

+(instancetype)attributeWithAttributeName:(NSString *)attributeName rawValue:(NSString *)rawValue
{
    return [[[self class] alloc] initWithAttributeName:attributeName rawValue:rawValue];
}

-(instancetype)initWithAttributeName:(NSString*)attributeName rawValue:(NSString*)rawValue
{
    if( [attributeName length] <= 0 && [rawValue length] <= 0 )
    {
        return nil;
    }
    
    self = [super init];
    if( self != nil )
    {
        _attributeContainer = nil;
        
        _originalString = rawValue;
        _attributeName = attributeName;
        
        [self parseProperty];
    }
    return self;
}

+(instancetype)conditionalPropertyWithPropertyName:(NSString*)propertyName jsonObject:(id)jsonObject
{
    IXAttribute* conditionalProperty = nil;
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

                conditionalProperty = [IXAttribute attributeWithAttributeName:propertyName rawValue:valueIfTrue];
                [conditionalProperty setValueIfTrue:[IXAttribute attributeWithAttributeName:nil rawValue:conditionalStatement]];
                if( [valueIfFalse length] > 0 ) {
                    [conditionalProperty setValueIfFalse:[IXAttribute attributeWithAttributeName:nil rawValue:valueIfFalse]];
                }
            }
        }
    }
    else if( [jsonObject isKindOfClass:[NSDictionary class]] && [[jsonObject allKeys] count] > 0 )
    {
        NSDictionary* propertyValueDict = (NSDictionary*)jsonObject;
        conditionalProperty = [IXAttribute attributeWithAttributeName:propertyName jsonObject:propertyValueDict[kIX_VALUE]];
            
        [conditionalProperty setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:propertyValueDict[kIX_ORIENTATION]]];
        [conditionalProperty setValueIfTrue:[IXAttribute attributeWithAttributeName:nil jsonObject:propertyValueDict[kIX_IF]]];
    }
    return conditionalProperty;
}

+(instancetype)attributeWithAttributeName:(NSString*)attributeName jsonObject:(id)jsonObject
{
    IXAttribute* attribute = nil;
    
    if( [jsonObject isKindOfClass:[NSString class]] )
    {
        attribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:jsonObject];
    }
    else if( [jsonObject isKindOfClass:[NSNumber class]] )
    {
        attribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:[jsonObject stringValue]];
    }
    else if( [jsonObject isKindOfClass:[NSDictionary class]] )
    {
        attribute = [IXAttribute conditionalPropertyWithPropertyName:attributeName jsonObject:jsonObject];
    }
    else if( jsonObject == nil || [jsonObject isKindOfClass:[NSNull class]] )
    {
        attribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:nil];
    }
    else
    {
        IX_LOG_WARN(@"WARNING from %@ in %@: Property value for %@ is not a valid object:\n %@",THIS_FILE,THIS_METHOD,attributeName,jsonObject);
    }
    return attribute;
}

+(NSArray*)attributeWithAttributeName:(NSString*)attributeName attributeValueJSONArray:(NSArray*)attributeValueJSONArray
{
    NSMutableArray* propertyArray = nil;
    NSMutableString* commaSeparatedStringValueList = nil;
    for( id propertyValueObject in attributeValueJSONArray )
    {
        if( [propertyValueObject isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary* propertyValueDict = (NSDictionary*) propertyValueObject;
            IXAttribute* property = [IXAttribute attributeWithAttributeName:attributeName jsonObject:propertyValueDict];
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
            IXAttribute* conditionalProperty = [IXAttribute conditionalPropertyWithPropertyName:attributeName jsonObject:propertyValueObject];
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
                if( !commaSeparatedStringValueList ) {
                    commaSeparatedStringValueList = [[NSMutableString alloc] initWithString:propertyValueObject];
                } else {
                    [commaSeparatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,propertyValueObject];
                }
            }
        }
        else if( [propertyValueObject isKindOfClass:[NSNumber class]] )
        {
            NSString* stringValue = [propertyValueObject stringValue];
            if( !commaSeparatedStringValueList ) {
                commaSeparatedStringValueList = [[NSMutableString alloc] initWithString:stringValue];
            } else {
                [commaSeparatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,stringValue];
            }
        }
        else
        {
            IX_LOG_WARN(@"WARNING from %@ in %@: Property value array for %@ does not have a dictionary object",THIS_FILE,THIS_METHOD,attributeName);
        }
    }
    
    if( [commaSeparatedStringValueList length] > 0 )
    {
        IXAttribute* commaSeparatedAttribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:commaSeparatedStringValueList];
        [commaSeparatedAttribute setWasAnArray:YES];
        if( commaSeparatedAttribute )
        {
            if( propertyArray == nil )
            {
                propertyArray = [NSMutableArray array];
            }
            [propertyArray addObject:commaSeparatedAttribute];
        }
    }
    return propertyArray;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[self attributeName] forKey:kIXAttributeNameNSCodingKey];
    [aCoder encodeObject:[self originalString] forKey:kIXOriginalStringNSCodingKey];
    [aCoder encodeObject:[self staticText] forKey:kIXStaticTextNSCodingKey];
    [aCoder encodeBool:[self wasAnArray] forKey:kIXWasAnArrayNSCodingKey];
    if( [[self evaluations] count] )
    {
        [aCoder encodeObject:[self evaluations] forKey:kIXEvaluationsNSCodingKey];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setAttributeName:[aDecoder decodeObjectForKey:kIXAttributeNameNSCodingKey]];
        [self setOriginalString:[aDecoder decodeObjectForKey:kIXOriginalStringNSCodingKey]];
        [self setStaticText:[aDecoder decodeObjectForKey:kIXStaticTextNSCodingKey]];
        [self setWasAnArray:[aDecoder decodeBoolForKey:kIXWasAnArrayNSCodingKey]];
        
        [self setEvaluations:[aDecoder decodeObjectForKey:kIXEvaluationsNSCodingKey]];
        for( IXBaseEvaluation* eval in [self evaluations] )
        {
            [eval setProperty:self];
        }
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXAttribute *copiedProperty = [super copyWithZone:zone];
    [copiedProperty setAttributeName:[self attributeName]];
    [copiedProperty setOriginalString:[self originalString]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setWasAnArray:[self wasAnArray]];
    if( [[self evaluations] count] )
    {
        [copiedProperty setEvaluations:[[NSMutableArray alloc] initWithArray:[self evaluations] copyItems:YES]];
        for( IXBaseEvaluation* copiedVariable in [copiedProperty evaluations] )
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
        static NSRegularExpression *evaluationMainComponentsRegex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError* __autoreleasing error = nil;
            evaluationMainComponentsRegex = [[NSRegularExpression alloc] initWithPattern:kIXEvaluationRegexString
                                                                                options:NSRegularExpressionDotMatchesLineSeparators
                                                                                  error:&error];
            if( error )
                IX_LOG_ERROR(@"Critical Error!!! Variable regex invalid with error: %@.",[error description]);
        });
        
        NSArray* matchesInStaticText = [evaluationMainComponentsRegex matchesInString:propertiesStaticText
                                                                             options:0
                                                                               range:NSMakeRange(0, [propertiesStaticText length])];
        if( [matchesInStaticText count] )
        {
            __block NSUInteger numberOfCharactersRemoved = 0;
            __block NSMutableArray* propertiesVariables = nil;
            __block NSMutableString* mutableStaticText = [[NSMutableString alloc] initWithString:propertiesStaticText];
            
            for( NSTextCheckingResult* matchInVariableString in matchesInStaticText )
            {
                IXBaseEvaluation* eval = [IXBaseEvaluation evaluationFromString:propertiesStaticText
                                                               textCheckingResult:matchInVariableString];
                if( eval )
                {
                    [eval setProperty:self];
                    
                    if( !propertiesVariables )
                    {
                        propertiesVariables = [[NSMutableArray alloc] init];
                    }
                    
                    [propertiesVariables addObject:eval];
                    
                    NSRange evalRange = [matchInVariableString rangeAtIndex:0];
                    evalRange.location = evalRange.location - numberOfCharactersRemoved;
                    [mutableStaticText replaceCharactersInRange:evalRange withString:kIX_EMPTY_STRING];
                    numberOfCharactersRemoved += evalRange.length;
                }
            }
            
            [self setStaticText:mutableStaticText];
            [self setEvaluations:propertiesVariables];
        }
        else
        {
            [self setStaticText:propertiesStaticText];
            [self setEvaluations:nil];
        }
    }
}

-(void)setAttributeContainer:(IXAttributeContainer *)propertyContainer
{
    _attributeContainer = propertyContainer;
    
    [[self valueIfTrue] setAttributeContainer:_attributeContainer];
    [[self valueIfFalse] setAttributeContainer:_attributeContainer];
    
    for( IXBaseEvaluation *eval in [self evaluations] )
    {
        for( IXAttribute *attribute in [eval parameters] )
        {
            [attribute setAttributeContainer:_attributeContainer];
        }
    }
}

-(NSString*)attributeStringValue
{
    if( [self originalString] == nil || [[self originalString] length] == 0 )
        return kIX_EMPTY_STRING;
    
    NSString* returnString = ([self staticText] == nil) ? kIX_EMPTY_STRING : [self staticText];
    
    if( [[self evaluations] count] > 0 )
    {
        returnString = [[NSMutableString alloc] initWithString:returnString];
        
        __block NSInteger newCharsAdded = 0;
        __block NSMutableString* weakString = (NSMutableString*)returnString;
        
        [[self evaluations] enumerateObjectsUsingBlock:^(IXBaseEvaluation *eval, NSUInteger idx, BOOL *stop) {
            
            NSRange evalRange = [eval rangeInPropertiesText];
            
            NSString *evaluatedValue = [eval evaluateAndApplyUtility];
            if( evaluatedValue == nil )
            {
                evaluatedValue = kIX_EMPTY_STRING;
            }            
            [weakString insertString:evaluatedValue atIndex:evalRange.location + newCharsAdded];
            newCharsAdded += [evaluatedValue length] - evalRange.length;
        }];
    }
    
    return returnString;
}

@end
