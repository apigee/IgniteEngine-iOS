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

@property (nonatomic,strong) NSManagedObject* dataProviderManagedObjectForRowData;
@property (nonatomic,weak) IXCoreDataDataProvider* dataProviderForRowData;
@property (nonatomic,strong) NSIndexPath* indexPathForRowData;

@property (nonatomic,strong) NSString* basePath;
@property (nonatomic,strong) NSString* rootPath;

-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(IXBaseDataProvider*)dataProvider;

-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID;
-(IXBaseDataProvider*)getDataProviderWithID:(NSString*)dataProviderID;

-(void)loadAllDataProviders;

@end
