//
//  IXProperty.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseConditionalObject.h"

@class IXPropertyContainer;

@interface IXProperty : IXBaseConditionalObject <NSCopying>

@property (nonatomic,weak) IXPropertyContainer* propertyContainer;

@property (nonatomic,assign,getter = isReadonly) BOOL readonly;
@property (nonatomic,strong) NSString* originalString;
@property (nonatomic,strong) NSString* rawValue;
@property (nonatomic,strong) NSString* propertyName;
@property (nonatomic,strong) NSString* staticText;
@property (nonatomic,strong) NSArray* shortCodes; // TODO: make copy after implementing it
@property (nonatomic,strong) NSArray* shortCodeRanges; // TODO: make copy after implementing it

-(instancetype)initWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;
+(instancetype)propertyWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;

-(NSString*)getPropertyValue;

@end
