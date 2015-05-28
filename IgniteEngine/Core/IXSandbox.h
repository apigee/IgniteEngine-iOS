//
//  IXSandbox.h
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


#import <Foundation/Foundation.h>
//#import <RestKit/CoreD÷ata.h>

@class IXCustom;
@class IXBaseObject;
@class IXViewController;
@class IXBaseControl;
@class IXBaseDataProvider;
@class IXDataRowDataProvider;

extern NSString* const kIXSelfControlRef;
extern NSString* const kIXViewControlRef;
extern NSString* const kIXSessionRef;
extern NSString* const kIXAppRef;
extern NSString* const kIXCustomContainerControlRef;

@interface IXSandbox : NSObject <NSCoding>

@property (nonatomic,weak) IXViewController* viewController;
@property (nonatomic,weak) IXBaseControl* containerControl;
@property (nonatomic,weak) IXBaseControl* customControlContainer;

@property (nonatomic,weak) IXDataRowDataProvider* dataProviderForRowData;
@property (nonatomic,copy) NSString* dataRowBasePathForRowData;
@property (nonatomic,strong) NSIndexPath* indexPathForRowData;

@property (nonatomic,copy) NSString* basePath;
@property (nonatomic,copy) NSString* rootPath;

-(instancetype)initWithBasePath:(NSString*)basePath rootPath:(NSString*)rootPath;

-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(IXBaseDataProvider*)dataProvider;

-(NSArray*)getAllControlsWithID:(NSString*)objectID;
-(NSArray*)getAllControlsWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject;
-(NSArray*)getAllControlsAndDataProvidersWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject;
-(NSArray*)getAllControlsAndDataProvidersWithIDs:(NSArray*)objectIDs withSelfObject:(IXBaseObject*)selfObject;
-(IXBaseDataProvider*)getDataProviderWithID:(NSString*)dataProviderID;
-(IXDataRowDataProvider*)getDataRowDataProviderWithID:(NSString*)dataProviderID;

-(void)loadAllDataProviders;

@end
