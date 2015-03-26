//
//  IXDataGrabber.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RXMLElement;

typedef void(^IXJSONGrabCompletedBlock)(id jsonObject, NSString* stringValue, NSError *error);
typedef void(^IXXMLGrabCompletedBlock)(RXMLElement* rXMLElement, NSString* stringValue, NSError *error);

@interface IXDataGrabber : NSObject

+(IXDataGrabber*)sharedDataGrabber;
+(void)clearCache;

-(void)grabJSONFromPath:(NSString*)path
                 asynch:(BOOL)asynch
            shouldCache:(BOOL)shouldCache
        completionBlock:(IXJSONGrabCompletedBlock)grabCompletionBlock;

-(void)grabXMLFromPath:(NSString*)path
                asynch:(BOOL)asynch
           shouldCache:(BOOL)shouldCache
       completionBlock:(IXXMLGrabCompletedBlock)grabCompletionBlock;

@end
