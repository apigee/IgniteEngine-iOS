//
//  IXProperty.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXBaseObject;
@class IXPropertyContainer;

@interface IXProperty : IXBaseConditionalObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXPropertyContainer* propertyContainer;
@property (nonatomic,assign) BOOL wasAnArray;
@property (nonatomic,copy) NSString* propertyName;
@property (nonatomic,copy) NSString* originalString;
@property (nonatomic,copy) NSString* staticText;
@property (nonatomic,strong) NSArray* shortCodes;

-(instancetype)initWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;
+(instancetype)propertyWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;
+(instancetype)propertyWithPropertyName:(NSString*)propertyName jsonObject:(id)jsonObject;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueJSONArray:(NSArray*)propertyValueJSONArray;

-(NSString*)getPropertyValue;

@end
