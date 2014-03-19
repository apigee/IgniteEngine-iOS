//
//  IXLogger.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDLog.h"

extern int ddLogLevel;

@interface IXLogger : NSObject

@property (nonatomic,copy) NSString* appLogLevel;

+(instancetype)sharedLogger;

@end
