//
//  IXDataRowDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 6/12/14.
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

#import "IXBaseDataProvider.h"

@interface IXDataRowDataProvider : IXBaseDataProvider

@property (nonatomic,copy,readonly) NSString* dataRowBasePath;
@property (nonatomic,copy,readonly) NSString* predicateFormat;
@property (nonatomic,copy,readonly) NSString* predicateArguments;
@property (nonatomic,copy,readonly) NSString* sortDescriptorKey;
@property (nonatomic,copy,readonly) NSString* sortOrder;

@property (nonatomic,readonly) NSPredicate* predicate;
@property (nonatomic,readonly) NSSortDescriptor* sortDescriptor;

-(NSUInteger)rowCount:(NSString*)dataRowBasePath;
-(NSString*)rowDataRawStringResponse;
-(NSString*)rowDataForIndexPath:(NSIndexPath*)rowIndexPath keyPath:(NSString*)keyPath dataRowBasePath:(NSString*)dataRowBasePath;
-(NSString*)rowDataTotalForKeyPath:(NSString*)keyPath;

@end
