//
//  IXCustom.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXCustom.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXJSONParser.h"
#import "IXPathHandler.h"

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@interface IXCustom ()

@property (nonatomic,strong) IXSandbox* customControlSandox;

@end

@implementation IXCustom

-(void)buildView
{
    [super buildView];
    
    _needsToPopulate = YES;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXCustom* customCopy = [super copyWithZone:zone];
    [customCopy setNeedsToPopulate:[self needsToPopulate]];
    [customCopy setDataProviders:[self dataProviders]];
    return customCopy;
}

-(void)applySettings
{
    if( [self customControlSandox] == nil )
    {
        NSString* pathToJSON = [[self propertyContainer] getPathPropertyValue:@"control_location" basePath:nil defaultValue:nil];
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
        [[self customControlSandox] setDataProviders:[NSMutableDictionary dictionaryWithDictionary:[[self sandbox] dataProviders]]];
        [[self customControlSandox] addDataProviders:[self dataProviders]];
        [self setSandbox:[self customControlSandox]];
    }
    
    [super applySettings];
}

@end
