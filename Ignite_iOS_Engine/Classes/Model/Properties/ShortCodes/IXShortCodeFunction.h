//
//  IXShortCodeFunction.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 4/9/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^IXBaseShortCodeFunction)(NSString* stringToModify,NSArray* parameters);

@interface IXShortCodeFunction : NSObject

+(IXBaseShortCodeFunction)shortCodeFunctionWithName:(NSString*)functionName;

@end
