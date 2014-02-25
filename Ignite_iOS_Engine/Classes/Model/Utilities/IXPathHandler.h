//
//  IXPathHandler.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/25/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXPathHandler : NSObject

+(BOOL)pathIsLocal:(NSString*)path;
+(BOOL)pathIsAssetsLibrary:(NSString*)path;
+(BOOL)pathIsDocs:(NSString*)path;
+(BOOL)pathIsCache:(NSString*)path;

+(NSString *)normalizedPath:(NSString *)pathToNormalize
                   basePath:(NSString *)basePath
                   rootPath:(NSString *)rootPath;

+(NSURL *)normalizedURLPath:(NSString *)pathToNormalize
                   basePath:(NSString *)basePath
                   rootPath:(NSString *)rootPath;

@end
