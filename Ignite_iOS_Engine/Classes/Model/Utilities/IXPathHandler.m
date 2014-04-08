//
//  IXPathHandler.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/25/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXPathHandler.h"

static NSString* sIXBundleRootPath = nil;
static NSString* sIXDocumentDirectoryPath = nil;
static NSString* sIXCachesDirectoryPath = nil;

static NSString* const kIXHTTPPrefix = @"http://";
static NSString* const kIXHTTPSPrefix = @"https://";
static NSString* const kIXDocsPrefix = @"docs://";
static NSString* const kIXCachePrefix = @"cache://";
static NSString* const kIXDevicePrefix = @"device://";
static NSString* const kIXAssetsLibraryPrefix = @"assets-library://";

@implementation IXPathHandler

+(void)load
{
    sIXBundleRootPath = [[NSBundle mainBundle] resourcePath];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    sIXDocumentDirectoryPath = [paths firstObject];
    
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    sIXCachesDirectoryPath = [paths firstObject];
}

+(BOOL)pathIsLocal:(NSString*)path
{
    return ![path hasPrefix:kIXHTTPPrefix] && ![path hasPrefix:kIXHTTPSPrefix];
}

+(BOOL)pathIsAssetsLibrary:(NSString*)path
{
    return [path hasPrefix:kIXAssetsLibraryPrefix];
}

+(BOOL)pathIsDocs:(NSString*)path
{
    return [path hasPrefix:kIXDocsPrefix];
}

+(BOOL)pathIsDevice:(NSString*)path
{
    return [path hasPrefix:kIXDevicePrefix];
}

+(BOOL)pathIsCache:(NSString*)path
{
    return [path hasPrefix:kIXCachePrefix];
}

+(NSString *)normalizedPath:(NSString *)pathToNormalize
                   basePath:(NSString *)basePath
                   rootPath:(NSString *)rootPath
{
    NSString* normalizedPath = nil;
    if( pathToNormalize.length > 0 )
    {
        if( [pathToNormalize hasPrefix:sIXBundleRootPath] )
        {
            normalizedPath = pathToNormalize;
        }
        else if( [IXPathHandler pathIsDevice:pathToNormalize] )
        {
            normalizedPath = [sIXBundleRootPath stringByAppendingPathComponent:[pathToNormalize substringFromIndex:[kIXDevicePrefix length]]];
        }
        else if( ![IXPathHandler pathIsLocal:pathToNormalize] || [IXPathHandler pathIsAssetsLibrary:pathToNormalize] )
        {
            normalizedPath = pathToNormalize;
        }
        else if( [IXPathHandler pathIsDocs:pathToNormalize] )
        {
            normalizedPath = [sIXDocumentDirectoryPath stringByAppendingPathComponent:[pathToNormalize substringFromIndex:[kIXDocsPrefix length]]];
        }
        else if( [IXPathHandler pathIsCache:pathToNormalize] )
        {
            normalizedPath = [sIXCachesDirectoryPath stringByAppendingPathComponent:[pathToNormalize substringFromIndex:[kIXDocsPrefix length]]];
        }
        else if( basePath == nil )
        {
            if( [pathToNormalize hasPrefix:@"/"] )
            {
                normalizedPath = [NSString stringWithFormat:@"%@%@",rootPath,pathToNormalize];
            }
            else
            {
                normalizedPath = [NSString stringWithFormat:@"%@/%@",rootPath,pathToNormalize];
            }
        }
        else
        {
            normalizedPath = [NSString stringWithFormat:@"%@/%@",basePath,pathToNormalize];
        }
    }
    return normalizedPath;
}

+(NSURL *)normalizedURLPath:(NSString *)pathToNormalize
                   basePath:(NSString *)basePath
                   rootPath:(NSString *)rootPath
{
    NSURL* normalizedURL = nil;
    if( pathToNormalize.length > 0 )
    {
        NSString* normalizedPath = [IXPathHandler normalizedPath:pathToNormalize basePath:basePath rootPath:rootPath];
        if( normalizedPath )
        {
            if( [IXPathHandler pathIsLocal:normalizedPath] && ![IXPathHandler pathIsAssetsLibrary:normalizedPath] )
            {
                normalizedURL = [NSURL fileURLWithPath:normalizedPath];
            }
            else
            {
                normalizedURL = [NSURL URLWithString:normalizedPath];
            }
        }
    }
    return normalizedURL;
}


@end
