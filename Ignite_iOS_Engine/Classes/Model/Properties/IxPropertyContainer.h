//
//  IxPropertyBag.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IxConstants.h"

@class IxProperty;
@class IxBaseObject;
@class IxSandbox;
@class IxSizePercentageContainer;

@interface IxPropertyContainer : NSObject

@property (nonatomic,weak) IxSandbox* sandbox;

// FINISHED - But unuseable until finish the IxProperty class.

-(void)addProperty:(IxProperty*)property;
-(void)addPropertiesFromPropertyContainer:(IxPropertyContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding;
-(NSDictionary*)getAllPropertiesStringValues;
-(BOOL)propertyExistsForPropertyNamed:(NSString*)propertyName;

-(NSString*)getStringPropertyValue:(NSString*)propertyName defaultValue:(NSString*)defaultValue;
-(BOOL)getBoolPropertyValue:(NSString*)propertyName defaultValue:(BOOL)defaultValue;
-(int)getIntPropertyValue:(NSString*)propertyName defaultValue:(int)defaultValue;
-(float)getFloatPropertyValue:(NSString*)propertyName defaultValue:(float)defaultValue;
-(IxSizePercentageContainer*)getSizePercentageContainer:(NSString*)propertyName defaultValue:(CGFloat)defaultValue;
-(UIColor*)getColorPropertyValue:(NSString*)propertyName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue;

#warning METHODS NOT DONE YET
-(NSString*)getPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;
-(UIFont*)getFontPropertyValue:(NSString*)propertyName defaultValue:(UIFont*)defaultValue;

@end
