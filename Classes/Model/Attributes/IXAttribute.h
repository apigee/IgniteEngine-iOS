//
//  IXAttribute.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXBaseObject;
@class IXAttributeContainer;

@interface IXAttribute : IXBaseConditionalObject

@property (nonatomic,weak) IXAttributeContainer* attributeContainer;
@property (nonatomic,assign) BOOL wasAnArray;
@property (nonatomic,copy) NSString* attributeName;
@property (nonatomic,copy) NSString* originalString;
@property (nonatomic,copy) NSString* staticText;
@property (nonatomic,strong) NSArray* evaluations;

-(instancetype)initWithAttributeName:(NSString*)attributeName rawValue:(NSString*)rawValue;
+(instancetype)attributeWithAttributeName:(NSString*)attributeName rawValue:(NSString*)rawValue;
+(instancetype)attributeWithAttributeName:(NSString*)attributeName jsonObject:(id)jsonObject;
+(NSArray*)attributeWithAttributeName:(NSString*)attributeName attributeValueJSONArray:(NSArray*)attributeValueJSONArray;

-(NSString*)attributeStringValue;

@end
