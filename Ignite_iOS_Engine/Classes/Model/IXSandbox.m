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
#import "IXLogger.h"
#import "IXViewController.h"

static NSString* const kIXSelfControlRef = @"self";
static NSString* const kIXViewControlRef = @"_view";
static NSString* const kIXCustomContainerControlRef = @"_custom";

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
            DDLogWarn(@"WARNING from %@ in %@ : INITIALIZING SANDBOX WITHOUT ROOT PATH!!!",THIS_FILE,THIS_METHOD);
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

-(NSArray*)getAllControlsAndDataProvidersWithIDs:(NSArray*)objectIDs withSelfObject:(IXBaseObject*)selfObject
{
    NSMutableArray* returnArray = nil;
    if( [objectIDs count] )
    {
        returnArray = [[NSMutableArray alloc] init];
        for( NSString* objectID in objectIDs )
        {
            NSArray* objectsWithID = [self getAllControlAndDataProvidersWithID:objectID
                                                                withSelfObject:selfObject];
            [returnArray addObjectsFromArray:objectsWithID];
        }
    }
    return returnArray;
}

-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject;
{
    NSArray* returnArray = nil;
    if( [objectID isEqualToString:kIXSelfControlRef] )
    {
        if( selfObject )
        {
            returnArray = @[selfObject];
        }
    }
    else if( [objectID isEqualToString:kIXCustomContainerControlRef] )
    {
        if( [self customControlContainer] )
        {
            returnArray = @[[self customControlContainer]];
        }
    }
    else if( [objectID isEqualToString:kIXViewControlRef] )
    {
        if( [[self viewController] containerControl] )
        {
            returnArray = @[[[self viewController] containerControl]];
        }
    }
    else
    {
        NSMutableArray* arrayOfObjects = [[NSMutableArray alloc] initWithArray:[[self containerControl] childrenWithID:objectID]];
        IXBaseDataProvider* dataProviderWithObjectID = [self getDataProviderWithID:objectID];
        if( dataProviderWithObjectID )
        {
            [arrayOfObjects addObject:dataProviderWithObjectID];
        }
        returnArray = arrayOfObjects;
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
    if( dataProviderID.length > 0 )
    {
        if( [self dataProviders][dataProviderID] != nil )
        {
            if( [[self dataProviders][dataProviderID] isEqual:dataProvider] )
            {
                DDLogWarn(@"WARNING from %@ in %@ :  ATTEMPTING TO ADD SAME DATA PROVIDER TO SANDBOX TWICE",THIS_FILE,THIS_METHOD);
            }
            else
            {
                DDLogError(@"ERROR from %@ in %@ :  CONFLICTING DATASOURCE IDS WITH ID : %@",THIS_FILE,THIS_METHOD,dataProviderID);
            }
        }
        
        [dataProvider setSandbox:self];
        [self dataProviders][dataProviderID] = dataProvider;
        
        didAddDataProvider = YES;
    }
    else
    {
        DDLogError(@"ERROR from %@ in %@ :  ATTEMPTING TO ADD DATAPROVIDER WITHOUT ID : %@",THIS_FILE,THIS_METHOD,[dataProvider description]);
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
    IXBaseDataProvider* returnDataProvider = [self dataProviders][dataProviderID];
    if( returnDataProvider == nil && ![self isEqual:[[IXAppManager sharedAppManager] applicationSandbox]] )
    {
        returnDataProvider = [[[IXAppManager sharedAppManager] applicationSandbox] getDataProviderWithID:dataProviderID];
    }
    return returnDataProvider;
}

@end
