//
//  IXCustom.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/4/14.
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

#import "IXCustom.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXPathHandler.h"
#import "IXBaseDataProvider.h"

// NSCoding Key Constants
static NSString* const kIXDataProvidersNSCodingKey = @"dataProviders";
static NSString* const kIXPathToJSONNSCodingKey = @"pathToJSON";

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@interface IXCustom ()

@property (nonatomic,strong) IXSandbox* customControlSandox;

@end

@implementation IXCustom

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXCustom* customCopy = [super copyWithZone:zone];
    [customCopy setDataProviders:[self dataProviders]];
    [customCopy setPathToJSON:[self pathToJSON]];
    return customCopy;
}

-(void)buildView
{
    [super buildView];
    
    _firstLoad = YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self pathToJSON] forKey:kIXPathToJSONNSCodingKey];
    [aCoder encodeObject:[self dataProviders] forKey:kIXDataProvidersNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setDataProviders:[aDecoder decodeObjectForKey:kIXDataProvidersNSCodingKey]];
        [self setPathToJSON:[aDecoder decodeObjectForKey:kIXPathToJSONNSCodingKey]];
    }
    return self;
}

-(void)setSandbox:(IXSandbox *)sandbox
{
    if( [self customControlSandox] == nil || [self customControlSandox] == sandbox )
    {
        [super setSandbox:sandbox];
    }
    else
    {
        [[self customControlSandox] setViewController:[sandbox viewController]];
        [[self customControlSandox] setContainerControl:[sandbox containerControl]];
        [[self customControlSandox] setDataProviderForRowData:[sandbox dataProviderForRowData]];
        [[self customControlSandox] setIndexPathForRowData:[sandbox indexPathForRowData]];
        
        [[self customControlSandox] setDataProviders:nil];
        if( [[[self sandbox] dataProviders] count] )
        {
            [[self customControlSandox] setDataProviders:[NSMutableDictionary dictionaryWithDictionary:[[self sandbox] dataProviders]]];
        }
        [[self customControlSandox] addDataProviders:[self dataProviders]];
    }
}

-(void)setPathToJSON:(NSString *)pathToJSON
{
    _pathToJSON = pathToJSON;
    
    NSString* jsonRootPath = nil;
    if( [IXPathHandler pathIsLocal:pathToJSON] ) {
        jsonRootPath = [pathToJSON stringByDeletingLastPathComponent];
    } else {
        jsonRootPath = [[[NSURL URLWithString:pathToJSON] URLByDeletingLastPathComponent] absoluteString];
    }
    [self setCustomControlSandox:[[IXSandbox alloc] initWithBasePath:nil rootPath:jsonRootPath]];
    [[self customControlSandox] setCustomControlContainer:self];
    [[self customControlSandox] setViewController:[[self sandbox] viewController]];
    [[self customControlSandox] setContainerControl:[[self sandbox] containerControl]];
    [[self customControlSandox] setDataProviderForRowData:[[self sandbox] dataProviderForRowData]];
    [[self customControlSandox] setIndexPathForRowData:[[self sandbox] indexPathForRowData]];
    if( [[[self sandbox] dataProviders] count] )
    {
        [[self customControlSandox] setDataProviders:[NSMutableDictionary dictionaryWithDictionary:[[self sandbox] dataProviders]]];
    }
    [[self customControlSandox] addDataProviders:[self dataProviders]];
    [self setSandbox:[self customControlSandox]];
}

-(void)applySettings
{
    if( [self isFirstLoad] )
    {
        [self setFirstLoad:NO];
        
        // Only on firstLoad load only the data providers that are specific for this custom control.
        for( IXBaseDataProvider* dataProvider in [self dataProviders] )
        {
            [dataProvider applySettings];
            if( [dataProvider shouldAutoLoad] )
            {
                [dataProvider loadData:YES];
            }
        }
    }
    
    [super applySettings];
}

@end
