//
//  IxSandbox.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/9.
//  Copyright (c) 2013 All rights reserved.
//



/*
 
 
 
 Ix.control.switch

 
 
 
 */
 

#import <Foundation/Foundation.h>

@class IxBaseObject;
@class IxViewController;
@class IxBaseControl;
@class IxBaseDataprovider;

@interface IxSandbox : NSObject

@property (nonatomic,weak) IxViewController* viewController;
@property (nonatomic,weak) IxBaseControl* containerControl;

@property (nonatomic,strong) NSString* basePath;
@property (nonatomic,strong) NSString* rootPath;

#warning IMPLEMENT THIS METHOD
-(NSArray*)getAllControlAndDataProvidersWithID:(NSString*)objectID;
-(void)addDataProviders:(NSArray*)dataProviders;
-(BOOL)addDataProvider:(IxBaseDataprovider*)dataProvider;
-(IxBaseDataprovider*)getDataProviderWithID:(NSString*)dataProviderID;
-(NSArray*)getDataProvidersWithID:(NSString*)dataProviderID;


-(void)loadAllDataProviders;

@end
