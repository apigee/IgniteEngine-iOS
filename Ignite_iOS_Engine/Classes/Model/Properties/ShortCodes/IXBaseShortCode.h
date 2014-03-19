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

typedef NSString*(^IXBaseShortCodeFunction)(NSString* stringToModify,NSArray* parameters);

@interface IXBaseShortCode : NSObject <NSCopying>

@property (nonatomic,weak) IXProperty* property;
@property (nonatomic,assign) NSRange rangeInPropertiesText;

@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* objectID;
@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,strong) NSArray* parameters;

@property (nonatomic,copy) NSString* functionName;
@property (nonatomic,copy) IXBaseShortCodeFunction shortCodeFunction;

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                   functionName:(NSString*)functionName
                     parameters:(NSArray*)parameters;

+(instancetype)shortCodeFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult;

-(NSString*)evaluate;
-(NSString*)evaluateAndApplyFunction;

@end
