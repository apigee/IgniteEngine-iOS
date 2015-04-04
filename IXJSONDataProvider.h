//
//  IXJSONDataProvider.h
//  Ignite Engine
//
//  Created by Robert Walsh on 12/6/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXDataRowDataProvider.h"

@interface IXJSONDataProvider : IXDataRowDataProvider

@property (nonatomic,strong) id lastJSONResponse;
@property (nonatomic,strong) NSMutableDictionary* rowDataResultsDict;
- (NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*) currentNode;

@end
