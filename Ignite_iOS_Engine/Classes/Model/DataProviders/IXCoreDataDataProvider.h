//
//  IXCoreDataDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXDataRowDataProvider.h"
#import <RestKit/CoreData.h>

@class IXEntityContainer;

@interface IXCoreDataDataProvider : IXDataRowDataProvider

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) IXEntityContainer* entityContainer;

@end
