//
//  IXAttributeBag.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
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

+(instancetype)attributeContainerWithJSONDict:(id)propertyDictionary;

-(BOOL)hasLayoutAttributes;

-(void)removeAllAttributes;

-(void)addAttribute:(IXAttribute*)property;
-(void)addAttribute:(IXAttribute*)property replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes;
-(void)addAttributes:(NSArray*)Attributes;
-(void)addAttributes:(NSArray*)Attributes replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes;
-(void)addAttributesFromContainer:(IXAttributeContainer*)propertyContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes;
-(void)removeAttributeNamed:(NSString*)attributeName;

-(NSDictionary*)getAllAttributesURLValues;
-(NSDictionary*)getAllAttributesAsDictionary;
-(NSDictionary*)getAllAttributesAsDictionaryWithURLEncodedValues:(BOOL)urlEncodeValues;
-(NSDictionary*)getAllAttributesAsDictionaryWithDotNotation;
-(NSDictionary*)getAllAttributesAsDictionaryWithDotNotationAndURLEncodedValues:(BOOL)urlEncodeValues;
-(BOOL)attributeExistsForName:(NSString*)attributeName;

-(NSString*)getStringValueForAttribute:(NSString*)attributeName defaultValue:(NSString*)defaultValue;
-(IXSize*)getSizeValueForAttributeWithPrefix:(NSString*)prefix;
-(BOOL)getBoolValueForAttribute:(NSString*)attributeName defaultValue:(BOOL)defaultValue;
-(int)getIntValueForAttribute:(NSString*)attributeName defaultValue:(int)defaultValue;
-(CGFloat)getFloatValueForAttribute:(NSString*)attributeName defaultValue:(CGFloat)defaultValue;
// TODO: Upgrade this and merge into IXSize
-(CGFloat)getSizeValueForAttribute:(NSString*)attributeName maximumSize:(CGFloat)maxSize defaultValue:(CGFloat)defaultValue;
-(UIColor*)getColorValueForAttribute:(NSString*)attributeName defaultValue:(UIColor*)defaultValue;
-(UIFont*)getFontValueForAttribute:(NSString*)attributeName defaultValue:(UIFont*)defaultValue;
-(NSArray*)getCommaSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeCommaPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSURL*)getURLValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue;
-(NSString*)getPathValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;

/*
 A note on attribute retrieval: in 0.1.2, methods have been added to allow
 for retriving an attribute value by defining an array of possible attribute
 names. As these are obviously more process intensive, only use them when
 deprecating an attribute is required. Expect to remove your deprecation in
 future versions and revert back to the standard attribute retrieval methods.
 */

-(NSString*)getStringValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(NSString*)defaultValue;
-(BOOL)getBoolValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(BOOL)defaultValue;
-(int)getIntValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(int)defaultValue;
-(CGFloat)getFloatValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(CGFloat)defaultValue;
-(UIColor*)getColorValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(UIColor*)defaultValue;
-(UIFont*)getFontValueForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(UIFont*)defaultValue;
-(NSArray*)getCommaSeparatedArrayOfValuesForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeSeparatedArrayOfValuesForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeCommaPipeSeparatedArrayOfValuesForLegacyAttributes:(NSArray*)legacyAttributes defaultValue:(NSArray*)defaultValue;
-(NSURL*)getURLValueForLegacyAttributes:(NSArray*)legacyAttributes basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue;
-(NSString*)getPathValueForLegacyAttributes:(NSArray*)legacyAttributes basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;

-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock;
-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock shouldRefreshCachedImage:(BOOL)refreshCachedImage;
+(void)storeImageInCache:(UIImage*)image withImageURL:(NSURL*)imageURL toDisk:(BOOL)toDisk;

@end
