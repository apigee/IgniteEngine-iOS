//
//  IXJSONGrabber.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/26/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IXJSONGrabCompletedBlock)(id jsonObject, NSError *error);

@interface IXJSONGrabber : NSObject

+(IXJSONGrabber*)sharedJSONGrabber;
+(void)clearCache;

-(void)grabJSONFromPath:(NSString*)path
                 asynch:(BOOL)asynch
        completionBlock:(IXJSONGrabCompletedBlock)grabCompletionBlock;

@end
