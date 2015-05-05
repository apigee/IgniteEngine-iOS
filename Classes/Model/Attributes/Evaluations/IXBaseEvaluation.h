//
//  IXBaseVariable.h
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
