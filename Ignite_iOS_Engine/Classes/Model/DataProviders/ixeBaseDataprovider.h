//
//  ixeBaseDataprovider.h
//  Ignite iOS Engine (ixe)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "ixeBaseObject.h"
#import "ixeConstants.h"
#import <RestKit/CoreData.h>

@class ixeTableView;
@class ixePropertyContainer;
@class ixeEntityContainer;

@interface ixeBaseDataprovider : ixeBaseObject

@property (nonatomic,weak) ixeTableView* controlListener;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) ixePropertyContainer* requestParameterProperties;
@property (nonatomic,strong) ixePropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) ixePropertyContainer* fileAttachmentProperties;
@property (nonatomic,strong) ixeEntityContainer* entityContainer;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;

-(void)loadData;

@end
