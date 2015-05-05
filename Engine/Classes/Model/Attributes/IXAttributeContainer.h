//
//  IXPropertyBag.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IXConstants.h"
#import "IXSize.h"

@class IXAttribute;
@class IXBaseObject;
@class IXSandbox;
@class IXSizePercentageContainer;

typedef void(^IXAttributeContainerImageSuccessCompletedBlock)(UIImage *image);
typedef void(^IXAttributeContainerImageFailedCompletedBlock)(NSError *error);

@interface IXAttributeContainer : NSObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXBaseObject* ownerObject;

+(instancetype)attributeContainerFromJSONDict:(NSDictionary*)attributeDictionary;

-(BOOL)hasLayoutProperties;

-(void)removeAllAttributes;

-(void)addAttribute:(IXAttribute*)attribute;
-(void)addAttribute:(IXAttribute*)attribute replaceOtherAttributesWithTheSameName:(BOOL)replaceOtherAttributes;
-(void)addAttributes:(NSArray*)attributes;
-(void)addAttributes:(NSArray*)attributes replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes;
-(void)addAttributesFromAttributeContainer:(IXAttributeContainer*)attributeContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding replaceOtherAttributesWithTheSameName:(BOOL)replaceOtherAttributes;
-(void)removeAttributeNamed:(NSString*)attributeName;

-(NSDictionary*)getAllAttributesURLValues;
-(NSDictionary*)getAllAttributesObjectValues;
-(NSDictionary*)getAllAttributesObjectValuesURLEncoded:(BOOL)urlEncodeStringValues;
-(NSDictionary*)getAllAttributesStringValues:(BOOL)urlEncodeValues;
-(BOOL)attributeExistsWithName:(NSString*)attributeName;

-(NSString*)getStringAttributeValue:(NSString*)attributeName defaultValue:(NSString*)defaultValue;
-(IXSize*)getSizeAttributeValueWithPrefix:(NSString*)prefix;
-(BOOL)getBoolPropertyValue:(NSString*)attributeName defaultValue:(BOOL)defaultValue;
-(int)getIntAttributeValue:(NSString*)attributeName defaultValue:(int)defaultValue;
-(float)getFloatAttributeValue:(NSString*)attributeName defaultValue:(float)defaultValue;
-(float)getSizeValue:(NSString*)attributeName maximumSize:(float)maxSize defaultValue:(float)defaultValue;
-(UIColor*)getColorAttributeValue:(NSString*)attributeName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeCommaPipeSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock;
-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock shouldRefreshCachedImage:(BOOL)refreshCachedImage;
-(UIFont*)getFontAttributeValue:(NSString*)attributeName defaultValue:(UIFont*)defaultValue;
-(NSURL*)getURLPathAttributeValue:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue;
-(NSString*)getPathAttributeValue:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;

+(void)storeImageInCache:(UIImage*)image withImageURL:(NSURL*)imageURL toDisk:(BOOL)toDisk;

@end
