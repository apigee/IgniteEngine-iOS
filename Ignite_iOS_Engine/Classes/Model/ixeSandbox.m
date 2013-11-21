//
//  ixeSandbox.m
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeSandbox.h"

#import "ixeBaseObject.h"
#import "ixeBaseControl.h"
#import "ixeBaseDataprovider.h"

@interface ixeSandbox ()

@property (nonatomic,strong) NSMutableDictionary* dataProviders;

@end

@implementation ixeSandbox

@synthesize containerControl = _containerControl;

-(id)init
{
    self = [super init];
    if( self )
    {
        _dataProviders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(ixeBaseControl*)containerControl
{
    return _containerControl;
}

-(void)setContainerControl:(ixeBaseControl *)containerControl
{
    _containerControl = containerControl;
    [_containerControl setSandbox:self];
}

-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID
{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    
    NSArray* controlsWithObjectID = [[self containerControl] childrenWithID:objectID];
    [returnArray addObjectsFromArray:controlsWithObjectID];

    NSArray* dataProvidersWithObjectID = [self getDataProvidersWithID:objectID];
    [returnArray addObjectsFromArray:dataProvidersWithObjectID];
    
    return returnArray;
}

-(void)addDataProviders:(NSArray*)dataProviders
{
    for( ixeBaseDataprovider* dataProvider in dataProviders )
    {
        [self addDataProvider:dataProvider];
    }
}

-(BOOL)addDataProvider:(ixeBaseDataprovider*)dataProvider
{
    BOOL didAddDataProvider = NO;
    
    NSString* dataProviderID = [[dataProvider propertyContainer] getStringPropertyValue:@"id" defaultValue:nil];
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
    for( ixeBaseDataprovider* dataProvider in [[self dataProviders] allValues] )
    {
        [dataProvider applySettings];
        if( [dataProvider shouldAutoLoad] )
        {
            [dataProvider loadData];
        }        
    }
}

-(ixeBaseDataprovider*)getDataProviderWithID:(NSString*)dataProviderID
{
    return [[self dataProviders] objectForKey:dataProviderID];
}

-(NSArray*)getDataProvidersWithID:(NSString*)dataProviderID
{
    return [[self dataProviders] objectForKey:dataProviderID];
}

@end
