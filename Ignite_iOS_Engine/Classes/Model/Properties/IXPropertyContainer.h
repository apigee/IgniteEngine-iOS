//
//  IXPropertyBag.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXConstants.h"

@class IXProperty;
@class IXBaseObject;
@class IXSandbox;
@class IXSizePercentageContainer;

typedef void(^IXPropertyContainerImageSuccessCompletedBlock)(UIImage *image);
typedef void(^IXPropertyContainerImageFailedCompletedBlock)(NSError *error);

@interface IXPropertyContainer : NSObject <NSCopying>

@property (nonatomic,weak) IXSandbox* sandbox;

// FINISHED - But unuseable until finish the IXProperty class.

-(void)addProperty:(IXProperty*)property;
-(void)addProperties:(NSArray*)properties;
-(void)addPropertiesFromPropertyContainer:(IXPropertyContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding;

-(NSDictionary*)getAllPropertiesStringValues;
-(BOOL)propertyExistsForPropertyNamed:(NSString*)propertyName;

-(NSString*)getStringPropertyValue:(NSString*)propertyName defaultValue:(NSString*)defaultValue;
-(BOOL)getBoolPropertyValue:(NSString*)propertyName defaultValue:(BOOL)defaultValue;
-(int)getIntPropertyValue:(NSString*)propertyName defaultValue:(int)defaultValue;
-(float)getFloatPropertyValue:(NSString*)propertyName defaultValue:(float)defaultValue;
-(IXSizePercentageContainer*)getSizePercentageContainer:(NSString*)propertyName defaultValue:(CGFloat)defaultValue;
-(UIColor*)getColorPropertyValue:(NSString*)propertyName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue;
-(void)getImageProperty:(NSString*)propertyName successBlock:(IXPropertyContainerImageSuccessCompletedBlock)successBlock failBlock:(IXPropertyContainerImageFailedCompletedBlock)failBlock;

#warning METHODS NOT DONE YET
-(NSString*)getPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;
-(UIFont*)getFontPropertyValue:(NSString*)propertyName defaultValue:(UIFont*)defaultValue;

@end
