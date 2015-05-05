//
//  IXJSONUtils.h
//  IgniteEngine
//
//  Created by Brandon on 4/16/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXBaseObject.h"
#import "NSObject+IXAdditions.h"

@interface IXJSONUtils : IXBaseObject

+(NSObject*)setValue:(NSObject*)value forKeyPath:(NSString *)path inContainer:(NSObject*)container;
+(NSObject*)objectForPath:(NSString *)jsonXPath container:(NSObject*)currentNode sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;
+(NSString*)getQueryValueOutOfValue:(NSString*)value sandbox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;
+(NSObject*)appendNewResponseObject:(NSObject *)newObject toPreviousResponseObject:(NSObject *)previousObject forDataPath:(NSString *)dataPath sandox:(IXSandbox*)sandbox baseObject:(IXBaseObject*)baseObject;

@end
