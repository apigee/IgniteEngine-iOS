//
//  IXLogger.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IXConstants.h"

extern int ddLogLevel;
extern BOOL ixShouldLogUsingApigeeLogging;

@interface IXLogger : NSObject

@property (nonatomic,copy) NSString* appLogLevel;
@property (nonatomic,assign,getter = isApigeeClientAvailable) BOOL apigeeClientAvailable;
@property (nonatomic,assign,getter = isRemoteLoggingEnabled) BOOL remoteLoggingEnabled;

+(instancetype)sharedLogger;

@end
