//
//  IXAttributeBag.m
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

#import "IXAttributeContainer.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXAttribute.h"
#import "IXControlLayoutInfo.h"
#import "IXPathHandler.h"

#import "IXBaseObject.h"
#import "ColorUtils.h"
#import "SDWebImageManager.h"
#import "NSObject+IXAdditions.h"
#import "UIImage+IXAdditions.h"
#import "UIFont+IXAdditions.h"
#import "IXLogger.h"

IX_STATIC_CONST_STRING kIXWidth = @"size.w";
IX_STATIC_CONST_STRING kIXWidthX = @"size.width";
IX_STATIC_CONST_STRING kIXHeight = @"size.h";
IX_STATIC_CONST_STRING kIXHeightX = @"size.height";
IX_STATIC_CONST_STRING kIXSize = @"size";

// NSCoding Key Constants
static NSString* const kIXAttributesDictNSCodingKey = @"attributesDict";

@interface IXAttributeContainer ()

@property (nonatomic,strong) NSMutableDictionary* attributesDict;

@end

@implementation IXAttributeContainer

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _ownerObject = nil;
        _attributesDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXAttributeContainer* attributeContainerCopy = [[[self class] allocWithZone:zone] init];
    [attributeContainerCopy setOwnerObject:[self ownerObject]];
    [[self attributesDict] enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSArray* attributeArray, BOOL *stop) {
        NSMutableArray* attributeArrayCopy = [[NSMutableArray alloc] initWithArray:attributeArray copyItems:YES];
        [attributeContainerCopy addAttributes:attributeArrayCopy];
    }];
    return attributeContainerCopy;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self attributesDict] forKey:kIXAttributesDictNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if( self )
    {        
        NSDictionary* encodedAttributesDictionary = [aDecoder decodeObjectForKey:kIXAttributesDictNSCodingKey];
        for( NSArray* attributesArray in [encodedAttributesDictionary allValues] )
        {
            [self addAttributes:attributesArray replaceOtherAttributesWithSameName:NO];
        }
    }
    return self;
}

+(instancetype)attributeContainerWithJSONDict:(id)attributeJSONDictionary
{
    IXAttributeContainer* attributeContainer = nil;
    if( [attributeJSONDictionary isKindOfClass:[NSDictionary class]] && [[attributeJSONDictionary allValues] count] > 0 )
    {
        attributeContainer = [[[self class] alloc] init];
        [IXAttributeContainer populateAttributeContainer:attributeContainer withAttributeJSONDict:attributeJSONDictionary keyPrefix:nil];
    } else if ([attributeJSONDictionary isKindOfClass:[NSString class]]) {
        attributeContainer = [[[self class] alloc] init];
        NSDictionary* dictionaryFromJSONString = (NSDictionary*)[NSObject ix_dictionaryFromJSONString:attributeJSONDictionary];
        [IXAttributeContainer populateAttributeContainer:attributeContainer withAttributeJSONDict:dictionaryFromJSONString keyPrefix:nil];
    }
    return attributeContainer;
}

+(void)populateAttributeContainer:(IXAttributeContainer*)attributeContainer withAttributeJSONDict:(NSDictionary*)attributeJSONDictionary keyPrefix:(NSString*)keyPrefix
{
    [attributeJSONDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString* attributesKey = key;
        if( [keyPrefix length] > 0 )
        {
            attributesKey = [NSString stringWithFormat:@"%@%@%@",keyPrefix,kIX_PERIOD_SEPERATOR,key];
        }
        
        if( [obj isKindOfClass:[NSArray class]] ) {
            [attributeContainer addAttributes:[IXAttribute attributeWithAttributeName:attributesKey attributeValueJSONArray:obj]];
        }
        else if( [obj isKindOfClass:[NSDictionary class]] ) {
            [IXAttributeContainer populateAttributeContainer:attributeContainer withAttributeJSONDict:obj keyPrefix:attributesKey];
        }
        else {
            [attributeContainer addAttribute:[IXAttribute attributeWithAttributeName:attributesKey jsonObject:obj]];
        }
    }];
}

-(NSMutableArray*)attributesForAttributeNamed:(NSString*)attributeName
{
    return [self attributesDict][attributeName];
}

-(BOOL)attributeExistsForName:(NSString*)attributeName
{
    return ([self getAttributeToEvaluate:attributeName] != nil);
}

-(BOOL)hasLayoutAttributes
{
    BOOL hasLayoutAttributes = NO;
    for( NSString* attributeName in [[self attributesDict] allKeys] )
    {
        hasLayoutAttributes = [IXControlLayoutInfo doesAttributeTriggerLayout:attributeName];
        if( hasLayoutAttributes )
            break;
    }
    return hasLayoutAttributes;
}

-(void)removeAllAttributes
{
    [[self attributesDict] removeAllObjects];
}

-(void)addAttributes:(NSArray*)attributes
{
    [self addAttributes:attributes replaceOtherAttributesWithSameName:NO];
}

-(void)addAttributes:(NSArray*)attributes replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes
{
    for( IXAttribute* attribute in attributes )
    {
        [self addAttribute:attribute replaceOtherAttributesWithSameName:replaceOtherAttributes];
    }
}

-(void)addAttribute:(IXAttribute*)property
{
    [self addAttribute:property replaceOtherAttributesWithSameName:NO];
}

-(void)addAttribute:(IXAttribute*)attribute replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes
{
    NSString* attributeName = [attribute attributeName];
    if( attribute == nil || attributeName == nil )
    {
        IX_LOG_ERROR(@"ERROR from %@ in %@: Tried to add an undefined attribute or attribute's name is nil",THIS_FILE,THIS_METHOD);
        return;
    }
    
    [attribute setAttributeContainer:self];
    
    NSMutableArray* attributeArray = [self attributesForAttributeNamed:attributeName];
    if( attributeArray == nil )
    {
        attributeArray = [[NSMutableArray alloc] initWithObjects:attribute, nil];
        [self attributesDict][attributeName] = attributeArray;
    }
    else if( replaceOtherAttributes )
    {
        [attributeArray removeAllObjects];
        [attributeArray addObject:attribute];
    }
    else if( ![attributeArray containsObject:attribute] )
    {
        [attributeArray addObject:attribute];
    }
}

-(void)addAttributesFromContainer:(IXAttributeContainer*)attributeContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding replaceOtherAttributesWithSameName:(BOOL)replaceOtherAttributes
{
    NSArray* attributeNames = [[attributeContainer attributesDict] allKeys];
    for( NSString* attributeName in attributeNames )
    {
        if( evaluateBeforeAdding )
        {
            NSString* attributeValue = [attributeContainer getStringValueForAttribute:attributeName defaultValue:nil];
            if( attributeValue )
            {
                IXAttribute* attribute = [[IXAttribute alloc] initWithAttributeName:attributeName rawValue:attributeValue];
                [self addAttribute:attribute replaceOtherAttributesWithSameName:replaceOtherAttributes];
            }
        }
        else
        {
            NSMutableArray* attributeArray = [[NSMutableArray alloc] initWithArray:[attributeContainer attributesForAttributeNamed:attributeName]
                                                                        copyItems:YES];
            if( replaceOtherAttributes ) {
                for( IXAttribute* attribute in attributeArray ) {
                    [attribute setAttributeContainer:self];
                }
                self.attributesDict[attributeName] = attributeArray;
            } else {
                [self addAttributes:attributeArray replaceOtherAttributesWithSameName:false];
            }
        }
    }
}

-(void)removeAttributeNamed:(NSString *)attributeName
{
    NSMutableArray* attributeArray = [self attributesForAttributeNamed:attributeName];
    [attributeArray removeAllObjects];
}


-(NSDictionary*)dictionaryWithKey:(NSString*)key subKeys:(NSMutableArray*)subKeys lastObjectValue:(NSString*)lastObjectValue
{
    NSDictionary* dictionary = nil;
    
    if( [subKeys count] > 0 )
    {
        NSString* nextKey = [subKeys firstObject];
        [subKeys removeObject:nextKey];
        
        NSDictionary* subDictionary = [self dictionaryWithKey:nextKey subKeys:subKeys lastObjectValue:lastObjectValue];
        dictionary = @{key : subDictionary};
    }
    else
    {
        dictionary = @{key : lastObjectValue};
    }
    
    return dictionary;
}

-(void)addValuesFromDictionary:(NSDictionary*)dict1 toMutableDictionary:(NSMutableDictionary*)dict2
{
    [dict1 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if( [obj isKindOfClass:[NSDictionary class]] )
        {
            id objectFromDict2 = [dict2 objectForKey:key];
            if( [objectFromDict2 isKindOfClass:[NSDictionary class]] )
            {
                NSMutableDictionary* mutableObjectFromDict2 = [NSMutableDictionary dictionaryWithDictionary:objectFromDict2];
                
                [self addValuesFromDictionary:obj
                          toMutableDictionary:mutableObjectFromDict2];
                
                [dict2 setObject:mutableObjectFromDict2 forKey:key];
            }
            else
            {
                [dict2 setObject:obj forKey:key];
            }
        }
        else
        {
            [dict2 setObject:obj forKey:key];
        }
        
    }];
}
-(NSDictionary*)getAllAttributesAsDictionary {
    return [self getAllAttributesAsDictionaryWithURLEncodedValues:NO];
}

-(NSDictionary*)getAllAttributesAsDictionaryWithURLEncodedValues:(BOOL)urlEncodeValues
{
    NSMutableDictionary* returnDictionary = nil;
    if( [[[self attributesDict] allKeys] count] > 0 )
    {
        returnDictionary = [[NSMutableDictionary alloc] init];
        
        for( NSString* attributeName in [[self attributesDict] allKeys] )
        {
            NSString* attributeValue = [self getStringValueForAttribute:attributeName defaultValue:kIX_EMPTY_STRING];
            if( urlEncodeValues ) {
                attributeValue = [attributeValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }

            NSMutableArray* attributeNameComponents = [NSMutableArray arrayWithArray:[attributeName componentsSeparatedByString:kIX_PERIOD_SEPERATOR]];
            if( [attributeNameComponents count] > 1 )
            {
                NSString* firstKey = [attributeNameComponents firstObject];
                [attributeNameComponents removeObject:firstKey];
                
                NSString* nextKey = [attributeNameComponents firstObject];
                [attributeNameComponents removeObject:nextKey];
                
                NSDictionary* dictionaryFromPeriodSeperatedKey = [self dictionaryWithKey:nextKey
                                                                                 subKeys:attributeNameComponents
                                                                         lastObjectValue:attributeValue];
                
                NSDictionary* dictionaryInReturnDict = [returnDictionary objectForKey:firstKey];
                
                if( dictionaryInReturnDict )
                {
                    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:dictionaryInReturnDict];
                    
                    [self addValuesFromDictionary:dictionaryFromPeriodSeperatedKey
                              toMutableDictionary:mutableDict];
                    
                    [returnDictionary setObject:mutableDict forKey:firstKey];
                }
                else
                {
                    [returnDictionary setObject:dictionaryFromPeriodSeperatedKey forKey:firstKey];
                }
            }
            else
            {
                IXAttribute* attribute = [self getAttributeToEvaluate:attributeName];
                if( [attribute wasAnArray] )
                {
                    [returnDictionary setObject:[attributeValue componentsSeparatedByString:kIX_COMMA_SEPERATOR] forKey:attributeName];
                }
                else
                {
                        NSData *data = [attributeValue dataUsingEncoding:NSUTF8StringEncoding];
                        if( [data length] > 0 )
                        {
                            NSError __autoreleasing *error;
                            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if( jsonObject != nil && error == nil )
                            {
                                [returnDictionary setObject:jsonObject forKey:attributeName];
                            }
                            else
                            {
                                [returnDictionary setObject:attributeValue forKey:attributeName];
                            }
                        }
                }
            }
        }
    }
    return returnDictionary;
}

-(NSDictionary*)getAllAttributesURLValues
{
    NSMutableDictionary* returnDictionary = nil;
    if( [[[self attributesDict] allKeys] count] > 0 )
    {
        returnDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray* attributeNames = [[self attributesDict] allKeys];
        for( NSString* attributeName in attributeNames )
        {
            NSURL* attributeURL = [self getURLValueForAttribute:attributeName basePath:nil defaultValue:nil];
            if( [[attributeURL absoluteString] length] > 0 )
            {
                [returnDictionary setObject:attributeURL forKey:attributeName];
            }
        }
    }
    return returnDictionary;
}

-(NSDictionary*)getAllAttributesAsDictionaryWithDotNotation {
    return [self getAllAttributesAsDictionaryWithDotNotationAndURLEncodedValues:NO];
}

-(NSDictionary*)getAllAttributesAsDictionaryWithDotNotationAndURLEncodedValues:(BOOL)urlEncodeValues
{
    NSMutableDictionary* returnDictionary = nil;
    if( [[[self attributesDict] allKeys] count] > 0 )
    {
        returnDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray* attributeNames = [[self attributesDict] allKeys];
        for( NSString* attributeName in attributeNames )
        {
            NSString* attributeValue = [self getStringValueForAttribute:attributeName defaultValue:kIX_EMPTY_STRING];
            if( urlEncodeValues ) {
                attributeValue = [attributeValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            if( attributeValue ) {
                [returnDictionary setObject:attributeValue forKey:attributeName];
            }
        }
    }
    return returnDictionary;
}

-(IXAttribute*)getAttributeToEvaluate:(NSString*)attributeName
{
    if( attributeName == nil )
        return nil;
    
    IXAttribute* attributeToEvaluate = nil;
    NSArray* attributeArray = [self attributesForAttributeNamed:attributeName];
    if( [attributeArray count] > 0 )
    {
        UIInterfaceOrientation currentOrientation = [IXAppManager currentInterfaceOrientation];
        for( IXAttribute* attribute in [attributeArray reverseObjectEnumerator] )
        {
            if( [attribute areConditionalAndOrientationMaskValid:currentOrientation] ) {
                attributeToEvaluate = attribute;
            } else if( [attribute valueIfFalse] != nil && [attribute isOrientationMaskValidForOrientation:currentOrientation] ) {
                attributeToEvaluate = [attribute valueIfFalse];
            }

            if( attributeToEvaluate != nil ) {
                break;
            }
        }
    }
    return attributeToEvaluate;
}

-(NSString*)getStringValueForAttribute:(NSString*)attributeName defaultValue:(NSString*)defaultValue
{
    IXAttribute* attributeToEvaluate = [self getAttributeToEvaluate:attributeName];
    NSString* returnValue =  ( attributeToEvaluate != nil ) ? [attributeToEvaluate attributeStringValue] : defaultValue;
    return [returnValue copy];
}

-(IXSize*)getSizeValueForAttributeWithPrefix:(NSString*)prefix
{
    NSString* attributeName = kIXSize;
    NSString* width = kIXWidth;
    NSString* height = kIXHeight;
    NSString* widthX = kIXWidthX;
    NSString* heightX = kIXHeightX;
    
    if (prefix != nil) {
        attributeName = [NSString stringWithFormat:@"%@.%@", prefix, kIXSize];
        width = [NSString stringWithFormat:@"%@.%@", prefix, width];
        height = [NSString stringWithFormat:@"%@.%@", prefix, height];
        widthX = [NSString stringWithFormat:@"%@.%@", prefix, widthX];
        heightX = [NSString stringWithFormat:@"%@.%@", prefix, heightX];
    }
    IXSize* returnSize = [[IXSize alloc] initWithDefaultSize];
    NSArray* sizeArr = [self getCommaSeparatedArrayOfValuesForAttribute:attributeName defaultValue:nil];
    if (sizeArr.count == 2) {
        returnSize.width = sizeArr[0];
        returnSize.height = sizeArr[1];
    } else if (sizeArr.count == 1) {
        returnSize.width = sizeArr[0];
        returnSize.height = sizeArr[0];
    }
    returnSize.width = [self getStringValueForAttribute:width defaultValue:nil] ?: [self getStringValueForAttribute:widthX defaultValue:returnSize.width];
    returnSize.height = [self getStringValueForAttribute:height defaultValue:nil] ?: [self getStringValueForAttribute:heightX defaultValue:returnSize.height];
    return returnSize;
}

-(NSArray*)getCommaSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_COMMA_SEPERATOR];
    }
    return returnArray;
}

-(NSArray*)getPipeCommaPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_PIPECOMMAPIPE_SEPERATOR];
    }
    return returnArray;
}

-(NSArray*)getPipeSeparatedArrayOfValuesForAttribute:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_PIPE_SEPERATOR];
    }
    return returnArray;
}

-(BOOL)getBoolValueForAttribute:(NSString*)attributeName defaultValue:(BOOL)defaultValue
{
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    BOOL returnValue =  ( stringValue != nil ) ? [stringValue boolValue] : defaultValue;
    return returnValue;
}

-(int)getIntValueForAttribute:(NSString*)attributeName defaultValue:(int)defaultValue
{
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    int returnValue =  ( stringValue != nil ) ? (int) [stringValue integerValue] : defaultValue;
    return returnValue;
}

-(float)getFloatValueForAttribute:(NSString*)attributeName defaultValue:(float)defaultValue
{
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    float returnValue =  ( stringValue != nil ) ? [stringValue floatValue] : defaultValue;
    return returnValue;
}

-(float)getSizeValueForAttribute:(NSString*)attributeName maximumSize:(float)maxSize defaultValue:(float)defaultValue
{
    IXSizeValuePercentage sizeValuePercentage = ixSizePercentageValueWithStringOrDefaultValue([self getStringValueForAttribute:attributeName defaultValue:nil], defaultValue);
    float returnValue = ixEvaluateSizeValuePercentageForMaxValue(sizeValuePercentage, maxSize);
    return returnValue;
}

-(UIColor*)getColorValueForAttribute:(NSString*)attributeName defaultValue:(UIColor*)defaultValue
{
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    UIColor* returnValue =  ( stringValue != nil ) ? [UIColor colorWithString:stringValue] : defaultValue;
    return returnValue;
}

+(void)storeImageInCache:(UIImage*)image withImageURL:(NSURL*)imageURL toDisk:(BOOL)toDisk
{
    if( image && [imageURL absoluteString].length > 0 )
    {
        [[[SDWebImageManager sharedManager] imageCache] storeImage:image forKey:[imageURL absoluteString] toDisk:toDisk];
    }
}

-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock
{
    [self getImageAttribute:attributeName successBlock:successBlock failBlock:failBlock shouldRefreshCachedImage:NO];
}

-(void)getImageAttribute:(NSString*)attributeName successBlock:(IXAttributeContainerImageSuccessCompletedBlock)successBlock failBlock:(IXAttributeContainerImageFailedCompletedBlock)failBlock shouldRefreshCachedImage:(BOOL)refreshCachedImage
{
    NSURL* imageURL = [self getURLValueForAttribute:attributeName basePath:nil defaultValue:nil];
    /*
     Added in a fallback so that if images.touch (etc.) don't exist, it tries again with "images.default".
     This way we don't have to specify several of the same image in the JSON.
     - B
    */
    if( imageURL == nil )
    {
        if ([attributeName hasSuffix:@"icon"])
            imageURL = [self getURLValueForAttribute:@"icon" basePath:nil defaultValue:nil];
        if ([attributeName hasPrefix:@"images"])
            imageURL = [self getURLValueForAttribute:@"images.default" basePath:nil defaultValue:nil];
    }
    
    if( imageURL != nil )
    {
        NSString* imageURLPath = [imageURL absoluteString];
        
        if ( [IXPathHandler pathIsAssetsLibrary:imageURLPath] )
        {
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:imageURL
                     resultBlock:^(ALAsset *asset) {
                         
                         ALAssetRepresentation *rep = [asset defaultRepresentation];
                         CGImageRef iref = [rep fullResolutionImage];
                         if (iref)
                         {
                             UIImage* image = [UIImage imageWithCGImage:iref];
                             if( image )
                             {
                                 if( successBlock )
                                 {
                                     successBlock(image);
                                 }
                             }
                         }
                         
                     } failureBlock:^(NSError *err) {
                         IX_LOG_ERROR(@"ERROR from %@ in %@ : Failed to load image from assets-library: %@",THIS_FILE,THIS_METHOD,[err localizedDescription]);
                    }];
        }
        else
        {
            if( !refreshCachedImage && [IXPathHandler pathIsLocal:imageURLPath] )
            {
                UIImage* image = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:[imageURL absoluteString]];
                if( image )
                {
                    if( successBlock )
                    {
                        successBlock(image);
                        return;
                    }
                }            
            }
            
            if( refreshCachedImage )
            {
                [[[SDWebImageManager sharedManager] imageCache] removeImageForKey:[imageURL absoluteString] fromDisk:YES];
            }
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                                                       options:SDWebImageCacheMemoryOnly
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {                                                     
                                                         if (image) {
                                                             if( successBlock )
                                                                 successBlock([UIImage imageWithCGImage:[image CGImage]]);
                                                         } else {
                                                             if( failBlock )
                                                                 failBlock(error);
                                                         }
                                                     }];
        }
    }
    else
    {
        if( failBlock != nil )
        {
            failBlock(nil);
        }
    }
}

-(NSURL*)getURLValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue
{
    NSURL* returnURL = defaultValue;
    NSString* stringSettingValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringSettingValue != nil )
    {
        returnURL = [IXPathHandler normalizedURLPath:stringSettingValue
                                            basePath:basePath
                                            rootPath:[[[self ownerObject] sandbox] rootPath]];
    }
    return returnURL;
}

-(NSString*)getPathValueForAttribute:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue
{
    NSString* returnPath = defaultValue;
    NSString* stringSettingValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringSettingValue != nil )
    {
        returnPath = [IXPathHandler normalizedPath:stringSettingValue
                                          basePath:basePath
                                          rootPath:[[[self ownerObject] sandbox] rootPath]];
    }
    return returnPath;
}

-(UIFont*)getFontValueForAttribute:(NSString*)attributeName defaultValue:(UIFont*)defaultValue
{
    UIFont* returnFont = defaultValue;
    NSString* stringValue = [self getStringValueForAttribute:attributeName defaultValue:nil];
    if( stringValue )
    {
        returnFont = [UIFont ix_fontFromString:stringValue];
        if( returnFont == nil )
        {
            returnFont = defaultValue;
        }
    }
    return returnFont;
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString string];
    NSArray* attributes = [[self attributesDict] allKeys];
    for( NSString* attributeKey in attributes )
    {
        IXAttribute* attributeToEvaluate = [self getAttributeToEvaluate:attributeKey];
        [description appendFormat:@"\t%@: %@",attributeKey, [attributeToEvaluate attributeStringValue]];
        if( [attributeToEvaluate evaluations] )
        {
            [description appendFormat:@" (%@)",[attributeToEvaluate originalString]];
        }
        [description appendString:@"\n"];
    }
    return description;
}

@end
