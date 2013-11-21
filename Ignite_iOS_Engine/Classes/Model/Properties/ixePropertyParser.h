//
//  ixePropertyParser.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/24.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>

@class ixeProperty;

@interface ixePropertyParser : NSObject

+(void)parseixePropertyIntoComponents:(ixeProperty*)property;

@end
