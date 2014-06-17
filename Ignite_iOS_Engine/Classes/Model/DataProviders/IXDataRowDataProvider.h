//
//  IXDataRowDataProvider.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 6/12/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXBaseDataProvider.h"

@interface IXDataRowDataProvider : IXBaseDataProvider

@property (nonatomic,copy,readonly) NSString* dataRowBasePath;
@property (nonatomic,copy,readonly) NSString* predicateFormat;
@property (nonatomic,copy,readonly) NSString* predicateArguments;
@property (nonatomic,copy,readonly) NSString* sortDescriptorKey;
@property (nonatomic,copy,readonly) NSString* sortOrder;

@property (nonatomic,readonly) NSPredicate* predicate;
@property (nonatomic,readonly) NSSortDescriptor* sortDescriptor;
@property (nonatomic,readonly) NSUInteger rowCount;

-(NSString*)rowDataRawStringResponse;
-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath;
-(NSString*)rowDataTotalForKeyPath:(NSString*)keyPath;

@end
