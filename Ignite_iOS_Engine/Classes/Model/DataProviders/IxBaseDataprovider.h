//
//  IxBaseDataprovider.h
//  Ignite iOS Engine (Ix)
//
//  Created by Robert Walsh on 10/3.
//  Copyright (c) 2013 All rights reserved.
//

#import "IxBaseObject.h"
#import "IxConstants.h"
#import <RestKit/CoreData.h>

@class IxTableView;
@class IxPropertyContainer;
@class IxEntityContainer;

@interface IxBaseDataprovider : IxBaseObject

@property (nonatomic,weak) IxTableView* controlListener;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong) IxPropertyContainer* requestParameterProperties;
@property (nonatomic,strong) IxPropertyContainer* requestHeaderProperties;
@property (nonatomic,strong) IxPropertyContainer* fileAttachmentProperties;
@property (nonatomic,strong) IxEntityContainer* entityContainer;

@property (nonatomic,assign,getter = shouldAutoLoad) BOOL autoLoad;

-(void)loadData;

@end
