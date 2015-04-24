//
//  IXAFHTTPSessionManager.h
//  Ignite Engine
//
//  Created by Brandon Shelley on 4/9/15
//  Copyright (c) 2015 Apigee. All rights reserved.
//  Source: http://www.splinter.com.au/2014/09/10/afnetworking-error-bodies/
//

#import "AFHTTPSessionManager.h"

//#define kErrorResponseObjectKey @"kErrorResponseObjectKey"

@interface IXAFHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

@end
