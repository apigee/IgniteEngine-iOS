//
//  IXBaseConditionalObject.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseConditionalObject.h"

#import "IXAppManager.h"
#import "IXProperty.h"
#import "IXBaseObject.h"

@implementation IXBaseConditionalObject

-(instancetype)init
{
    return [self initWithInterfaceOrientationMask:UIInterfaceOrientationMaskAll
                              conditionalProperty:nil];
}

+(instancetype)baseConditionalObjectWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                                             conditionalProperty:(IXProperty*)conditionalProperty
{
    return [[[self class] alloc] initWithInterfaceOrientationMask:interfaceOrientationMask
                                              conditionalProperty:conditionalProperty];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:[self interfaceOrientationMask] forKey:@"interfaceOrientationMask"];
    [aCoder encodeObject:[self conditionalProperty] forKey:@"conditionalProperty"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithInterfaceOrientationMask:[aDecoder decodeIntegerForKey:@"interfaceOrientationMask"]
                              conditionalProperty:[aDecoder decodeObjectForKey:@"conditionalProperty"]];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithInterfaceOrientationMask:[self interfaceOrientationMask]
                                                           conditionalProperty:[[self conditionalProperty] copy]];
}

-(instancetype)initWithInterfaceOrientationMask:(UIInterfaceOrientationMask)interfaceOrientationMask
                            conditionalProperty:(IXProperty*)conditionalProperty
{
    self = [super init];
    if( self )
    {
        _interfaceOrientationMask = interfaceOrientationMask;
        _conditionalProperty = conditionalProperty;
    }
    return self;
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

-(BOOL)isConditionalValid
{
    BOOL conditionalPropertyIsValid = YES;
    if( [self conditionalProperty] != nil )
    {
        NSString* conditionalPropertyValue = [[self conditionalProperty] getPropertyValue];
        if( conditionalPropertyValue && [conditionalPropertyValue length] > 0 )
        {
            NSString* conditionalPropertyValueReturned = [[IXAppManager sharedAppManager] evaluateJavascript:conditionalPropertyValue];
            
            conditionalPropertyIsValid = !( conditionalPropertyValueReturned == nil || [conditionalPropertyValueReturned length] <= 0 || [conditionalPropertyValueReturned isEqualToString:@"0"] || [conditionalPropertyValueReturned isEqualToString:@"false"] );
        }
    }
    return conditionalPropertyIsValid;
}

-(BOOL)areConditionalAndOrientationMaskValid:(UIInterfaceOrientation)interfaceOrientation
{
    return [self isConditionalValid] && [self isOrientationMaskValidForOrientation:interfaceOrientation];
}

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue
{
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
    if( [orientationValue isKindOfClass:[NSString class]] )
    {
        if( [orientationValue isEqualToString:@"landscape"] )
        {
            mask = UIInterfaceOrientationMaskLandscape;
        }
        else if( [orientationValue isEqualToString:@"portrait"] )
        {
            mask = UIInterfaceOrientationMaskPortrait;
        }
    }
    return mask;
}

@end
