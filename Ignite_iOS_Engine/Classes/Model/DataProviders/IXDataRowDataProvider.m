//
//  IXDataRowDataProvider.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/12/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXDataRowDataProvider.h"

#warning These haven't been renamed yet

// IXDataRowDataProvider Attributes
IX_STATIC_CONST_STRING kIXDataRowBasePath = @"datarow.basepath";
IX_STATIC_CONST_STRING kIXPredicateFormat = @"predicate.format";            //e.g. "%K CONTAINS[c] %@"
IX_STATIC_CONST_STRING kIXPredicateArguments = @"predicate.arguments";      //e.g. "email,[[inputbox.text]]"
IX_STATIC_CONST_STRING kIXSortOrder = @"sort.order";
IX_STATIC_CONST_STRING kIXSortKey = @"sort.key";                            //dataRow key to sort on

// kIXSortOrder Accepted Types
IX_STATIC_CONST_STRING kIXSortOrderNone = @"none";
IX_STATIC_CONST_STRING kIXSortOrderAscending = @"ascending";
IX_STATIC_CONST_STRING kIXSortOrderDescending = @"descending";

// IXDataRowDataProvider Read-Only Attributes
IX_STATIC_CONST_STRING kIXRawDataResponse = @"raw_data_response";
IX_STATIC_CONST_STRING kIXCount = @"count_rows";

// Non Attribute constants.
#warning We probably should rename dataRow to something more consistenc.
IX_STATIC_CONST_STRING kIXDataRow = @"dataRow.";
IX_STATIC_CONST_STRING kIXTotal = @"total.";

@interface IXDataRowDataProvider ()

@property (nonatomic,copy) NSString* dataRowBasePath;
@property (nonatomic,copy) NSString* predicateFormat;
@property (nonatomic,copy) NSString* predicateArguments;
@property (nonatomic,copy) NSString* sortDescriptorKey;
@property (nonatomic,copy) NSString* sortOrder;

@end

@implementation IXDataRowDataProvider

-(void)applySettings
{
    [super applySettings];
    
    [self setDataRowBasePath:[[self propertyContainer] getStringPropertyValue:kIXDataRowBasePath defaultValue:nil]];
    [self setPredicateFormat:[[self propertyContainer] getStringPropertyValue:kIXPredicateFormat defaultValue:nil]];
    [self setPredicateArguments:[[self propertyContainer] getStringPropertyValue:kIXPredicateArguments defaultValue:nil]];
    [self setSortDescriptorKey:[[self propertyContainer] getStringPropertyValue:kIXSortKey defaultValue:nil]];
    [self setSortOrder:[[self propertyContainer] getStringPropertyValue:kIXSortOrder defaultValue:kIXSortOrderNone]];
}

-(void)loadData:(BOOL)forceGet
{
    [super loadData:forceGet];
}

-(NSString *)getReadOnlyPropertyValue:(NSString *)propertyName
{
    NSString* returnValue = nil;
    if( [propertyName isEqualToString:kIXCount] )
    {
        returnValue = [NSString stringWithFormat:@"%li",(long)[self rowCount:nil]];
    }
    else if( [propertyName isEqualToString:kIXTotal] )
    {
        returnValue = [self rowDataTotalForKeyPath:propertyName];
    }
    else if( [propertyName hasPrefix:kIXDataRow] )
    {
        NSString* remainingKeyPathString = [propertyName stringByReplacingOccurrencesOfString:kIXDataRow withString:kIX_EMPTY_STRING];
        if( [remainingKeyPathString length] > 0 )
        {
            if( [remainingKeyPathString isEqualToString:kIXRawDataResponse] )
            {
                returnValue = [self rowDataRawStringResponse];
            }
            else if( [remainingKeyPathString hasPrefix:kIXTotal] )
            {
                remainingKeyPathString = [remainingKeyPathString stringByReplacingOccurrencesOfString:kIXTotal withString:kIX_EMPTY_STRING];
                if( [remainingKeyPathString length] > 0 )
                {
                    returnValue = [self rowDataTotalForKeyPath:remainingKeyPathString];
                }
            }
        }
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
    if( [[self sortDescriptorKey] length] > 0 && ![[self sortOrder] isEqualToString:kIXSortOrderNone])
    {
        BOOL sortAscending = YES;
        if ([self.sortOrder isEqualToString:kIXSortOrderDescending])
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
            IX_LOG_VERBOSE(@"%@ : PREDICATE EQUALS : %@",THIS_FILE,[predicate description]);
        }
        return predicate;
    }
    @catch (NSException *exception) {
        IX_LOG_ERROR(@"ERROR - BAD PREDICATE: %@", exception);
        return nil;
    }
}

-(NSUInteger)rowCount:(NSString*)dataRowBasePath
{
    return 0;
}

-(NSString*)rowDataRawStringResponse
{
    return nil;
}

-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath dataRowBasePath:(NSString*)dataRowPath
{
    return nil;
}

-(NSString*)rowDataTotalForKeyPath:(NSString*)keyPath
{
    NSInteger rowCount = [self rowCount:nil];
    NSDecimalNumber* rowTotal = [NSDecimalNumber zero];
    for( int i = 0; i < rowCount; i++ )
    {
        NSString* rowDataForIndex = [self rowDataForIndexPath:[NSIndexPath indexPathForRow:i inSection:0] keyPath:keyPath dataRowBasePath:[self dataRowBasePath]];
        if( rowDataForIndex )
        {
            NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:rowDataForIndex];
            if( decimalNumber != nil )
            {
                rowTotal = [rowTotal decimalNumberByAdding:decimalNumber];
            }
        }
    }
    return [rowTotal stringValue];
}

@end
