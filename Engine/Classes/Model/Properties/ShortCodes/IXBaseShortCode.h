//
//  IXBaseShortCode.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;
@class IXSandbox;
@class IXBaseObject;

typedef NSString*(^IXBaseShortCodeFunction)(NSString* stringToModify,NSArray* parameters);

@interface IXBaseShortCode : NSObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXProperty* property;
@property (nonatomic,assign) NSRange rangeInPropertiesText;

@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* objectID;
@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,copy) NSString* rawString;
@property (nonatomic,strong) NSArray* parameters;

@property (nonatomic,copy) NSString* functionName;
@property (nonatomic,copy) IXBaseShortCodeFunction shortCodeFunction;

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                     rawString:(NSString*)rawString
                   functionName:(NSString*)functionName
                     parameters:(NSArray*)parameters
          rangeInPropertiesText:(NSRange)rangeInPropertiesText;

+(instancetype)shortCodeFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult;

-(NSString*)evaluate;
-(NSString*)evaluateAndApplyFunction;

@end
