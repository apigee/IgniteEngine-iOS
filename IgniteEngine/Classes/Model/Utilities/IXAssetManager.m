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

@implementation IXAssetManager

+(void)dataFromAssetLibraryAsset:(NSURL*)assetLibraryURL resultBlock:(void(^)(NSData* data))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetLibraryURL resultBlock:^(ALAsset *asset) {
//         UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.5 orientation:UIImageOrientationUp];
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        block([NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES]);
    } failureBlock:^(NSError *error) {
        IX_LOG_DEBUG(@"Error: %@", [error localizedDescription]);
        block(nil);
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
            // MIME type and file name are automatically detected here
            if ([IXPathHandler pathIsAssetsLibrary:[url absoluteString]]) {
                dispatch_async(queue, ^{
                    [self dataFromAssetLibraryAsset:url resultBlock:^(NSData *data) {
                        [attachments setObject:data forKey:key];
                        dispatch_semaphore_signal(sema);
                        //NSString* queryString = [[[url absoluteString] componentsSeparatedByString:@"?"] lastObject];
                        //NSDictionary* queryParams = [NSDictionary ix_dictionaryFromQueryParamsString:queryString];
                        //NSString* ext = [queryParams[@"ext"] lowercaseString];
                        //NSString* fileName = [NSString stringWithFormat:@"%@.%@", key, ext];
                        //                            NSInputStream* stream = [[NSInputStream alloc] initWithData:data];
                        //                            [formData appendPartWithInputStream:stream name:key fileName:fileName length:[data length] mimeType:kIXMimeTypeOctetStream];
                        //[formData appendPartWithFileData:data name:key fileName:fileName mimeType:kIXMimeTypeOctetStream];
                    }];
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
        }
    }];
    return attachments;
}

@end
