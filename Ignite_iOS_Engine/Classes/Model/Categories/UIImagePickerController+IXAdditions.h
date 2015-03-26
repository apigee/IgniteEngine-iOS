//
//  UIImagePickerController+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (IXAdditions)

+(UIImagePickerControllerSourceType)stringToSourceType:(NSString*)sourceTypeString;
+(UIImagePickerControllerCameraDevice)stringToCameraDevice:(NSString*)cameraDeviceString;

@end
