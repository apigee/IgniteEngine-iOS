//
//  NSURL+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/23/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (IXAdditions)

-(NSDictionary*)ix_parseQueryStringToParamsDict;

@end
