//
//  UIImagePickerController+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "UIImagePickerController+IXAdditions.h"

@implementation UIImagePickerController (IXAdditions)

+(UIImagePickerControllerSourceType)stringToSourceType:(NSString*)sourceTypeString
{
    UIImagePickerControllerSourceType returnSourceType = UIImagePickerControllerSourceTypeCamera;
    if( [sourceTypeString isEqualToString:@"camera"] || [sourceTypeString isEqualToString:@"video"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if( [sourceTypeString isEqualToString:@"library"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if( [sourceTypeString isEqualToString:@"saved_photos"] )
    {
        returnSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    return returnSourceType;
}

+(UIImagePickerControllerCameraDevice)stringToCameraDevice:(NSString*)cameraDeviceString
{
    UIImagePickerControllerCameraDevice returnCameraDevice = UIImagePickerControllerCameraDeviceRear;
    if ( [cameraDeviceString isEqualToString:@"front"] )
        returnCameraDevice = UIImagePickerControllerCameraDeviceFront;
    if ( [cameraDeviceString isEqualToString:@"rear"] )
        returnCameraDevice = UIImagePickerControllerCameraDeviceRear;
    return returnCameraDevice;
}

@end
