//
//  IXPropertyBag.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IXConstants.h"

@class IXProperty;
@class IXBaseObject;
@class IXSandbox;
@class IXSizePercentageContainer;

typedef void(^IXPropertyContainerImageSuccessCompletedBlock)(UIImage *image);
typedef void(^IXPropertyContainerImageFailedCompletedBlock)(NSError *error);

@interface IXPropertyContainer : NSObject <NSCopying>

@property (nonatomic,weak) IXBaseObject* ownerObject;

+(instancetype)propertyContainerWithJSONDict:(NSDictionary*)propertyDictionary;

-(BOOL)hasLayoutProperties;

-(void)addProperty:(IXProperty*)property;
-(void)addProperty:(IXProperty*)property replaceOtherPropertiesWithTheSameName:(BOOL)replaceOtherProperties;
-(void)addProperties:(NSArray*)properties;
-(void)addProperties:(NSArray*)properties replaceOtherPropertiesWithTheSameName:(BOOL)replaceOtherProperties;
-(void)addPropertiesFromPropertyContainer:(IXPropertyContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding replaceOtherPropertiesWithTheSameName:(BOOL)replaceOtherProperties;

-(NSDictionary*)getAllPropertiesStringValues;
-(BOOL)propertyExistsForPropertyNamed:(NSString*)propertyName;

-(NSString*)getStringPropertyValue:(NSString*)propertyName defaultValue:(NSString*)defaultValue;
-(BOOL)getBoolPropertyValue:(NSString*)propertyName defaultValue:(BOOL)defaultValue;
-(int)getIntPropertyValue:(NSString*)propertyName defaultValue:(int)defaultValue;
-(float)getFloatPropertyValue:(NSString*)propertyName defaultValue:(float)defaultValue;
-(float)getSizeValue:(NSString*)propertyName maximumSize:(float)maxSize defaultValue:(float)defaultValue;
-(UIColor*)getColorPropertyValue:(NSString*)propertyName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeSeperatedArrayListValue:(NSString*)propertyName defaultValue:(NSArray*)defaultValue;
-(void)getImageProperty:(NSString*)propertyName successBlock:(IXPropertyContainerImageSuccessCompletedBlock)successBlock failBlock:(IXPropertyContainerImageFailedCompletedBlock)failBlock;
-(void)getImageProperty:(NSString*)propertyName successBlock:(IXPropertyContainerImageSuccessCompletedBlock)successBlock failBlock:(IXPropertyContainerImageFailedCompletedBlock)failBlock shouldRefreshCachedImage:(BOOL)refreshCachedImage;
-(UIFont*)getFontPropertyValue:(NSString*)propertyName defaultValue:(UIFont*)defaultValue;
-(NSURL*)getURLPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue;
-(NSString*)getPathPropertyValue:(NSString*)propertyName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;

+(void)storeImageInCache:(UIImage*)image withImageURL:(NSURL*)imageURL toDisk:(BOOL)toDisk;

@end
