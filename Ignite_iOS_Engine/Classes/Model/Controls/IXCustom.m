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

-(void)applySettings
{
    if( [self needsToPopulate] || [self customControlSandox] == nil )
    {
        NSString* pathToJSON = [[self propertyContainer] getPathPropertyValue:@"control_location" basePath:nil defaultValue:nil];
        if( pathToJSON )
        {
            if( [self customControlSandox] == nil )
            {
                NSString* jsonRootPath = nil;
                if( [IXAppManager pathIsLocal:pathToJSON] ) {
                    jsonRootPath = [pathToJSON stringByDeletingLastPathComponent];
                } else {
                    jsonRootPath = [[[NSURL URLWithString:pathToJSON] URLByDeletingLastPathComponent] absoluteString];
                }
                
                [self setCustomControlSandox:[[IXSandbox alloc] initWithBasePath:nil rootPath:jsonRootPath]];
                [[self customControlSandox] setViewController:[[self sandbox] viewController]];
                [[self customControlSandox] setContainerControl:[[self sandbox] containerControl]];
                [[self customControlSandox] setDataProviderForRowData:[[self sandbox] dataProviderForRowData]];
                [[self customControlSandox] setIndexPathForRowData:[[self sandbox] indexPathForRowData]];
                [[self customControlSandox] setDataProviders:[[self sandbox] dataProviders]];
                [self setSandbox:[self customControlSandox]];
            }
            if( [self needsToPopulate] )
            {
                BOOL loadAsync = [[self propertyContainer] getBoolPropertyValue:@"load_async" defaultValue:YES];
                [IXJSONParser populateCustomControl:self withJSONAtPath:pathToJSON async:loadAsync];
                [self setNeedsToPopulate:NO];
            }
        }
    }
    
    [super applySettings];
}

@end
