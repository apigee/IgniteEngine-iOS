//
//  IXPropertyParser.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/24/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXProperty;

@interface IXPropertyParser : NSObject

+(void)parseIXPropertyIntoComponents:(IXProperty*)property;

@end
