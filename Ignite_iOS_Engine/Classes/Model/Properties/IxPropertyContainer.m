//
//  IXPropertyBag.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXPropertyContainer.h"

#import "IXAppManager.h"
#import "IXProperty.h"
#import "IXControlLayoutInfo.h"

#import "ColorUtils.h"

@interface IXPropertyContainer ()

@property (nonatomic,strong) NSMutableDictionary* propertiesDict;

@end

@implementation IXPropertyContainer

-(id)init
{
    self = [super init];
    if( self )
    {
        _sandbox = nil;
        _propertiesDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSMutableArray*)propertiesForPropertyNamed:(NSString*)propertyName
{
    return [[self propertiesDict] objectForKey:propertyName];
}

-(BOOL)propertyExistsForPropertyNamed:(NSString*)propertyName
{
    return ([self getPropertyToEvaluate:propertyName] != nil);
}

-(void)addProperty:(IXProperty*)property
{
    NSString* propertyName = [property propertyName];
    if( property == nil || propertyName == nil )
    {
        NSLog(@"ERROR: TRYING TO ADD PROPERTY THAT IS NIL OR PROPERTIES NAME IS NIL");
        return;
    }
    
    [property setPropertyContainer:self];
    
    NSMutableArray* propertyArray = [self propertiesForPropertyNamed:propertyName];
    if( propertyArray == nil )
    {
        propertyArray = [[NSMutableArray alloc] initWithObjects:property, nil];
        [[self propertiesDict] setObject:propertyArray forKey:propertyName];
    }
    else if( ![propertyArray containsObject:property] )
    {
        [propertyArray addObject:property];
    }
}

-(void)addPropertiesFromPropertyContainer:(IXPropertyContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding
{
    if( evaluateBeforeAdding )
    {
        NSArray* propertyNames = [[propertyContainer propertiesDict] allKeys];
        for( NSString* propertyName in propertyNames )
        {
            NSString* propertyValue = [propertyContainer getStringPropertyValue:propertyName defaultValue:@""];
            IXProperty* property = [[IXProperty alloc] initWithPropertyName:propertyName rawValue:propertyValue];
            [self addProperty:property];
        }
    }
    else
    {
        // TODO: Probably should be actually copying the properties not just adding them.
        NSArray* propertyNames = [[propertyContainer propertiesDict] allKeys];
        for( NSString* propertyName in propertyNames )
        {
            NSArray* propertyArray = [propertyContainer propertiesForPropertyNamed:propertyName];
            for( IXProperty* property in propertyArray )
            {
                [self addProperty:property];
            }
        }
    }
}

-(NSDictionary*)getAllPropertiesStringValues
{
    NSMutableDictionary* returnDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray* propertyNames = [[self propertiesDict] allKeys];
    for( NSString* propertyName in propertyNames )
    {
        NSString* propertyValue = [self getStringPropertyValue:propertyName defaultValue:@""];
        
        [returnDictionary setObject:propertyValue forKey:propertyName];
    }
    
    return returnDictionary;
}

-(IXProperty*)getPropertyToEvaluate:(NSString*)propertyName
{
    if( propertyName == nil )
        return nil;
    
    IXProperty* propertyToEvaluate = nil;
    NSArray* propertyArray = [self propertiesForPropertyNamed:propertyName];
    if( propertyArray != nil || [propertyArray count] > 0 )
    {
        UIInterfaceOrientation currentOrientation = [IXAppManager currentInterfaceOrientation];
        for( IXProperty* property in [[propertyArray reverseObjectEnumerator] allObjects] )
        {
            if( [property areConditionalAndOrientationMaskValid:currentOrientation] )
            {
                propertyToEvaluate = property;
                break;
            }
        }
    }
    return propertyToEvaluate;
}

-(NSString*)getStringPropertyValue:(NSString*)propertyName defaultValue:(NSString*)defaultValue
{
    IXProperty* propertyToEvaluate = [self getPropertyToEvaluate:propertyName];
    NSString* returnValue =  ( propertyToEvaluate != nil ) ? [propertyToEvaluate getPropertyValue] : defaultValue;
    return returnValue;
}

-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:@","];
    }
    return returnArray;
}

-(BOOL)getBoolPropertyValue:(NSString*)propertyName defaultValue:(BOOL)defaultValue
{
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    BOOL returnValue =  ( stringValue != nil ) ? [stringValue boolValue] : defaultValue;
    return returnValue;
}

-(int)getIntPropertyValue:(NSString*)propertyName defaultValue:(int)defaultValue
{
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    int returnValue =  ( stringValue != nil ) ? [stringValue integerValue] : defaultValue;
    return returnValue;
}

-(float)getFloatPropertyValue:(NSString*)propertyName defaultValue:(float)defaultValue
{
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    float returnValue =  ( stringValue != nil ) ? [stringValue floatValue] : defaultValue;
    return returnValue;
}

-(IXSizePercentageContainer*)getSizePercentageContainer:(NSString*)propertyName defaultValue:(CGFloat)defaultValue
{
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    return [IXSizePercentageContainer sizeAndPercentageContainerWithStringValue:stringValue orDefaultValue:defaultValue];
}

-(UIColor*)getColorPropertyValue:(NSString*)propertyName defaultValue:(UIColor*)defaultValue
{
    NSString* stringValue = [self getStringPropertyValue:propertyName defaultValue:nil];
    UIColor* returnValue =  ( stringValue != nil ) ? [UIColor colorWithString:stringValue] : defaultValue;
    return returnValue;
}

-(NSString*)getPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue
{
    // Use this to get IMAGE paths. Then set up a image loader singleton that loads all the images for you.
    // Same with other FILE paths. When a control needs the data from a file use this to get the path to the image and set up a data loader singleton.
    
    return nil;
}

-(UIFont*)getFontPropertyValue:(NSString*)propertyName defaultValue:(UIFont*)defaultValue
{
    return nil;
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString string];
    NSArray* properties = [[self propertiesDict] allKeys];
    for( NSString* propertyKey in properties )
    {
        [description appendFormat:@"%@: %@\n",propertyKey, [self getStringPropertyValue:propertyKey defaultValue:nil]];
    }
    return description;
}

@end
