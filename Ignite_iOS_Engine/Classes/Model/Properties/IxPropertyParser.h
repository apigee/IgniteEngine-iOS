//
//  IxPropertyParser.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/24.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class IxProperty;

@interface IxPropertyParser : NSObject

+(void)parseIxPropertyIntoComponents:(IxProperty*)property;

@end
