//
//  IxProperty.m
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxProperty.h"

#import "IxPropertyContainer.h"
#import "IxBaseShortCode.h"
#import "IxPropertyParser.h"

@interface IxProperty ()

@property (nonatomic,copy) NSString* propertyValue;

@end

@implementation IxProperty

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
        _propertyContainer = nil;
        
        _originalString = [rawValue copy];
        _rawValue = [rawValue copy];
        _propertyName = [propertyName copy];
        
        [IxPropertyParser parseIxPropertyIntoComponents:self];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    IxProperty* copiedProperty = [[[self class] allocWithZone:zone] init];
    
    [copiedProperty setPropertyContainer:[self propertyContainer]];
    [copiedProperty setRawValue:[self rawValue]];
    [copiedProperty setStaticText:[self staticText]];
    [copiedProperty setPropertyValue:[self propertyValue]];
    [copiedProperty setShortCodes:[[NSMutableArray alloc] initWithArray:[self shortCodes] copyItems:YES]];

    return copiedProperty;
}

-(NSString*)getPropertyValue
{
    // FIXME: We need to get the shortcode values and add them back into the static text then return that value.
    // ALSO: Could actually override this method in some subclasses so we dont have to evaluate. (or check if we need to everytime)
    
    return [self rawValue];
}

@end
