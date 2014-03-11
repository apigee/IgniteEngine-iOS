//
//  IXBaseShortCode.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;
@class IXSandbox;
@class IXBaseObject;

@interface IXBaseShortCode : NSObject <NSCopying>

@property (nonatomic,weak) IXProperty* property;
@property (nonatomic,assign) NSRange rangeInPropertiesText;

@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* objectID;
@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,copy) NSString* functionName;
@property (nonatomic,strong) NSArray* parameters;

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                   functionName:(NSString*)functionName
                     parameters:(NSArray*)parameters;

+(IXBaseShortCode*)shortCodeWithRawValue:(NSString*)rawValue
                                objectID:(NSString*)objectID
                              methodName:(NSString*)methodName
                            functionName:(NSString*)functionName
                              parameters:(NSArray*)parameters;

-(NSString*)evaluate;
-(NSString*)applyFunctionToString:(NSString*)stringToModify;

@end
