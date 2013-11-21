//
//  ixeProperty.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/7.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseConditionalObject.h"

@class ixePropertyContainer;

@interface ixeProperty : ixeBaseConditionalObject <NSCopying>

@property (nonatomic,weak) ixePropertyContainer* propertyContainer;

@property (nonatomic,copy) NSString* originalString;
@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* propertyName;
@property (nonatomic,copy) NSString* staticText;
@property (nonatomic,strong) NSMutableArray* shortCodes; // TODO: make copy after implementing it
@property (nonatomic,strong) NSMutableArray* shortCodeRanges; // TODO: make copy after implementing it


#warning METHODS NOT DONE YET

-(instancetype)initWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;
+(instancetype)propertyWithPropertyName:(NSString*)propertyName rawValue:(NSString*)rawValue;

-(NSString*)getPropertyValue;

@end
