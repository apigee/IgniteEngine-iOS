//
//  IXSandbox.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//



/*
 
 
 
 IX.control.switch

 
 
 
 */
 

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>

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
