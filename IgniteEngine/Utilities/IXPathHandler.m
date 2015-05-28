//
//  IXPathHandler.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/25/14.
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

#import "IXPathHandler.h"

static NSString* sIXBundleRootPath = nil;
static NSString* sIXDocumentDirectoryPath = nil;
static NSString* sIXCachesDirectoryPath = nil;

static NSString* const kIXHTTPPrefix = @"http://";
static NSString* const kIXHTTPSPrefix = @"https://";
static NSString* const kIXWSPrefix = @"ws://";
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
    return ![path hasPrefix:kIXHTTPPrefix] && ![path hasPrefix:kIXHTTPSPrefix] && ![path hasPrefix:kIXWSPrefix];
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
        if( ![IXPathHandler pathIsLocal:pathToNormalize] )
        {
            normalizedPath = pathToNormalize;
        }
        else if( [pathToNormalize hasPrefix:sIXBundleRootPath] )
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

+(NSString*)localPathWithRelativeFilePath:(NSString *)filePath
{
    NSString* localPath = nil;
    if( [filePath length] > 0 )
    {
        localPath = [[NSBundle mainBundle] pathForResource:filePath ofType:nil];
    }
    return localPath;
}

@end
