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

static NSString* const kIXPredicateFormat = @"predicate.format"; //e.g. "%K CONTAINS[c] %@"
static NSString* const kIXPredicateArguments = @"predicate.arguments"; //e.g. "email,[[inputbox.text]]"
static NSString* const kIXSortOrder = @"sort.order"; //ascending, descending, none (default=none)
static NSString* const kIXSortKey = @"sort.key"; //dataRow key to sort on
static NSString* const kIXDataBaseUrl = @"data.baseurl";
static NSString* const kIXDataPath = @"data.path";
static NSString* const kIXAutoLoad = @"auto_load";

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
    
    [self setAutoLoad:[[self propertyContainer] getBoolPropertyValue:kIXAutoLoad defaultValue:NO]];
    [self setDataLocation:[[self propertyContainer] getStringPropertyValue:kIXDataBaseUrl defaultValue:nil]];
    [self setObjectsPath:[[self propertyContainer] getStringPropertyValue:kIXDataPath defaultValue:nil]];
    [self setPredicateFormat:[[self propertyContainer] getStringPropertyValue:kIXPredicateFormat defaultValue:nil]];
    [self setPredicateArguments:[[self propertyContainer] getStringPropertyValue:kIXPredicateArguments defaultValue:nil]];
    [self setSortDescriptorKey:[[self propertyContainer] getStringPropertyValue:kIXSortKey defaultValue:nil]];
    [self setSortOrder:[[self propertyContainer] getStringPropertyValue:kIXSortOrder defaultValue:@"none"]];
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
    if( [[self sortDescriptorKey] length] > 0 && ![[self sortOrder] isEqualToString:@"none"])
    {
        BOOL sortAscending = YES;
        if ([self.sortOrder isEqualToString:@"descending"])
            sortAscending = NO;
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self sortDescriptorKey]
                                                       ascending:sortAscending
                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return sortDescriptor;
}

-(NSPredicate*)predicate
{
    NSPredicate* predicate = nil;
    @try {
        NSArray* predicateArgumentsArray = [[self predicateArguments] componentsSeparatedByString:kIX_COMMA_SEPERATOR];
        if( [[self predicateFormat] length] > 0 && [predicateArgumentsArray count] > 0 )
        {
            predicate = [NSPredicate predicateWithFormat:[self predicateFormat] argumentArray:predicateArgumentsArray];
            DDLogVerbose(@"%@ : PREDICATE EQUALS : %@",THIS_FILE,[predicate description]);
        }
        return predicate;
    }
    @catch (NSException *exception) {
        DDLogError(@"ERROR - BAD PREDICATE: %@", exception);
        return nil;
    }
    
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
