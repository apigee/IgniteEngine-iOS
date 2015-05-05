//
//  IXLogger.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/26/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXLogger.h"

//#import "DDASLLogger.h"
//#import "DDTTYLogger.h"
#import "IXAFNetworkActivityLogger.h"

#import "IXAppManager.h"

BOOL ixShouldLogUsingApigeeLogging = NO;

#ifdef DEBUG
DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
DDLogLevel ddLogLevel = DDLogLevelError;
#endif

static NSString* const kIXLogLevelVerbose = @"verbose";
static NSString* const kIXLogLevelDebug = @"debug";
static NSString* const kIXLogLevelInfo = @"info";
static NSString* const kIXLogLevelWarn = @"warn";
static NSString* const kIXLogLevelError = @"error";
static NSString* const kIXLogLevelOff = @"off";
static NSString* const kIXLogLevelRelease = @"release";

@implementation IXLogger

@synthesize requestLoggingEnabled = _requestLoggingEnabled;
@synthesize remoteLoggingEnabled = _remoteLoggingEnabled;
@synthesize apigeeClientAvailable = _apigeeClientAvailable;

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _requestLoggingEnabled = NO;
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

-(void)setRequestLoggingEnabled:(BOOL)requestLoggingEnabled
{
    _requestLoggingEnabled = requestLoggingEnabled;
    if( requestLoggingEnabled )
    {
        [[IXAFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
        [[IXAFNetworkActivityLogger sharedLogger] startLogging];
    }
    else
    {
        [[IXAFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelOff];
        [[IXAFNetworkActivityLogger sharedLogger] stopLogging];
    }
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
    
    DDLogLevel logLevelInt = ddLogLevel;
    if( [appLogLevel isEqualToString:kIXLogLevelVerbose] ) {
        logLevelInt = DDLogLevelVerbose;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelDebug] ) {
        logLevelInt = DDLogLevelDebug;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelInfo] ) {
        logLevelInt = DDLogLevelInfo;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelWarn] ) {
        logLevelInt = DDLogLevelWarning;
    } else if( [appLogLevel isEqualToString:kIXLogLevelOff] ) {
        logLevelInt = DDLogLevelOff;
    } else if ( [appLogLevel isEqualToString:kIXLogLevelError] || [appLogLevel isEqualToString:kIXLogLevelRelease] ) {
        logLevelInt = DDLogLevelError;
    }

    ddLogLevel = logLevelInt;
    
    IX_LOG_DEBUG(@"%@ : App Log Level Set To : %@",THIS_FILE,[self appLogLevel]);
}

@end
