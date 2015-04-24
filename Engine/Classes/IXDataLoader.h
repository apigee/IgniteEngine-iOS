//
//  IXDataLoader.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RXMLElement;

typedef void(^IXJSONGrabCompletedBlock)(id jsonObject, NSString* stringValue, NSError *error);
typedef void(^IXXMLGrabCompletedBlock)(RXMLElement* rXMLElement, NSString* stringValue, NSError *error);

@interface IXDataLoader : NSObject

+(IXDataLoader*)sharedDataLoader;
+(void)clearCache;

-(void)loadJSONFromPath:(NSString*)path
                 async:(BOOL)async
            shouldCache:(BOOL)shouldCache
        completion:(IXJSONGrabCompletedBlock)completion;

@end
