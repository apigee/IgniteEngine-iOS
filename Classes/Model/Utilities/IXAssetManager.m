//
//  IXAssetManager.m
//  IgniteEngine
//
//  Created by Brandon on 4/15/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXAssetManager.h"
#import "IXConstants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IXPathHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation IXAssetManager

+(void)dataFromAssetLibraryAsset:(NSURL*)assetLibraryURL resultBlock:(void(^)(NSData* data, NSString* mimeType))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetLibraryURL resultBlock:^(ALAsset *asset) {
//         UIImage  *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.5 orientation:UIImageOrientationUp];
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSString* mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass ((__bridge CFStringRef)[rep UTI], kUTTagClassMIMEType) ?: @"application/octet-stream";
        block([NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES], mimeType);
    } failureBlock:^(NSError *error) {
        IX_LOG_DEBUG(@"Error: %@", [error localizedDescription]);
        block(nil, nil);
    }];
}

+(NSDictionary*)dataForAttachmentsDict:(NSDictionary*)dict
{
    NSMutableDictionary* attachments = [NSMutableDictionary new];
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSURL class]])
        {
            NSURL* url = [(NSURL*)obj copy];
            if ([IXPathHandler pathIsAssetsLibrary:[url absoluteString]]) {
                dispatch_async(queue, ^{
                    [self dataFromAssetLibraryAsset:url resultBlock:^(NSData *data, NSString* mimeType) {
                        [attachments setObject:@{@"data": data, @"mimeType": mimeType} forKey:key];
                        dispatch_semaphore_signal(sema);
                    }];
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
        }
    }];
    return attachments;
}

@end
