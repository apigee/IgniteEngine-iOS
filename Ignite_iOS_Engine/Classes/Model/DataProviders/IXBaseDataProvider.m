//
//  IXBaseDataProvider.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseDataProvider.h"

#import "IXPropertyContainer.h"
#import "IXTableView.h"
#import "IXEntityContainer.h"
#import "IXAppManager.h"

#import <RestKit/RestKit.h>

@interface IXBaseDataProvider ()

@end

@implementation IXBaseDataProvider

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

-(id)init
{
    self = [super init];
    if( self )
    {
        _delegates = [[NSMutableArray alloc] init];
        _requestParameterProperties = [[IXPropertyContainer alloc] init];
        _requestHeaderProperties = [[IXPropertyContainer alloc] init];
        _fileAttachmentProperties = [[IXPropertyContainer alloc] init];
    }
    return self;
}

-(void)setRequestHeaderProperties:(IXPropertyContainer *)requestHeaderProperties
{
    _requestHeaderProperties = requestHeaderProperties;
    [_requestHeaderProperties setOwnerObject:self];
}

-(void)setRequestParameterProperties:(IXPropertyContainer *)requestParameterProperties
{
    _requestParameterProperties = requestParameterProperties;
    [_requestParameterProperties setOwnerObject:self];
}

-(void)setFileAttachmentProperties:(IXPropertyContainer *)fileAttachmentProperties
{
    _fileAttachmentProperties = fileAttachmentProperties;
    [_fileAttachmentProperties setOwnerObject:self];
}

-(void)addDelegate:(id<IXDataProviderDelegate>)delegate
{
    if( delegate )
        [[self delegates] addObject:delegate];
}

-(void)removeDelegate:(id<IXDataProviderDelegate>)delegate
{
    if( delegate )
        [[self delegates] removeObject:delegate];
}

-(void)notifyAllDelegates
{
    for( id<IXDataProviderDelegate> delegate in [self delegates] )
    {
        [delegate dataProviderDidUpdate:self];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:@"auto_load" defaultValue:NO]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:@"data_location" defaultValue:nil]];
    [self setObjectsPath:[[self propertyContainer] getStringPropertyValue:@"objects_path" defaultValue:nil]];
    [self setFetchPredicate:[[self propertyContainer] getStringPropertyValue:@"fetch_predicate" defaultValue:nil]];
    [self setFetchPredicateStrings:[[self propertyContainer] getStringPropertyValue:@"fetch_predicate_strings" defaultValue:nil]];
    [self setSortDescriptorKey:[[self propertyContainer] getStringPropertyValue:@"fetch_sort_descriptor_key" defaultValue:nil]];
    [self setSortAscending:[[self propertyContainer] getBoolPropertyValue:@"fetch_sort_ascending" defaultValue:YES]];
}

-(void)loadData:(BOOL)forceGet
{
    // Base Provider does nothing... Might need to update this.
}

-(void)fireLoadFinishedEvents:(BOOL)loadDidSucceed
{
    if( loadDidSucceed )
    {
        [[self actionContainer] executeActionsForEventNamed:@"success"];
    }
    else
    {
        [[self actionContainer] executeActionsForEventNamed:@"fail"];
    }
    [[self actionContainer] executeActionsForEventNamed:@"finished"];
    [self notifyAllDelegates];
}

-(NSString*)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:@"raw_data_response"] )
    {
        returnValue = [[self rawResponse] copy];
    }
    else if( [propertyName isEqualToString:@"status_code"] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self lastResponseStatusCode]];
    }
    else if( [propertyName isEqualToString:@"error_message"] )
    {
        returnValue = [[self lastResponseErrorMessage] copy];
    }
    else if( [propertyName isEqualToString:@"count"] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self getRowCount]];
    }
    else
    {
        returnValue = [super getReadOnlyPropertyValue:propertyName];
    }
    return returnValue;
}

-(NSSortDescriptor*)sortDescriptor
{
    NSSortDescriptor* sortDescriptor = nil;
    if( [self sortDescriptorKey] != nil && ![[self sortDescriptorKey] isEqualToString:@""] )
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self sortDescriptorKey]
                                                       ascending:[self sortAscending]
                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return sortDescriptor;
}

-(NSPredicate*)predicate
{
    NSPredicate* predicate = nil;
    NSArray* fetchPredicateStringsArray = [[self fetchPredicateStrings] componentsSeparatedByString:@","];
    if( [self fetchPredicate] != nil && ![[self fetchPredicate] isEqualToString:@""] && [fetchPredicateStringsArray count] > 0 )
    {
        predicate = [NSPredicate predicateWithFormat:[self fetchPredicate] argumentArray:fetchPredicateStringsArray];
        if( [[IXAppManager sharedAppManager] appMode] == IXDebugMode )
        {
            NSLog(@"PREDICATE EQUALS : %@",[predicate description]);
        }
    }
    return predicate;
}

-(NSUInteger)getRowCount
{
    return 0;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath
{
    return nil;
}

@end
