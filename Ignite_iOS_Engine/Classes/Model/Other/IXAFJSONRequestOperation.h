//
//  IXAFJSONRequestOperation.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "AFJSONRequestOperation.h"

@interface IXAFJSONRequestOperation : AFJSONRequestOperation

+(void)addAcceptedContentType:(NSString*)contentType;

@end
