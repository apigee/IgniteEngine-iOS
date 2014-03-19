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
#import "IXLogger.h"

#import <RestKit/RestKit.h>

NSString* IXBaseDataProviderDidUpdateNotification = @"IXBaseDataProviderDidUpdateNotification";

@interface IXBaseDataProvider ()

@end

@implementation IXBaseDataProvider

+(void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
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

-(void)applySettings
{
    [super applySettings];
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:@"auto_load" defaultValue:NO]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:@"data.baseurl" defaultValue:nil]];
    [self setObjectsPath:[[self propertyContainer] getStringPropertyValue:@"data.path" defaultValue:nil]];
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
        [[self actionContainer] executeActionsForEventNamed:kIX_SUCCESS];
    }
    else
    {
        [[self actionContainer] executeActionsForEventNamed:kIX_FAILED];
    }
    [[self actionContainer] executeActionsForEventNamed:kIX_FINISHED];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IXBaseDataProviderDidUpdateNotification
                                                        object:self];
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
    if( [[self sortDescriptorKey] length] > 0 )
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
    NSArray* fetchPredicateStringsArray = [[self fetchPredicateStrings] componentsSeparatedByString:kIX_COMMA_SEPERATOR];
    if( [[self fetchPredicate] length] > 0 && [fetchPredicateStringsArray count] > 0 )
    {
        predicate = [NSPredicate predicateWithFormat:[self fetchPredicate] argumentArray:fetchPredicateStringsArray];
        DDLogVerbose(@"%@ : PREDICATE EQUALS : %@",THIS_FILE,[predicate description]);
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
