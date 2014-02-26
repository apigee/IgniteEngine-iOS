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

#ifdef DEBUG
BOOL kIXIsInDebugMode = YES;
int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
BOOL isInDebugMode = NO;
int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation IXLogger

-(instancetype)init
{
    self = [super init];
    if( self )
    {
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

-(void)setAppLogLevel:(NSString *)appLogLevel
{
    _appLogLevel = appLogLevel;
    
    int logLevelInt = ddLogLevel;
    if( [appLogLevel isEqualToString:@"debug"] ) {
        logLevelInt = LOG_LEVEL_DEBUG;
    } else if( [appLogLevel isEqualToString:@"release"] ) {
        logLevelInt = LOG_LEVEL_OFF;
    } else if ( [appLogLevel isEqualToString:@"verbose"] ) {
        logLevelInt = LOG_LEVEL_VERBOSE;
    } else if ( [appLogLevel isEqualToString:@"info"] ) {
        logLevelInt = LOG_LEVEL_INFO;
    } else if ( [appLogLevel isEqualToString:@"warning"] ) {
        logLevelInt = LOG_LEVEL_WARN;
    }
    
    DDLogDebug(@"%@ : App Log Level Set To : %@",THIS_FILE,_appLogLevel);

    ddLogLevel = logLevelInt;
}

@end
