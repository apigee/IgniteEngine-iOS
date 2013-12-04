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

@class IXBaseObject;
@class IXViewController;
@class IXBaseControl;
@class IXBaseDataprovider;

@interface IXSandbox : NSObject

@property (nonatomic,weak) IXViewController* viewController;
@property (nonatomic,weak) IXBaseControl* containerControl;

@property (nonatomic,strong) NSString* basePath;
@property (nonatomic,strong) NSString* rootPath;

-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(IXBaseDataprovider*)dataProvider;

-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID;
-(IXBaseDataprovider*)getDataProviderWithID:(NSString*)dataProviderID;

-(void)loadAllDataProviders;

@end
