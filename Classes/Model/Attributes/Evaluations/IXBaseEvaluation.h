//
//  IXBaseVariable.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/7/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXAttribute;
@class IXSandbox;
@class IXBaseObject;

typedef NSString*(^IXBaseEvaluationUtility)(NSString* stringToModify,NSArray* parameters);

@interface IXBaseEvaluation : NSObject <NSCopying,NSCoding>

@property (nonatomic,weak) IXAttribute* property;
@property (nonatomic,assign) NSRange rangeInPropertiesText;

@property (nonatomic,copy) NSString* rawValue;
@property (nonatomic,copy) NSString* objectID;
@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,copy) NSString* rawString;
@property (nonatomic,strong) NSArray* parameters;

@property (nonatomic,copy) NSString* evaluationUtilityName;
@property (nonatomic,copy) IXBaseEvaluationUtility evaluationUtility;

-(instancetype)initWithRawValue:(NSString*)rawValue
                       objectID:(NSString*)objectID
                     methodName:(NSString*)methodName
                      rawString:(NSString*)rawString
          evaluationUtilityName:(NSString*)evaluationUtilityName
                     parameters:(NSArray*)parameters
          rangeInPropertiesText:(NSRange)rangeInPropertiesText;

+(instancetype)evaluationFromString:(NSString*)checkedString
                textCheckingResult:(NSTextCheckingResult*)textCheckingResult;

-(NSString*)evaluate;
-(NSString*)evaluateAndApplyUtility;

@end
