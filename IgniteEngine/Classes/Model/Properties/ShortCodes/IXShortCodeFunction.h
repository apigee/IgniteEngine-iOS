//
//  IXShortCodeFunction.h
//  Ignite Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^IXBaseShortCodeFunction)(NSString* stringToModify,NSArray* parameters);

@interface IXShortCodeFunction : NSObject

+(IXBaseShortCodeFunction)shortCodeFunctionWithName:(NSString*)functionName;

@end
