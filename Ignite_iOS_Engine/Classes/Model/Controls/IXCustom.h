//
//  IXCustom.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/4/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXLayout.h"

@interface IXCustom : IXLayout

@property (nonatomic,assign,getter = isFirstLoad) BOOL firstLoad;
@property (nonatomic,strong) NSString* pathToJSON;
@property (nonatomic,strong) NSArray* dataProviders;

@end
