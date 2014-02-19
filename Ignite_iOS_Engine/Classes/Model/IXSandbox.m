//
//  IXSandbox.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXSandbox.h"

#import "IXBaseObject.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"
#import "IXAppManager.h"

static NSString* const kIXSelfControlRef = @"self";

@interface IXSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@implementation IXSandbox

@synthesize containerControl = _containerControl;

-(instancetype)init
{
    return [self initWithBasePath:nil rootPath:nil];
}

-(instancetype)initWithBasePath:(NSString*)basePath rootPath:(NSString*)rootPath
{
    self = [super init];
    if( self )
    {
        _basePath = [basePath copy];
        _rootPath = [rootPath copy];
        
        if( _rootPath == nil )
        {
            NSLog(@"WARNING INITIALIZING SANDBOX WITHOUT ROOT PATH!!!");
        }
        
        _dataProviders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(IXBaseControl*)containerControl
{
    return _containerControl;
}

-(void)setContainerControl:(IXBaseControl *)containerControl
{
    _containerControl = containerControl;
}

-(NSArray*)getAllControlsWithID:(NSString*)objectID
{
    NSArray* controlsWithObjectID = [[self containerControl] childrenWithID:objectID];
    return controlsWithObjectID;
}

-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject;
{
    if( [objectID isEqualToString:kIXSelfControlRef] )
    {
        NSArray* returnArray = nil;
        if( selfObject )
            returnArray = [NSArray arrayWithObject:selfObject];
        return returnArray;
    }
    
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    
    NSArray* controlsWithObjectID = [[self containerControl] childrenWithID:objectID];
    [returnArray addObjectsFromArray:controlsWithObjectID];

    IXBaseDataProvider* dataProviderWithObjectID = [self getDataProviderWithID:objectID];
    if( dataProviderWithObjectID )
    {
        [returnArray addObject:dataProviderWithObjectID];
    }
    
    return returnArray;
}

-(void)addDataProviders:(NSArray*)dataProviders
{
    for( IXBaseDataProvider* dataProvider in dataProviders )
    {
        [self addDataProvider:dataProvider];
    }
}

-(BOOL)addDataProvider:(IXBaseDataProvider*)dataProvider
{
    BOOL didAddDataProvider = NO;
    
    NSString* dataProviderID = [[dataProvider propertyContainer] getStringPropertyValue:kIX_ID defaultValue:nil];
    if( dataProviderID != nil && ![dataProviderID isEqualToString:@""] )
    {
        if( [[self dataProviders] objectForKey:dataProviderID] != nil )
        {
            if( [[[self dataProviders] objectForKey:dataProvider] isEqual:dataProvider] )
            {
                NSLog(@"WARNING: ATTEMPTING TO ADD SAME DATA PROVIDER TO SANDBOX TWICE");
            }
            else
            {
                NSLog(@"WARNING: CONFLICTING DATASOURCE IDS");
            }
        }
        
        [dataProvider setSandbox:self];
        [[self dataProviders] setObject:dataProvider forKey:dataProviderID];
        
        didAddDataProvider = YES;
    }
    else
    {
        NSLog(@"WARNING: ATTEMPTING TO ADD DATAPROVIDER WITHOUT ID");
    }
    
    return didAddDataProvider;
}

-(void)loadAllDataProviders
{
    for( IXBaseDataProvider* dataProvider in [[self dataProviders] allValues] )
    {
        [dataProvider applySettings];
        if( [dataProvider shouldAutoLoad] )
        {
            [dataProvider loadData:YES];
        }        
    }
}

-(IXBaseDataProvider*)getDataProviderWithID:(NSString*)dataProviderID
{
    IXBaseDataProvider* returnDataProvider = [[self dataProviders] objectForKey:dataProviderID];
    if( returnDataProvider == nil && [self isEqual:[[IXAppManager sharedAppManager] applicationSandbox]] )
    {
        returnDataProvider = [[[IXAppManager sharedAppManager] applicationSandbox] getDataProviderWithID:dataProviderID];
    }
    return returnDataProvider;
}

@end
