//
//  IXBaseDataprovider.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IXBaseObject.h"
#import "IXConstants.h"
#import <RestKit/CoreData.h>

@class IXTableView;
@class IXPropertyContainer;
@class IXEntityContainer;

@interface IXBaseDataprovider : IXBaseObject

@property (nonatomic,weak) IXTableView* controlListener;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) IXPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IXPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IXPropertyContainer* fileAttachmentProperties;
@property (nonatomic,strong) IXEntityContainer* entityContainer;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;

-(void)loadData;

@end
