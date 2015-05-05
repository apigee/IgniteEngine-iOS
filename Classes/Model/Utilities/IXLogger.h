//
//  IXLogger.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>
#define LOG_LEVEL_DEF ddLogLevel
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "IXConstants.h"

extern DDLogLevel ddLogLevel;
extern BOOL ixShouldLogUsingApigeeLogging;

@interface IXLogger : NSObject

@property (nonatomic,copy) NSString* appLogLevel;
@property (nonatomic,assign,getter = isRequestLoggingEnabled) BOOL requestLoggingEnabled;
@property (nonatomic,assign,getter = isApigeeClientAvailable) BOOL apigeeClientAvailable;
@property (nonatomic,assign,getter = isRemoteLoggingEnabled) BOOL remoteLoggingEnabled;

+(instancetype)sharedLogger;

@end
