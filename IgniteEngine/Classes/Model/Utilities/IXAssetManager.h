//
//  IXAssetManager.h
//  IgniteEngine
//
//  Created by Brandon on 4/15/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IXAssetManager : NSObject

+(void)dataFromAssetLibraryAsset:(NSURL*)assetLibraryURL resultBlock:(void(^)(NSData* data))block;
+(NSDictionary*)dataForAttachmentsDict:(NSDictionary*)dict;

@end
