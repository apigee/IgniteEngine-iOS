//
//  IXBaseConditionalObject.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
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

#import "IXBaseConditionalObject.h"

#import "IXAppManager.h"
#import "IXAttribute.h"
#import "IXBaseObject.h"

// NSCoding Key Constants
static NSString* const kIXConditionalPropertyNSCodingKey = @"conditionalProperty";
static NSString* const kIXElsePropertyNSCodingKey = @"elseProperty";
static NSString* const kIXInterfaceOrientationMaskNSCodingKey = @"interfaceOrientationMask";

@implementation IXBaseConditionalObject

-(instancetype)init
{
    return [self initWithInterfaceOrientationMask:UIInterfaceOrientationMaskAll
                              conditionalProperty:nil];
}

+(instancetype)baseConditionalObjectWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                                             conditionalProperty:(IXAttribute*)conditionalProperty
{
    return [[[self class] alloc] initWithInterfaceOrientationMask:interfaceOrientationMask
                                              conditionalProperty:conditionalProperty];
}

-(id)copyWithZone:(NSZone *)zone
{
    IXBaseConditionalObject* copiedObject = [[[self class] allocWithZone:zone] initWithInterfaceOrientationMask:[self interfaceOrientationMask]
                                                                                            conditionalProperty:[[self valueIfTrue] copy]];
    [copiedObject setValueIfFalse:[[self valueIfFalse] copy]];
    return copiedObject;
}

-(instancetype)initWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                            conditionalProperty:(IXAttribute*)conditionalProperty
{
    self = [super init];
    if( self )
    {
        _interfaceOrientationMask = interfaceOrientationMask;
        _valueIfTrue = conditionalProperty;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    IXBaseConditionalObject* baseConditionalObject = [self initWithInterfaceOrientationMask:[aDecoder decodeIntegerForKey:kIXInterfaceOrientationMaskNSCodingKey]
                                                                        conditionalProperty:[aDecoder decodeObjectForKey:kIXConditionalPropertyNSCodingKey]];
    [baseConditionalObject setValueIfFalse:[aDecoder decodeObjectForKey:kIXElsePropertyNSCodingKey]];
    return baseConditionalObject;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:[self interfaceOrientationMask] forKey:kIXInterfaceOrientationMaskNSCodingKey];
    [aCoder encodeObject:[self valueIfTrue] forKey:kIXConditionalPropertyNSCodingKey];
    [aCoder encodeObject:[self valueIfFalse] forKey:kIXElsePropertyNSCodingKey];
}

-(BOOL)isOrientationMaskValidForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL orientationIsValid = YES;
    if( [self interfaceOrientationMask] != UIInterfaceOrientationMaskAll )
    {
        if( UIInterfaceOrientationIsPortrait(interfaceOrientation) )
        {
            // If the current orientation is Portrait check to see if this property is for portrait orientation
            orientationIsValid = ([self interfaceOrientationMask] == UIInterfaceOrientationMaskPortrait);
        }
        else
        {
            // If the current orientation is not Portrait check to see if this property is for landscape orientation
            orientationIsValid = ([self interfaceOrientationMask] == UIInterfaceOrientationMaskLandscape);
        }
    }
    return orientationIsValid;
}

-(BOOL)isConditionalTrue
{
    BOOL conditionalPropertyEvaluatesTrue = YES;
    if( [self valueIfTrue] != nil )
    {
        NSString* conditionalPropertyValue = [[self valueIfTrue] attributeStringValue];
        if( conditionalPropertyValue && [conditionalPropertyValue length] > 0 )
        {
            NSString* evaluationResult = [[IXAppManager sharedAppManager] evaluateJavascript:conditionalPropertyValue];
            
            conditionalPropertyEvaluatesTrue = !( evaluationResult == nil || [evaluationResult length] <= 0 || [evaluationResult isEqualToString:kIX_ZERO] || [evaluationResult isEqualToString:kIX_FALSE] );
        }
    }
    return conditionalPropertyEvaluatesTrue;
}

-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation
{
    return [self isConditionalTrue] && [self isOrientationMaskValidForOrientation:interfaceOrientation];
}

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue
{
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
    if( [orientationValue isKindOfClass:[NSString class]] )
    {
        if( [orientationValue isEqualToString:kIX_LANDSCAPE] )
        {
            mask = UIInterfaceOrientationMaskLandscape;
        }
        else if( [orientationValue isEqualToString:kIX_PORTRAIT] )
        {
            mask = UIInterfaceOrientationMaskPortrait;
        }
    }
    return mask;
}

@end
