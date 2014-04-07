//
//  IXLogger.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/26/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXLogger.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "IXAppManager.h"

BOOL ixShouldLogUsingApigeeLogging = NO;

#ifdef DEBUG
int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
int ddLogLevel = LOG_LEVEL_ERROR;
#endif

static NSString* const kIXLogLevelVerbose = @"verbose";
static NSString* const kIXLogLevelDebug = @"debug";
static NSString* const kIXLogLevelInfo = @"info";
static NSString* const kIXLogLevelWarn = @"warn";
static NSString* const kIXLogLevelError = @"error";
static NSString* const kIXLogLevelOff = @"off";
static NSString* const kIXLogLevelRelease = @"release";

@implementation IXLogger

@synthesize remoteLoggingEnabled = _remoteLoggingEnabled;
@synthesize apigeeClientAvailable = _apigeeClientAvailable;

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _remoteLoggingEnabled = NO;
        _apigeeClientAvailable = NO;
        
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    }
    return self;
}

+(instancetype)sharedLogger
{
    static IXLogger *sharedLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [[IXLogger alloc] init];
    });
    return sharedLogger;
}

-(void)setApigeeClientAvailable:(BOOL)apigeeClientAvailable
{
    _apigeeClientAvailable = apigeeClientAvailable;
    ixShouldLogUsingApigeeLogging = (_apigeeClientAvailable && _remoteLoggingEnabled);
}

-(void)setRemoteLoggingEnabled:(BOOL)remoteLoggingEnabled
{
    _remoteLoggingEnabled = remoteLoggingEnabled;
    ixShouldLogUsingApigeeLogging = (_apigeeClientAvailable && _remoteLoggingEnabled);
}

-(void)setAppLogLevel:(NSString *)appLogLevel
{
    _appLogLevel = [appLogLevel copy];
    
    int logLevelInt = ddLogLevel;
    if( [appLogLevel isEqualToString:kIXLogLevelVerbose] ) {
        logLevelInt = LOG_LEVEL_VERBOSE;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelDebug] ) {
        logLevelInt = LOG_LEVEL_DEBUG;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelInfo] ) {
        logLevelInt = LOG_LEVEL_INFO;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelWarn] ) {
        logLevelInt = LOG_LEVEL_WARN;
    } else if( [appLogLevel isEqualToString:kIXLogLevelOff] ) {
        logLevelInt = LOG_LEVEL_OFF;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelError] || [appLogLevel isEqualToString:kIXLogLevelRelease] ) {
        logLevelInt = LOG_LEVEL_ERROR;
    }

    ddLogLevel = logLevelInt;
    
    IX_LOG_DEBUG(@"%@ : App Log Level Set To : %@",THIS_FILE,[self appLogLevel]);
}

@end
