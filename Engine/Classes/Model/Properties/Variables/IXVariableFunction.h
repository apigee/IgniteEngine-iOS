//
//  IXVariableFunction.h
//  Ignite Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^IXBaseVariableFunction)(NSString* stringToModify,NSArray* parameters);

@interface IXVariableFunction : NSObject

+(IXBaseVariableFunction)variableFunctionWithName:(NSString*)functionName;

@end
