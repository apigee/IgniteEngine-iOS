//
//  IXEvaluationFunction.h
//  Ignite Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^IXBaseEvaluationUtility)(NSString* stringToModify,NSArray* parameters);

@interface IXEvaluationUtility : NSObject

+(IXBaseEvaluationUtility)evaluationUtilityWithName:(NSString*)functionName;

@end
