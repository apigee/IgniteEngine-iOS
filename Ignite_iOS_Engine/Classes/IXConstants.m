//
//  IXConstants.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXConstants.h"

// APP LEVEL NOTIFICATIONS
NSString* const kIXAppWillResignActiveEvent = @"willResignActive";
NSString* const kIXAppDidEnterBackgroundEvent = @"didEnterBackground";
NSString* const kIXAppWillEnterForegroundEvent = @"willEnterForeground";
NSString* const kIXAppDidBecomeActiveEvent = @"didBecomeActive";
NSString* const kIXAppWillTerminateEvent = @"willTerminate";
NSString* const kIXAppRegisterForRemoteNotificationsSuccess = @"push.register.success";
NSString* const kIXAppRegisterForRemoteNotificationsFailed = @"push.register.error";
NSString* const kIXPushRecievedEvent = @"push.received";
NSString* const kIXCustomURLSchemeOpened = @"customUrl.opened";
NSString* const kIXLocationAuthChanged = @"location.auth.changed";
NSString* const kIXLocationLocationUpdated = @"location.changed";
NSString* const kIXMicrophoneAuthChanged = @"mic.auth.changed";

// SPECIAL
NSString* const kIX_CONTROL_CLASS_NAME_FORMAT = @"IX%@";
NSString* const kIX_DATA_PROVIDER_CLASS_NAME_FORMAT = @"IX%@DataProvider";
NSString* const kIX_ACTION_CLASS_NAME_FORMAT = @"IX%@Action";
NSString* const kIX_SHORTCODE_CLASS_NAME_FORMAT = @"IX%@ShortCode";
NSString* const kIX_DUMMY_DATA_MODEL_ENTITY_NAME = @"IXDummyDataModelEntity";
NSString* const kIX_STORED_SESSION_ATTRIBUTES_KEY = @"IXStoredSessionAttributes";
NSString* const kIX_DEBUG = @"debug";
NSString* const kIX_RELEASE = @"release";

NSString* const kIX_ID = @"_id";
NSString* const kIX_TYPE = @"_type";
NSString* const kIX_STYLE = @"_style";
// TODO: Should we change this to "target.id" ? or "control.id"
NSString* const kIX_TARGET = @"_target";
NSString* const kIX_CONTROLS = @"controls";
NSString* const kIX_ACTION = @"action";
NSString* const kIX_ACTIONS = @"actions";
NSString* const kIX_ATTRIBUTES = @"attributes";
NSString* const kIX_DATASOURCES = @"datasources";
NSString* const kIX_VALUE = @"value";
NSString* const kIX_ORIENTATION = @"orientation";
NSString* const kIX_LANDSCAPE = @"landscape";
NSString* const kIX_PORTRAIT = @"portrait";
NSString* const kIX_IF = @"if";
NSString* const kIX_ENABLED = @"enabled";
NSString* const kIX_ON = @"on";
NSString* const kIX_DELAY = @"delay";
NSString* const kIX_TRUE = @"true";
NSString* const kIX_FALSE = @"false";
NSString* const kIX_ZERO = @"0";
NSString* const kIX_EMPTY_STRING = @"";
NSString* const kIX_COMMA_SEPERATOR = @",";
NSString* const kIX_PIPECOMMAPIPE_SEPERATOR = @"|,|";
NSString* const kIX_PIPE_SEPERATOR = @"|";
NSString* const kIX_PERIOD_SEPERATOR = @".";
NSString* const kIX_COLON_SEPERATOR = @":";
NSString* const kIX_DOUBLE_COLON_SEPERATOR = @"::";
NSString* const kIX_EVAL_BRACKETS = @"{{";

// DATA PROVIDER SPECIFIC NODES
NSString* const kIX_DP_PARAMETERS = @"parameters";
NSString* const kIX_DP_HEADERS = @"headers";
NSString* const kIX_DP_ATTACHMENTS = @"attachments";
NSString* const kIX_DP_ENTITY = @"entity";

// GLOBAL EVENT NAMES
NSString* const kIX_ERROR = @"error";
NSString* const kIX_FAILED = @"failed";
NSString* const kIX_FINISHED = @"finished";
NSString* const kIX_DONE = @"done";
NSString* const kIX_SUCCESS = @"success";

// ACTION TYPES
NSString* const kIX_ALERT = @"alert";
NSString* const kIX_MODIFY = @"modify";
NSString* const kIX_REFRESH = @"refresh";
NSString* const kIX_LOAD = @"load";
NSString* const kIX_SET = @"set";
NSString* const kIX_FUNCTION = @"function";

// RANDOMS
NSString* const kIX_ANIMATED = @"animated";
NSString* const kIX_TITLE = @"title";
NSString* const kIX_SUB_TITLE = @"sub_title";
NSString* const kIX_OK = @"OK";
NSString* const kIX_CANCEL = @"Cancel";
NSString* const kIX_TOUCH = @"touch";
NSString* const kIX_GIF_EXTENSION = @"gif";
NSString* const kIX_DEFAULT = @"default";