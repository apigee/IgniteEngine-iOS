//
//  IXPropertyBag.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
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
#import "UIImage+IXAdditions.h"
#import "UIFont+IXAdditions.h"
#import "IXLogger.h"

IX_STATIC_CONST_STRING kIXWidth = @"size.w";
IX_STATIC_CONST_STRING kIXWidthX = @"size.width";
IX_STATIC_CONST_STRING kIXHeight = @"size.h";
IX_STATIC_CONST_STRING kIXHeightX = @"size.height";
IX_STATIC_CONST_STRING kIXSize = @"size";

// NSCoding Key Constants
static NSString* const kIXPropertiesDictNSCodingKey = @"propertiesDict";

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
    [aCoder encodeObject:[self attributesDict] forKey:kIXPropertiesDictNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if( self )
    {        
        NSDictionary* encodedPropertiesDictionary = [aDecoder decodeObjectForKey:kIXPropertiesDictNSCodingKey];
        for( NSArray* propertiesArray in [encodedPropertiesDictionary allValues] )
        {
            [self addProperties:propertiesArray replaceOtherPropertiesWithTheSameName:NO];
        }
    }
    return self;
}

+(instancetype)attributeContainerFromJSONDict:(NSDictionary*)attributeDictionary
{
    IXAttributeContainer* attributeContainer = nil;
    if( [attributeDictionary isKindOfClass:[NSDictionary class]] && [[attributeDictionary allValues] count] > 0 )
    {
        attributeContainer = [[[self class] alloc] init];
        [IXAttributeContainer populateAttributeContainer:attributeContainer withAttributeJSONDict:attributeDictionary keyPrefix:nil];
    }
    return attributeContainer;
}

+(void)populateAttributeContainer:(IXAttributeContainer*)attributeContainer withAttributeJSONDict:(NSDictionary*)attributeDict keyPrefix:(NSString*)keyPrefix
{
    [attributeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString* propertiesKey = key;
        if( [keyPrefix length] > 0 )
        {
            propertiesKey = [NSString stringWithFormat:@"%@%@%@",keyPrefix,kIX_PERIOD_SEPERATOR,key];
        }
        
        if( [obj isKindOfClass:[NSArray class]] ) {
            [attributeContainer addAttributes:[IXAttribute attributesWithAttributeName:propertiesKey attributeValueArray:obj]];
        }
        else if( [obj isKindOfClass:[NSDictionary class]] ) {
            [IXAttributeContainer populateAttributeContainer:attributeContainer withAttributeJSONDict:obj keyPrefix:propertiesKey];
        }
        else {
            [attributeContainer addAttribute:[IXAttribute attributeWithAttributeName:propertiesKey jsonObject:obj]];
        }
    }];
}

-(NSMutableArray*)propertiesForPropertyNamed:(NSString*)attributeName
{
    return [self attributesDict][attributeName];
}

-(BOOL)attributeExistsWithName:(NSString*)attributeName
{
    return ([self getAttributeToEvaluate:attributeName] != nil);
}

-(BOOL)hasLayoutProperties
{
    BOOL hasLayoutProperties = NO;
    for( NSString* attributeName in [[self attributesDict] allKeys] )
    {
        hasLayoutProperties = [IXControlLayoutInfo doesAttributeTriggerLayout:attributeName];
        if( hasLayoutProperties )
            break;
    }
    return hasLayoutProperties;
}

-(void)removeAllAttributes
{
    [[self attributesDict] removeAllObjects];
}

-(void)addAttributes:(NSArray*)attributes
{
    [self addProperties:attributes replaceOtherPropertiesWithTheSameName:NO];
}

-(void)addProperties:(NSArray*)attributes replaceOtherPropertiesWithTheSameName:(BOOL)replaceOtherProperties
{
    for( IXAttribute* attribute in attributes )
    {
        [self addAttribute:attribute replaceOtherAttributesWithTheSameName:replaceOtherProperties];
    }
}

-(void)addAttribute:(IXAttribute*)attribute
{
    [self addAttribute:attribute replaceOtherAttributesWithTheSameName:NO];
}

-(void)addAttribute:(IXAttribute*)attribute replaceOtherAttributesWithTheSameName:(BOOL)replaceOtherAttributes
{
    NSString* attributeName = [attribute attributeName];
    if( attribute == nil || attributeName == nil )
    {
        IX_LOG_ERROR(@"ERROR from %@ in %@ : TRYING TO ADD PROPERTY THAT IS NIL OR PROPERTIES NAME IS NIL",THIS_FILE,THIS_METHOD);
        return;
    }
    
    [attribute setAttributeContainer:self];
    
    NSMutableArray* attributeArray = [self propertiesForPropertyNamed:attributeName];
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

-(void)addAttributesFromAttributeContainer:(IXAttributeContainer*)attributeContainer evaluateBeforeAdding:(BOOL)evaluateBeforeAdding replaceOtherAttributesWithTheSameName:(BOOL)replaceOtherAttributes
{
    NSArray* attributeNames = [[attributeContainer attributesDict] allKeys];
    for( NSString* attributeName in attributeNames )
    {
        if( evaluateBeforeAdding )
        {
            NSString* attributeValue = [attributeContainer getStringAttributeValue:attributeName defaultValue:nil];
            if( attributeValue )
            {
                IXAttribute* attribute = [[IXAttribute alloc] initWithAttributeName:attributeName rawValue:attributeValue];
                [self addAttribute:attribute replaceOtherAttributesWithTheSameName:replaceOtherAttributes];
            }
        }
        else
        {
            NSMutableArray* attributeArray = [[NSMutableArray alloc] initWithArray:[attributeContainer propertiesForPropertyNamed:attributeName]
                                                                        copyItems:YES];
            if( replaceOtherAttributes ) {
                for( IXAttribute* attribute in attributeArray ) {
                    [attribute setAttributeContainer:self];
                }
                self.attributesDict[attributeName] = attributeArray;
            } else {
                [self addProperties:attributeArray replaceOtherPropertiesWithTheSameName:false];
            }
        }
    }
}

-(void)removeAttributeNamed:(NSString *)attributeName
{
    NSMutableArray* attributeArray = [self propertiesForPropertyNamed:attributeName];
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
-(NSDictionary*)getAllAttributesObjectValues {
    return [self getAllAttributesObjectValuesURLEncoded:NO];
}

-(NSDictionary*)getAllAttributesObjectValuesURLEncoded:(BOOL)urlEncodeStringValues
{
    NSMutableDictionary* returnDictionary = nil;
    if( [[[self attributesDict] allKeys] count] > 0 )
    {
        returnDictionary = [[NSMutableDictionary alloc] init];
        
        for( NSString* attributeName in [[self attributesDict] allKeys] )
        {
            NSString* attributeValue = [self getStringAttributeValue:attributeName defaultValue:kIX_EMPTY_STRING];
            if( urlEncodeStringValues ) {
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
            NSURL* attributeURL = [self getURLPathAttributeValue:attributeName basePath:nil defaultValue:nil];
            if( [[attributeURL absoluteString] length] > 0 )
            {
                [returnDictionary setObject:attributeURL forKey:attributeName];
            }
        }
    }
    return returnDictionary;
}

-(NSDictionary*)getAllAttributesStringValues:(BOOL)urlEncodeValues
{
    NSMutableDictionary* returnDictionary = nil;
    if( [[[self attributesDict] allKeys] count] > 0 )
    {
        returnDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray* attributeNames = [[self attributesDict] allKeys];
        for( NSString* attributeName in attributeNames )
        {
            NSString* attributeValue = [self getStringAttributeValue:attributeName defaultValue:kIX_EMPTY_STRING];
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

-(IXAttribute*)getAttributeToEvaluate:(NSString*)attribute
{
    if( attribute == nil )
        return nil;
    
    IXAttribute* attributeToEvaluate = nil;
    NSArray* attributeArray = [self propertiesForPropertyNamed:attribute];
    if( [attributeArray count] > 0 )
    {
        UIInterfaceOrientation currentOrientation = [IXAppManager currentInterfaceOrientation];
        for( IXAttribute* attribute in [attributeArray reverseObjectEnumerator] )
        {
            if( [attribute areConditionalAndOrientationMaskValid:currentOrientation] ) {
                attributeToEvaluate = attribute;
            } else if( [attribute elseProperty] != nil && [attribute isOrientationMaskValidForOrientation:currentOrientation] ) {
                attributeToEvaluate = [attribute elseProperty];
            }

            if( attributeToEvaluate != nil ) {
                break;
            }
        }
    }
    return attributeToEvaluate;
}

-(NSString*)getStringAttributeValue:(NSString*)attributeName defaultValue:(NSString*)defaultValue
{
    IXAttribute* attributeToEvaluate = [self getAttributeToEvaluate:attributeName];
    NSString* returnValue =  ( attributeToEvaluate != nil ) ? [attributeToEvaluate getAttributeValue] : defaultValue;
    return [returnValue copy];
}

-(IXSize*)getSizeAttributeValueWithPrefix:(NSString*)prefix
{
    NSString* attribute = kIXSize;
    NSString* width = kIXWidth;
    NSString* height = kIXHeight;
    NSString* widthX = kIXWidthX;
    NSString* heightX = kIXHeightX;
    
    if (prefix != nil) {
        attribute = [NSString stringWithFormat:@"%@.%@", prefix, kIXSize];
        width = [NSString stringWithFormat:@"%@.%@", prefix, width];
        height = [NSString stringWithFormat:@"%@.%@", prefix, height];
        widthX = [NSString stringWithFormat:@"%@.%@", prefix, widthX];
        heightX = [NSString stringWithFormat:@"%@.%@", prefix, heightX];
    }
    IXSize* returnSize = [[IXSize alloc] initWithDefaultSize];
    NSArray* sizeArr = [self getCommaSeperatedArrayListValue:attribute defaultValue:nil];
    if (sizeArr.count == 2) {
        returnSize.width = sizeArr[0];
        returnSize.height = sizeArr[1];
    } else if (sizeArr.count == 1) {
        returnSize.width = sizeArr[0];
        returnSize.height = sizeArr[0];
    }
    returnSize.width = [self getStringAttributeValue:width defaultValue:nil] ?: [self getStringAttributeValue:widthX defaultValue:returnSize.width];
    returnSize.height = [self getStringAttributeValue:height defaultValue:nil] ?: [self getStringAttributeValue:heightX defaultValue:returnSize.height];
    return returnSize;
}

-(NSArray*)getCommaSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_COMMA_SEPERATOR];
    }
    return returnArray;
}

-(NSArray*)getPipeCommaPipeSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_PIPECOMMAPIPE_SEPERATOR];
    }
    return returnArray;
}

-(NSArray*)getPipeSeperatedArrayListValue:(NSString*)attributeName defaultValue:(NSArray*)defaultValue
{
    NSArray* returnArray = defaultValue;
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    if( stringValue != nil )
    {
        returnArray = [stringValue componentsSeparatedByString:kIX_PIPE_SEPERATOR];
    }
    return returnArray;
}

-(BOOL)getBoolPropertyValue:(NSString*)attributeName defaultValue:(BOOL)defaultValue
{
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    BOOL returnValue =  ( stringValue != nil ) ? [stringValue boolValue] : defaultValue;
    return returnValue;
}

-(int)getIntAttributeValue:(NSString*)attributeName defaultValue:(int)defaultValue
{
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    int returnValue =  ( stringValue != nil ) ? (int) [stringValue integerValue] : defaultValue;
    return returnValue;
}

-(float)getFloatAttributeValue:(NSString*)attributeName defaultValue:(float)defaultValue
{
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    float returnValue =  ( stringValue != nil ) ? [stringValue floatValue] : defaultValue;
    return returnValue;
}

-(float)getSizeValue:(NSString*)attributeName maximumSize:(float)maxSize defaultValue:(float)defaultValue
{
    IXSizeValuePercentage sizeValuePercentage = ixSizePercentageValueWithStringOrDefaultValue([self getStringAttributeValue:attributeName defaultValue:nil], defaultValue);
    float returnValue = ixEvaluateSizeValuePercentageForMaxValue(sizeValuePercentage, maxSize);
    return returnValue;
}

-(UIColor*)getColorAttributeValue:(NSString*)attributeName defaultValue:(UIColor*)defaultValue
{
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
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
    NSURL* imageURL = [self getURLPathAttributeValue:attributeName basePath:nil defaultValue:nil];
    /*
     Added in a fallback so that if images.touch (etc.) don't exist, it tries again with "images.default".
     This way we don't have to specify several of the same image in the JSON.
     - B
    */
    if( imageURL == nil )
    {
        if ([attributeName hasSuffix:@"icon"])
            imageURL = [self getURLPathAttributeValue:@"icon" basePath:nil defaultValue:nil];
        if ([attributeName hasPrefix:@"images"])
            imageURL = [self getURLPathAttributeValue:@"images.default" basePath:nil defaultValue:nil];
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

-(NSURL*)getURLPathAttributeValue:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSURL*)defaultValue
{
    NSURL* returnURL = defaultValue;
    NSString* stringSettingValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    if( stringSettingValue != nil )
    {
        returnURL = [IXPathHandler normalizedURLPath:stringSettingValue
                                            basePath:basePath
                                            rootPath:[[[self ownerObject] sandbox] rootPath]];
    }
    return returnURL;
}

-(NSString*)getPathAttributeValue:(NSString*)attributeName basePath:(NSString*)basePath defaultValue:(NSString*)defaultValue
{
    NSString* returnPath = defaultValue;
    NSString* stringSettingValue = [self getStringAttributeValue:attributeName defaultValue:nil];
    if( stringSettingValue != nil )
    {
        returnPath = [IXPathHandler normalizedPath:stringSettingValue
                                          basePath:basePath
                                          rootPath:[[[self ownerObject] sandbox] rootPath]];
    }
    return returnPath;
}

-(UIFont*)getFontAttributeValue:(NSString*)attributeName defaultValue:(UIFont*)defaultValue
{
    UIFont* returnFont = defaultValue;
    NSString* stringValue = [self getStringAttributeValue:attributeName defaultValue:nil];
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
        [description appendFormat:@"\t%@: %@",attributeKey, [attributeToEvaluate getAttributeValue]];
        if( [attributeToEvaluate evaluations] )
        {
            [description appendFormat:@" (%@)",[attributeToEvaluate originalString]];
        }
        [description appendString:@"\n"];
    }
    return description;
}

@end
