//
//  ixeSandbox.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//



/*
 
 
 
 ixe.control.switch

 
 
 
 */
 

#import <Foundation/Foundation.h>

@class ixeBaseObject;
@class ixeViewController;
@class ixeBaseControl;
@class ixeBaseDataprovider;

@interface ixeSandbox : NSObject

@property (nonatomic,weak) ixeViewController* viewController;
@property (nonatomic,weak) ixeBaseControl* containerControl;

@property (nonatomic,strong) NSString* basePath;
@property (nonatomic,strong) NSString* rootPath;

#warning IMPLEMENT THIS METHOD
-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID;
-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(ixeBaseDataprovider*)dataProvider;
-(ixeBaseDataprovider*)getDataProviderWithID:(NSString*)dataProviderID;
-(NSArray*)getDataProvidersWithID:(NSString*)dataProviderID;


-(void)loadAllDataProviders;

@end
