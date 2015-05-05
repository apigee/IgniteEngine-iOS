//
//  IXConstants.h
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
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

#import <Foundation/Foundation.h>

#import "IXLogger.h"
#import "ApigeeLogger.h"

#define IX_STATIC_CONST_STRING static NSString* const
#define IX_STATIC_CONST_FLOAT static CGFloat const
#define IX_STATIC_CONST_INTEGER static NSInteger const

#define IX_dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread])\
    {\
        block();\
    }\
    else\
    {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define IX_APIGEE_LOG_TAG @"IgniteEngine_Log"

#define IX_LOG_VERBOSE(frmt, ...)   \
    if( ddLogLevel & DDLogFlagVerbose ) { \
        if( ixShouldLogUsingApigeeLogging ) { \
            ApigeeLogVerbose(IX_APIGEE_LOG_TAG,frmt, ##__VA_ARGS__); \
        } else { \
            DDLogVerbose(frmt, ##__VA_ARGS__); \
        } \
    }
#define IX_LOG_DEBUG(frmt, ...) \
    if( ddLogLevel & DDLogFlagDebug ) { \
        if( ixShouldLogUsingApigeeLogging ) { \
            ApigeeLogDebug(IX_APIGEE_LOG_TAG,frmt, ##__VA_ARGS__); \
        } else { \
            DDLogDebug(frmt, ##__VA_ARGS__); \
        } \
    }
#define IX_LOG_INFO(frmt, ...) \
    if( ddLogLevel & DDLogFlagInfo ) { \
        if( ixShouldLogUsingApigeeLogging ) { \
            ApigeeLogInfo(IX_APIGEE_LOG_TAG,frmt, ##__VA_ARGS__); \
        } else { \
            DDLogInfo(frmt, ##__VA_ARGS__); \
        } \
    }
#define IX_LOG_WARN(frmt, ...) \
    if( ddLogLevel & DDLogFlagWarning ) { \
        if( ixShouldLogUsingApigeeLogging ) { \
            ApigeeLogWarn(IX_APIGEE_LOG_TAG,frmt, ##__VA_ARGS__); \
        } else { \
            DDLogWarn(frmt, ##__VA_ARGS__); \
        } \
    }
#define IX_LOG_ERROR(frmt, ...) \
    if( ddLogLevel & DDLogFlagError ) { \
        if( ixShouldLogUsingApigeeLogging ) { \
            ApigeeLogError(IX_APIGEE_LOG_TAG,frmt, ##__VA_ARGS__); \
        } else { \
            DDLogError(frmt, ##__VA_ARGS__); \
        } \
    }

// APP LEVEL EVENTS
extern NSString* const kIXAppWillResignActiveEvent;
extern NSString* const kIXAppDidEnterBackgroundEvent;
extern NSString* const kIXAppWillEnterForegroundEvent;
extern NSString* const kIXAppDidBecomeActiveEvent;
extern NSString* const kIXAppWillTerminateEvent;
extern NSString* const kIXAppRegisterForRemoteNotificationsSuccess;
extern NSString* const kIXAppRegisterForRemoteNotificationsFailed;
extern NSString* const kIXPushRecievedEvent;
extern NSString* const kIXCustomURLSchemeOpened;
extern NSString* const kIXLocationAuthChanged;
extern NSString* const kIXLocationLocationUpdated;
extern NSString* const kIXMicrophoneAuthChanged;

// SPECIAL
extern NSString* const kIX_CONTROL_CLASS_NAME_FORMAT;
extern NSString* const kIX_DATA_PROVIDER_CLASS_NAME_FORMAT;
extern NSString* const kIX_ACTION_CLASS_NAME_FORMAT;
extern NSString* const kIX_EVALUATION_CLASS_NAME_FORMAT;
extern NSString* const kIX_DUMMY_DATA_MODEL_ENTITY_NAME;
extern NSString* const kIX_STORED_SESSION_ATTRIBUTES_KEY;
extern NSString* const kIX_DEBUG;
extern NSString* const kIX_RELEASE;

extern NSString* const kIX_ID;
extern NSString* const kIX_STYLE;
extern NSString* const kIX_TARGET;
extern NSString* const kIX_TYPE;
extern NSString* const kIX_CONTROLS;
extern NSString* const kIX_ACTION;
extern NSString* const kIX_ACTIONS;
extern NSString* const kIX_ATTRIBUTES;
extern NSString* const kIX_DATASOURCES;
extern NSString* const kIX_VALUE;
extern NSString* const kIX_ORIENTATION;
extern NSString* const kIX_LANDSCAPE;
extern NSString* const kIX_PORTRAIT;
extern NSString* const kIX_IF;
extern NSString* const kIX_ENABLED;
extern NSString* const kIX_ON;
extern NSString* const kIX_DELAY;
extern NSString* const kIX_TRUE;
extern NSString* const kIX_FALSE;
extern NSString* const kIX_ZERO;
extern NSString* const kIX_EMPTY_STRING;
extern NSString* const kIX_COMMA_SEPERATOR;
extern NSString* const kIX_PIPE_SEPERATOR;
extern NSString* const kIX_PIPECOMMAPIPE_SEPERATOR;
extern NSString* const kIX_PERIOD_SEPERATOR;
extern NSString* const kIX_QUOTE_SEPERATOR;
extern NSString* const kIX_COLON_SEPERATOR;
extern NSString* const kIX_DOUBLE_COLON_SEPERATOR;
extern NSString* const kIX_EVAL_BRACKETS;

// GLOBAL EVENT NAMES
extern NSString* const kIX_ERROR;
extern NSString* const kIX_FAILED;
extern NSString* const kIX_FINISHED;
extern NSString* const kIX_DONE;
extern NSString* const kIX_SUCCESS;

// DATA PROVIDER SPECIFIC NODES
extern NSString* const kIX_DP_QUERYPARAMS;
extern NSString* const kIX_DP_BODY;
extern NSString* const kIX_DP_HEADERS;
extern NSString* const kIX_DP_ATTACHMENTS;
extern NSString* const kIX_DP_ENTITY;

// ACTION TYPES
extern NSString* const kIX_ALERT;
extern NSString* const kIX_MODIFY;
extern NSString* const kIX_REFRESH;
extern NSString* const kIX_LOAD;
extern NSString* const kIX_SET;
extern NSString* const kIX_FUNCTION_PARAMETERS;
extern NSString* const kIX_FUNCTION;

// RANDOMS
extern NSString* const kIX_ANIMATED;
extern NSString* const kIX_TITLE;
extern NSString* const kIX_SUB_TITLE;
extern NSString* const kIX_OK;
extern NSString* const kIX_CANCEL;
extern NSString* const kIX_TOUCH;
extern NSString* const kIX_GIF_EXTENSION;
extern NSString* const kIX_DEFAULT;