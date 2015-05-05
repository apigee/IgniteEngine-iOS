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
-(float)getFloatValueForAttribute:(NSString*)attributeName defaultValue:(float)defaultValue;
// TODO: Should this be deprecated in favor of the IXSize method above?
-(float)getSizeValueForAttribute:(NSString*)attributeName maximumSize:(float)maxSize defaultValue:(float)defaultValue;
-(UIColor*)getColorValueForAttribute:(NSString*)attributeName defaultValue:(UIColor*)defaultValue;
-(NSArray*)getCommaSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(NSArray*)getPipeCommaPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue;
-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock;
-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock shouldRefreshCachedImage:(BOOL)refreshCachedImage;
-(UIFont*)getFontValueForAttribute:(NSString*)attributeName defaultValue:(UIFont*)defaultValue;
-(NSURL*)getURLValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue;
-(NSString*)getPathValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue;

+(void)storeImageInCache:(UIImage*)image withImageURL:(NSURL*)imageURL toDisk:(BOOL)toDisk;

@end
