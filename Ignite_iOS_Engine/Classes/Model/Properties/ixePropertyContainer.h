//
//  ixePropertyBag.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ixeConstants.h"

@class ixeProperty;
@class ixeBaseObject;
@class ixeSandbox;
@class ixeSizePercentageContainer;

@interface ixePropertyContainer : NSObject

@property (nonatomic,weak) ixeSandbox* sandbox;

// FINISHED - But unuseable until finish the ixeProperty class.

-(void)addProperty:(ixeProperty*)property;
-(void)addPropertiesFromPropertyContainer:(ixePropertyContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding;
-(NSDictionary*)getAllPropertiesStringValues;
-(BOOL)propertyExistsForPropertyNamed:(NSString*)propertyName;

-(NSString*)getStringPropertyValue:(NSString*)propertyName defaultValue:(NSString*)defaultValue;
-(BOOL)getBoolPropertyValue:(NSString*)propertyName defaultValue:(BOOL)defaultValue;
-(int)getIntPropertyValue:(NSString*)propertyName defaultValue:(int)defaultValue;
-(float)getFloatPropertyValue:(NSString*)propertyName defaultValue:(float)defaultValue;
-(ixeSizePercentageContainer*)getSizePercentageContainer:(NSString*)propertyName defaultValue:(CGFloat)defaultValue;
-(UIColor*)getColorPropertyValue:(NSString*)propertyName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue;

#warning METHODS NOT DONE YET
-(NSString*)getPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;
-(UIFont*)getFontPropertyValue:(NSString*)propertyName defaultValue:(UIFont*)defaultValue;

@end
