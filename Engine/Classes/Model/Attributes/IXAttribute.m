//
//  IXAttribute.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
        
        [self parseAttribute];
    }
    return self;
}

+(instancetype)conditionalAttributeWithAttributeName:(NSString*)attributeName jsonObject:(id)jsonObject
{
    IXAttribute* conditionalAttribute = nil;
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

                conditionalAttribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:valueIfTrue];
                [conditionalAttribute setConditionalProperty:[IXAttribute attributeWithAttributeName:nil rawValue:conditionalStatement]];
                if( [valueIfFalse length] > 0 ) {
                    [conditionalAttribute setElseProperty:[IXAttribute attributeWithAttributeName:nil rawValue:valueIfFalse]];
                }
            }
        }
    }
    else if( [jsonObject isKindOfClass:[NSDictionary class]] && [[jsonObject allKeys] count] > 0 )
    {
        NSDictionary* attibutesDict = (NSDictionary*)jsonObject;
        conditionalAttribute = [IXAttribute attributeWithAttributeName:attributeName jsonObject:attibutesDict[kIX_VALUE]];
            
        [conditionalAttribute setInterfaceOrientationMask:[IXBaseConditionalObject orientationMaskForValue:attibutesDict[kIX_ORIENTATION]]];
        [conditionalAttribute setConditionalProperty:[IXAttribute attributeWithAttributeName:nil jsonObject:attibutesDict[kIX_IF]]];
    }
    return conditionalAttribute;
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
        attribute = [IXAttribute conditionalAttributeWithAttributeName:attributeName jsonObject:jsonObject];
    }
    else if( jsonObject == nil || [jsonObject isKindOfClass:[NSNull class]] )
    {
        attribute = [IXAttribute attributeWithAttributeName:attributeName rawValue:nil];
    }
    else
    {
        IX_LOG_WARN(@"WARNING from %@ in %@ : Property value for %@ not a valid object %@",THIS_FILE,THIS_METHOD,attributeName,jsonObject);
    }
    return attribute;
}

+(NSArray*)attributesWithAttributeName:(NSString*)attributeName attributeValueArray:(NSArray*)attributeValueArray
{
    NSMutableArray* attributeArray = nil;
    NSMutableString* commaSeperatedStringValueList = nil;
    for( id attributeValueObject in attributeValueArray )
    {
        if( [attributeValueObject isKindOfClass:[NSDictionary class]] )
        {
            NSDictionary* attributeDict = (NSDictionary*) attributeValueObject;
            IXAttribute* attribute = [IXAttribute attributeWithAttributeName:attributeName jsonObject:attributeDict];
            if( attribute != nil )
            {
                if( attributeArray == nil )
                {
                    attributeArray = [NSMutableArray array];
                }
                [attributeArray addObject:attribute];
            }
        }
        else if( [attributeValueObject isKindOfClass:[NSString class]] )
        {
            IXAttribute* conditionalProperty = [IXAttribute conditionalAttributeWithAttributeName:attributeName jsonObject:attributeValueObject];
            if( conditionalProperty )
            {
                if( attributeArray == nil )
                {
                    attributeArray = [NSMutableArray array];
                }
                [attributeArray addObject:conditionalProperty];
            }
            else
            {
                if( !commaSeperatedStringValueList ) {
                    commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:attributeValueObject];
                } else {
                    [commaSeperatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,attributeValueObject];
                }
            }
        }
        else if( [attributeValueObject isKindOfClass:[NSNumber class]] )
        {
            NSString* stringValue = [attributeValueObject stringValue];
            if( !commaSeperatedStringValueList ) {
                commaSeperatedStringValueList = [[NSMutableString alloc] initWithString:stringValue];
            } else {
                [commaSeperatedStringValueList appendFormat:@"%@%@",kIX_COMMA_SEPERATOR,stringValue];
            }
        }
        else
        {
            IX_LOG_WARN(@"WARNING from %@ in %@ : Property value array for %@ does not have a dictionary objects",THIS_FILE,THIS_METHOD,attributeName);
        }
    }
    
    if( [commaSeperatedStringValueList length] > 0 )
    {
        IXAttribute* commaSeperatedProperty = [IXAttribute attributeWithAttributeName:attributeName rawValue:commaSeperatedStringValueList];
        [commaSeperatedProperty setWasAnArray:YES];
        if( commaSeperatedProperty )
        {
            if( attributeArray == nil )
            {
                attributeArray = [NSMutableArray array];
            }
            [attributeArray addObject:commaSeperatedProperty];
        }
    }
    return attributeArray;
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
            [eval setAttribute:self];
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
        for( IXBaseEvaluation* copiedEvaluation in [copiedProperty evaluations] )
        {
            [copiedEvaluation setAttribute:copiedProperty];
        }
    }
    return copiedProperty;
}

-(void)parseAttribute
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
            if( error ) {
                IX_LOG_ERROR(@"ERROR: Evaluation regex invalid with error: %@.",[error description]);
            }
        });
        
        NSArray* matchesInStaticText = [evaluationMainComponentsRegex matchesInString:propertiesStaticText
                                                                             options:0
                                                                               range:NSMakeRange(0, [propertiesStaticText length])];
        if( [matchesInStaticText count] )
        {
            __block NSUInteger numberOfCharactersRemoved = 0;
            __block NSMutableArray* propertiesEvaluations = nil;
            __block NSMutableString* mutableStaticText = [[NSMutableString alloc] initWithString:propertiesStaticText];
            
            for( NSTextCheckingResult* matchInEvaluationString in matchesInStaticText )
            {
                IXBaseEvaluation* eval = [IXBaseEvaluation evaluationFromString:propertiesStaticText
                                                               textCheckingResult:matchInEvaluationString];
                if( eval )
                {
                    [eval setAttribute:self];
                    
                    if( !propertiesEvaluations )
                    {
                        propertiesEvaluations = [[NSMutableArray alloc] init];
                    }
                    
                    [propertiesEvaluations addObject:eval];
                    
                    NSRange evalRange = [matchInEvaluationString rangeAtIndex:0];
                    evalRange.location = evalRange.location - numberOfCharactersRemoved;
                    [mutableStaticText replaceCharactersInRange:evalRange withString:kIX_EMPTY_STRING];
                    numberOfCharactersRemoved += evalRange.length;
                }
            }
            
            [self setStaticText:mutableStaticText];
            [self setEvaluations:propertiesEvaluations];
        }
        else
        {
            [self setStaticText:propertiesStaticText];
            [self setEvaluations:nil];
        }
    }
}

-(void)setAttributeContainer:(IXAttributeContainer *)attributeContainer
{
    _attributeContainer = attributeContainer;
    
    [[self conditionalProperty] setAttributeContainer:_attributeContainer];
    [[self elseProperty] setAttributeContainer:_attributeContainer];
    
    for( IXBaseEvaluation *eval in [self evaluations] )
    {
        for( IXAttribute *attribute in [eval parameters] )
        {
            [attribute setAttributeContainer:_attributeContainer];
        }
    }
}

-(NSString*)getAttributeValue
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
            
            NSString *evaluationsValue = [eval evaluateAndApplyFunction];
            if( evaluationsValue == nil )
            {
                evaluationsValue = kIX_EMPTY_STRING;
            }            
            [weakString insertString:evaluationsValue atIndex:evalRange.location + newCharsAdded];
            newCharsAdded += [evaluationsValue length] - evalRange.length;
        }];
    }
    
    return returnString;
}

@end
