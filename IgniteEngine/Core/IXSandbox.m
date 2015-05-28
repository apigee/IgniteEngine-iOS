//
//  IXSandbox.m
//  Ignite Engine
//
//  Created by Robert Walsh on 10/9/13.
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

#import "IXSandbox.h"

#import "IXAppManager.h"
#import "IXBaseObject.h"
#import "IXBaseControl.h"
#import "IXBaseDataProvider.h"
#import "IXDataRowDataProvider.h"
#import "IXAppManager.h"
#import "IXLogger.h"
#import "IXCustom.h"
#import "IXViewController.h"

#import "MMDrawerController.h"

NSString* const kIXSelfControlRef = @"$self";
NSString* const kIXViewControlRef = @"$view";
NSString* const kIXSessionRef = @"$session";
NSString* const kIXAppRef = @"$app";
NSString* const kIXCustomContainerControlRef = @"$custom";

// NSCoding Key Constants
static NSString* const kIXBasePathNSCodingKey = @"basePath";
static NSString* const kIXRootPathNSCodingKey = @"rootPath";
static NSString* const kIXDataProvidersNSCodingKey = @"dataProviders";

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
            IX_LOG_WARN(@"WARNING from %@ in %@ : INITIALIZING SANDBOX WITHOUT ROOT PATH!!!",THIS_FILE,THIS_METHOD);
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self basePath] forKey:kIXBasePathNSCodingKey];
    [aCoder encodeObject:[self rootPath] forKey:kIXRootPathNSCodingKey];
    [aCoder encodeObject:[self dataProviders] forKey:kIXDataProvidersNSCodingKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithBasePath:[aDecoder decodeObjectForKey:kIXBasePathNSCodingKey]
                         rootPath:[aDecoder decodeObjectForKey:kIXRootPathNSCodingKey]];
    NSDictionary* dataProviders = [aDecoder decodeObjectForKey:kIXDataProvidersNSCodingKey];
    for( IXBaseDataProvider* dataProvider in [dataProviders allValues] )
    {
        [self addDataProvider:dataProvider];
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
    
    NSString* dataProviderID = [[dataProvider attributeContainer] getStringValueForAttribute:kIX_ID defaultValue:nil];
    if( dataProviderID.length > 0 )
    {
        if( [self dataProviders][dataProviderID] != nil )
        {
            if( [[self dataProviders][dataProviderID] isEqual:dataProvider] )
            {
                IX_LOG_WARN(@"WARNING from %@ in %@ :  ATTEMPTING TO ADD SAME DATA PROVIDER TO SANDBOX TWICE",THIS_FILE,THIS_METHOD);
            }
            else
            {
                IX_LOG_ERROR(@"ERROR from %@ in %@ :  CONFLICTING DATASOURCE IDS WITH ID : %@",THIS_FILE,THIS_METHOD,dataProviderID);
            }
        }
        
        [dataProvider setSandbox:self];
        
        if( ![self dataProviders] )
        {
            [self setDataProviders:[[NSMutableDictionary alloc] initWithObjects:@[dataProvider] forKeys:@[dataProviderID]]];
        }
        else
        {
            [self dataProviders][dataProviderID] = dataProvider;
        }
        
        didAddDataProvider = YES;
    }
    else
    {
        IX_LOG_ERROR(@"ERROR from %@ in %@ :  ATTEMPTING TO ADD DATAPROVIDER WITHOUT ID : %@",THIS_FILE,THIS_METHOD,[dataProvider description]);
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
    if( [dataProviderID length] > 0 && returnDataProvider == nil && (self != [[IXAppManager sharedAppManager] applicationSandbox]) )
    {
        returnDataProvider = [[[IXAppManager sharedAppManager] applicationSandbox] getDataProviderWithID:dataProviderID];
    }
    return returnDataProvider;
}

-(IXDataRowDataProvider*)getDataRowDataProviderWithID:(NSString*)dataProviderID
{
    IXDataRowDataProvider* returnDataProvider = nil;
    IXBaseDataProvider* dataProviderWithID = [self getDataProviderWithID:dataProviderID];
    if( [dataProviderWithID isKindOfClass:[IXDataRowDataProvider class]] )
    {
        returnDataProvider = (IXDataRowDataProvider*)dataProviderWithID;
    }
    return returnDataProvider;
}

-(NSArray*)getAllControlsWithID:(NSString*)objectID
{
    return [self getAllControlsWithID:objectID withSelfObject:nil];
}

-(NSArray*)getAllControlsAndDataProvidersWithIDs:(NSArray*)objectIDs withSelfObject:(IXBaseObject*)selfObject
{
    NSMutableArray* returnArray = nil;
    if( [objectIDs count] > 0 )
    {
        returnArray = [[NSMutableArray alloc] init];
        for( NSString* objectID in objectIDs )
        {
            NSArray* objectsWithID = [self getAllControlsAndDataProvidersWithID:objectID
                                                                 withSelfObject:selfObject];
            [returnArray addObjectsFromArray:objectsWithID];
        }
    }
    return returnArray;
}

-(NSArray*)getAllControlsAndDataProvidersWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject
{
    NSArray* returnArray = nil;
    if( [objectID length] > 0 )
    {
        NSMutableArray* arrayOfObjects = [[NSMutableArray alloc] initWithArray:[self getAllControlsWithID:objectID withSelfObject:selfObject]];
        
        IXBaseDataProvider* dataProviderWithObjectID = [self getDataProviderWithID:objectID];
        if( dataProviderWithObjectID )
        {
            [arrayOfObjects addObject:dataProviderWithObjectID];
        }
        
        if( [arrayOfObjects count] )
        {
            returnArray = arrayOfObjects;
        }
    }
    return returnArray;
}

-(NSArray*)getAllControlsWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject
{
    return [self getAllControlsWithID:objectID withSelfObject:selfObject alreadySearchedSandboxes:nil];
}

-(NSArray*)getAllControlsWithID:(NSString*)objectID withSelfObject:(IXBaseObject *)selfObject alreadySearchedSandboxes:(NSArray*)searchedSandboxes
{
    NSArray* returnArray = nil;
    if( [objectID length] > 0 )
    {
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
            NSMutableArray* arrayOfControls = [NSMutableArray array];
            if( [self customControlContainer] )
            {
                [arrayOfControls addObjectsFromArray:[[self customControlContainer] childrenWithID:objectID]];
            }
            if( ![arrayOfControls count] )
            {
                [arrayOfControls addObjectsFromArray:[[self containerControl] childrenWithID:objectID]];
            }
            if( ![arrayOfControls count] )
            {
                NSMutableArray* sandboxesToSkip = [NSMutableArray arrayWithArray:searchedSandboxes];
                [sandboxesToSkip addObject:self];
                
                IXSandbox* currentViewControllerSandbox = [[[IXAppManager sharedAppManager] currentIXViewController] sandbox];
                IXSandbox* leftDrawerSandbox = [(IXViewController*)[[[IXAppManager sharedAppManager] drawerController] leftDrawerViewController] sandbox];
                IXSandbox* rightDrawerSandbox = [(IXViewController*)[[[IXAppManager sharedAppManager] drawerController] rightDrawerViewController] sandbox];
                
                if( currentViewControllerSandbox != nil && ![sandboxesToSkip containsObject:currentViewControllerSandbox] && [self containerControl] == [currentViewControllerSandbox containerControl] )
                {
                    [sandboxesToSkip addObject:currentViewControllerSandbox];
                }
                
                if( currentViewControllerSandbox != nil && ![sandboxesToSkip containsObject:currentViewControllerSandbox] )
                {
                    [arrayOfControls addObjectsFromArray:[currentViewControllerSandbox getAllControlsWithID:objectID withSelfObject:nil alreadySearchedSandboxes:sandboxesToSkip]];
                }
                else if( leftDrawerSandbox != nil && ![sandboxesToSkip containsObject:leftDrawerSandbox] )
                {
                    [arrayOfControls addObjectsFromArray:[leftDrawerSandbox getAllControlsWithID:objectID withSelfObject:nil alreadySearchedSandboxes:sandboxesToSkip]];
                }
                else if( rightDrawerSandbox != nil && ![sandboxesToSkip containsObject:rightDrawerSandbox] )
                {
                    [arrayOfControls addObjectsFromArray:[rightDrawerSandbox getAllControlsWithID:objectID withSelfObject:nil alreadySearchedSandboxes:sandboxesToSkip]];
                }
            }
            returnArray = arrayOfControls;
        }
    }
    return returnArray;
}

@end
