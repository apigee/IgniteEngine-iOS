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

@class IXBaseObject;
@class IXViewController;
@class IXBaseControl;
@class IXBaseDataProvider;
@class IXCoreDataDataProvider;

@interface IXSandbox : NSObject

@property (nonatomic,weak) IXViewController* viewController;
@property (nonatomic,weak) IXBaseControl* containerControl;

@property (nonatomic,weak) IXBaseDataProvider* dataProviderForRowData;
@property (nonatomic,strong) NSIndexPath* indexPathForRowData;

@property (nonatomic,copy) NSString* basePath;
@property (nonatomic,copy) NSString* rootPath;

-(instancetype)initWithBasePath:(NSString*)basePath rootPath:(NSString*)rootPath;

-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(IXBaseDataProvider*)dataProvider;

-(NSArray*)getAllControlsWithID:(NSString*)objectID;
-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID withSelfObject:(IXBaseObject*)selfObject;
-(IXBaseDataProvider*)getDataProviderWithID:(NSString*)dataProviderID;

-(void)loadAllDataProviders;

@end
